import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, Profile } from '@node-saml/passport-saml';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class SamlStrategy extends PassportStrategy(Strategy, 'saml') {
  constructor(private prisma: PrismaService) {
    super({
      callbackUrl: 'http://localhost:3311/api/auth/saml/callback',
      entryPoint: process.env.SAML_ENTRY_POINT || 'https://idp.example.com/saml2/idp/SSOService.php',
      issuer: process.env.SAML_ISSUER || 'audira-mail-os',
      // @ts-ignore
      idpCert: process.env.SAML_CERT || 'dummy_cert_for_compilation',
    }, (profile: any, done: any) => {
      return done(null, profile);
    });
  }

  async validate(profile: Profile | null | undefined): Promise<any> {
    if (!profile) {
      throw new UnauthorizedException('SAML profile not found');
    }

    // Assuming the SAML response maps email to nameID or a specific attribute
    const email = profile.email || profile.nameID;
    
    if (!email) {
       throw new UnauthorizedException('Email not found in SAML profile');
    }

    // Look for the user. In a real enterprise app, you might auto-provision the user
    // if they belong to a known Organization via domain matching.
    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      // Auto-provisioning example (optional)
      // throw new UnauthorizedException('User is not registered');
      // Or create user based on SAML claims
      throw new UnauthorizedException('SAML login failed: User not found in system.');
    }

    return user;
  }
}
