import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { OtpService } from '../otp/otp.service';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private otpService: OtpService,
  ) {}

  async register(registerDto: RegisterDto) {
    const { name, email, password } = registerDto;

    // Check if user exists
    const existingUser = await this.prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new ConflictException('User with this email already exists');
    }

    // Hash password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Create user
    const user = await this.prisma.user.create({
      data: {
        name,
        email,
        passwordHash,
      },
      include: { role: true },
    });

    // Generate JWT
    return this.generateTokens(user.id, user.email, user.role?.name || 'viewer', user.organizationId);
  }

  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;

    const user = await this.prisma.user.findUnique({
      where: { email },
      include: { role: true },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (!user.passwordHash) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);

    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (user.mfaEnabled) {
      // Issue a temporary token just for OTP verification
      const payload = { sub: user.id, email: user.email, role: user.role?.name || 'viewer', organizationId: user.organizationId, isTemp: true };
      const tempToken = this.jwtService.sign(payload, { expiresIn: '5m' });
      return {
        mfaRequired: true,
        tempToken,
        message: 'Please verify OTP',
      };
    }

    // Generate full JWT
    return this.generateTokens(user.id, user.email, user.role?.name || 'viewer', user.organizationId);
  }

  async verifyOtpLogin(userId: string, token: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { role: true },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    const verification = await this.otpService.verifyOtp(userId, token);

    if (!verification.isValid) {
      throw new UnauthorizedException(verification.message || 'Invalid OTP code');
    }

    // OTP is valid, generate full tokens
    return this.generateTokens(user.id, user.email, user.role?.name || 'viewer', user.organizationId);
  }

  private generateTokens(userId: string, email: string, role: string, organizationId?: string | null) {
    const payload = { sub: userId, email, role, organizationId };
    
    return {
      access_token: this.jwtService.sign(payload, { expiresIn: '1h' }),
      refresh_token: this.jwtService.sign(payload, { expiresIn: '7d' }),
      user: {
        id: userId,
        email,
        role,
        organizationId
      }
    };
  }
}
