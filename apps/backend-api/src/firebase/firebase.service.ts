import { Injectable, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseService {
  private readonly logger = new Logger(FirebaseService.name);
  private isInitialized = false;

  constructor() {
    this.initFirebase();
  }

  private initFirebase() {
    try {
      // In a real production environment, use GOOGLE_APPLICATION_CREDENTIALS 
      // or pass the service account JSON.
      // For local dev without creds, we might not be able to actually send FCM,
      // but we set it up anyway.
      
      if (!admin.apps.length) {
        // If there's no service account configured, this might fail to send messages,
        // but it initializes the admin SDK.
        admin.initializeApp();
        this.isInitialized = true;
        this.logger.log('Firebase Admin initialized.');
      }
    } catch (e) {
      this.logger.warn(`Firebase Admin init failed (expected in local dev without credentials): ${e.message}`);
    }
  }

  async sendPushNotification(userId: string, title: string, body: string, data?: Record<string, string>) {
    // In a real implementation, you would query the database for the user's FCM device tokens
    // const tokens = await this.prisma.deviceToken.findMany({ where: { userId } });
    
    this.logger.log(`[MOCK PUSH] to User ${userId}: ${title} - ${body}`);
    
    if (!this.isInitialized) {
      return false;
    }

    try {
      // Typically we use admin.messaging().sendToDevice(tokens, payload)
      // For now we'll just log it so it doesn't crash the server since we don't have real tokens yet
      
      // const message = {
      //   notification: { title, body },
      //   data: data || {},
      //   token: 'USER_FCM_TOKEN_HERE'
      // };
      // await admin.messaging().send(message);
      
      return true;
    } catch (error) {
      this.logger.error('Error sending push notification', error);
      return false;
    }
  }
}
