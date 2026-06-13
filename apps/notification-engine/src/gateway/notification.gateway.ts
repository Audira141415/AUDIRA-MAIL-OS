import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';
import * as jwt from 'jsonwebtoken';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class NotificationGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(NotificationGateway.name);
  private userSockets = new Map<string, string[]>(); // userId -> socketIds[]

  handleConnection(client: Socket) {
    try {
      const token = client.handshake.auth.token?.split(' ')[1] || client.handshake.headers.authorization?.split(' ')[1];
      if (!token) {
        this.logger.warn(`Client connected without token, disconnecting. id: ${client.id}`);
        client.disconnect();
        return;
      }
      
      const payload = jwt.verify(token, process.env.JWT_SECRET || 'audira_enterprise_secret_key') as any;
      const userId = payload.sub || payload.id;
      
      if (!userId) {
        client.disconnect();
        return;
      }

      // Add to userSockets map
      const sockets = this.userSockets.get(userId) || [];
      sockets.push(client.id);
      this.userSockets.set(userId, sockets);
      
      // Join a room specifically for this user
      client.join(`user-${userId}`);
      
      this.logger.log(`Client connected: ${client.id} for user ${userId}`);
    } catch (err) {
      this.logger.error('Invalid token for socket connection', err);
      client.disconnect();
    }
  }

  handleDisconnect(client: Socket) {
    // Find and remove socket id
    for (const [userId, sockets] of this.userSockets.entries()) {
      const idx = sockets.indexOf(client.id);
      if (idx !== -1) {
        sockets.splice(idx, 1);
        if (sockets.length === 0) {
          this.userSockets.delete(userId);
        } else {
          this.userSockets.set(userId, sockets);
        }
        break;
      }
    }
    this.logger.log(`Client disconnected: ${client.id}`);
  }

  // Method to be called by controllers or redis subscribers
  notifyUser(userId: string, event: string, data: any) {
    this.server.to(`user-${userId}`).emit(event, data);
    this.logger.log(`Sent event ${event} to user ${userId}`);
  }
}
