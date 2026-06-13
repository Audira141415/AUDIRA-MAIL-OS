import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AutomationService {
  private readonly logger = new Logger(AutomationService.name);

  constructor(private prisma: PrismaService) {}

  async createRule(name: string, conditions: any, actions: any[]) {
    return this.prisma.automationRule.create({
      data: {
        name,
        triggerEvent: 'email_received',
        conditions: JSON.stringify(conditions),
        actions: JSON.stringify(actions),
      },
    });
  }

  async getRules() {
    return this.prisma.automationRule.findMany({
      orderBy: { createdAt: 'desc' },
    });
  }

  async updateRule(id: string, data: { name?: string, conditions?: any, actions?: any[], isActive?: boolean }) {
    return this.prisma.automationRule.update({
      where: { id },
      data: {
        ...(data.name && { name: data.name }),
        ...(data.conditions && { conditions: JSON.stringify(data.conditions) }),
        ...(data.actions && { actions: JSON.stringify(data.actions) }),
        ...(data.isActive !== undefined && { isActive: data.isActive }),
      },
    });
  }

  async deleteRule(id: string) {
    return this.prisma.automationRule.delete({
      where: { id },
    });
  }

  async getLogs(limit = 50) {
    return this.prisma.automationLog.findMany({
      orderBy: { createdAt: 'desc' },
      take: limit,
      include: {
        rule: true,
        email: {
          select: {
            subject: true,
            sender: true,
            category: true,
          }
        },
      },
    });
  }

  // Execute rules on an incoming email
  async runRules(email: any) {
    const activeRules = await this.prisma.automationRule.findMany({
      where: { isActive: true },
    });

    if (activeRules.length === 0) return;

    for (const rule of activeRules) {
      try {
        let isMatch = true;
        const conditions = JSON.parse(rule.conditions || '{}');

        // Check category condition
        if (conditions.category && conditions.category !== 'All' && email.category !== conditions.category) {
          isMatch = false;
        }

        // Check sender condition
        if (conditions.senderContains && !email.sender.toLowerCase().includes(conditions.senderContains.toLowerCase())) {
          isMatch = false;
        }

        // Check subject condition
        if (conditions.subjectContains && !email.subject.toLowerCase().includes(conditions.subjectContains.toLowerCase())) {
          isMatch = false;
        }

        if (isMatch) {
          this.logger.log(`Running automation rule "${rule.name}" for email ${email.id}`);
          const actions = JSON.parse(rule.actions || '[]');
          
          for (const action of actions) {
            await this.executeAction(action, email, rule.id);
          }
        }
      } catch (err) {
        this.logger.error(`Error running rule ${rule.id} on email ${email.id}`, err);
      }
    }
  }

  private async executeAction(action: any, email: any, ruleId: string) {
    let status = 'Success';
    let details = '';

    try {
      if (action.type === 'webhook') {
        const payload = {
          event: 'email_received',
          emailId: email.id,
          sender: email.sender,
          recipient: email.recipient,
          subject: email.subject,
          category: email.category,
          receivedAt: email.receivedAt,
          bodyText: email.bodyText,
          sentiment: email.sentiment,
          securityScore: email.securityScore,
        };

        const res = await fetch(action.value, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
          signal: AbortSignal.timeout(5000),
        });

        if (!res.ok) {
          throw new Error(`HTTP ${res.status}`);
        }

        details = `Webhook sent successfully to ${action.value}`;
      } else if (action.type === 'assign_team') {
        const team = await this.prisma.team.findFirst({
          where: { name: { contains: action.value, mode: 'insensitive' } }
        });
        
        if (team) {
          await this.prisma.assignment.upsert({
            where: { emailId: email.id },
            update: { teamId: team.id },
            create: {
              emailId: email.id,
              teamId: team.id,
              status: 'Open'
            }
          });
          details = `Assigned email to Team: ${team.name}`;
        } else {
          status = 'Failed';
          details = `Failed to find team matching name: ${action.value}`;
        }
      } else if (action.type === 'auto_reply') {
        details = `Auto-reply draft prepared with template: ${action.value}`;
      } else {
        status = 'Failed';
        details = `Unknown action type: ${action.type}`;
      }
    } catch (error: any) {
      status = 'Failed';
      details = `Action execution error: ${error.message}`;
    }

    // Log automation execution
    await this.prisma.automationLog.create({
      data: {
        ruleId,
        emailId: email.id,
        status,
        details,
      },
    });
  }
}
