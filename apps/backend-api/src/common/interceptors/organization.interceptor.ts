import { Injectable, NestInterceptor, ExecutionContext, CallHandler, UnauthorizedException } from '@nestjs/common';
import { Observable } from 'rxjs';

@Injectable()
export class OrganizationInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    // Optional: Enforcement logic for tenant isolation
    // If a route requires organization context, we can enforce it here.
    if (user && !user.organizationId && !user.isTemp && user.role !== 'Super Admin') {
      // For now, we won't block it to allow seamless migration, 
      // but in a strict environment, we would throw:
      // throw new UnauthorizedException('User does not belong to any organization');
    }

    // Attach organization context to request for downstream services
    if (user && user.organizationId) {
      request.organizationId = user.organizationId;
    }

    return next.handle();
  }
}
