const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');
const prisma = new PrismaClient();

async function main() {
  // Check if admin user already exists
  const existing = await prisma.user.findFirst({ where: { email: 'admin@audira.com' } });
  
  if (existing) {
    console.log('User exists:', existing.email);
    console.log('Has passwordHash:', !!existing.passwordHash);
    
    // Force update password
    const passwordHash = await bcrypt.hash('password123', 10);
    await prisma.user.update({
      where: { email: 'admin@audira.com' },
      data: { passwordHash }
    });
    console.log('Password reset to: password123');
  } else {
    // Create fresh user
    const passwordHash = await bcrypt.hash('password123', 10);
    const user = await prisma.user.create({
      data: {
        name: 'Admin',
        email: 'admin@audira.com',
        passwordHash,
      }
    });
    console.log('Created user:', user.email);
  }
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
