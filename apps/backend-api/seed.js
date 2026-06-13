const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');
const prisma = new PrismaClient();

async function main() {
  const passwordHash = await bcrypt.hash('password123', 10);
  await prisma.user.create({
    data: {
      email: 'admin@audira.com',
      name: 'Admin',
      passwordHash: passwordHash
    }
  });
  console.log('User created: admin@audira.com / password123');
}

main().catch(console.error).finally(() => prisma.$disconnect());
