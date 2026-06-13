import { Controller, Post, Body, HttpCode, HttpStatus, Get, UseGuards, Request, Res } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  async register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @HttpCode(HttpStatus.OK)
  @Post('login')
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  @UseGuards(JwtAuthGuard)
  @Post('verify-login')
  async verifyOtpLogin(@Request() req: any, @Body('token') token: string) {
    if (!req.user.isTemp) {
      return { error: 'Invalid token type for this operation' };
    }
    return this.authService.verifyOtpLogin(req.user.id, token);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  getProfile(@Request() req: any) {
    return req.user;
  }

  @Get('saml')
  @UseGuards(AuthGuard('saml'))
  async samlLogin() {
    // This route redirects the user to the IdP
  }

  @Post('saml/callback')
  @UseGuards(AuthGuard('saml'))
  async samlCallback(@Request() req: any, @Res() res: any) {
    // SAML callback logic. User is authenticated via SAML here.
    const user = req.user;
    // Generate JWT for the frontend application
    const tokenPayload = (this.authService as any).generateTokens(user.id, user.email, user.role?.name || 'viewer', user.organizationId);
    
    // Redirect to frontend with token
    const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:3310';
    return res.redirect(`${frontendUrl}/auth/saml-success?token=${tokenPayload.access_token}`);
  }
}

