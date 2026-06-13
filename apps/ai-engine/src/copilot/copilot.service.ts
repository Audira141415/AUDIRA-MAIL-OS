import { Injectable, Logger } from '@nestjs/common';
import OpenAI from 'openai';

@Injectable()
export class CopilotService {
  private openai: OpenAI | null = null;
  private readonly logger = new Logger(CopilotService.name);

  constructor() {
    const apiKey = process.env.OPENAI_API_KEY;
    if (apiKey && apiKey !== 'YOUR_OPENAI_API_KEY_HERE') {
      this.openai = new OpenAI({ apiKey });
    } else {
      this.logger.warn('OPENAI_API_KEY not configured. Falling back to mock AI mode.');
    }
  }

  async getChatResponse(message: string, context?: string): Promise<string> {
    const systemPrompt = `You are Audira Copilot, an advanced AI assistant designed to help users manage their email, analyze sentiments, and generate automated replies. Your tone is professional, concise, and slightly futuristic (like an AI OS terminal). Do not use markdown if possible, keep it plain text. 
    Here is the current real-time context of the user's data from the database: 
    ${context || 'No specific context available.'}`;

    if (this.openai) {
      try {
        const response = await this.openai.chat.completions.create({
          model: 'gpt-4o-mini',
          messages: [
            { role: 'system', content: systemPrompt },
            { role: 'user', content: message }
          ],
        });
        return response.choices[0]?.message?.content || 'Error generating response.';
      } catch (error) {
        this.logger.error('OpenAI Error', error);
        return 'I encountered a systemic error communicating with the neural net. Please check your API key.';
      }
    } else {
      // Mock mode
      await new Promise(resolve => setTimeout(resolve, 1500)); // simulate network delay
      
      const lowerMsg = message.toLowerCase();
      if (lowerMsg.includes('email') || lowerMsg.includes('inbox') || lowerMsg.includes('how many')) {
        return `[MOCK MODE] I have analyzed your system. ${context || ''} What would you like to do next?`;
      } else if (lowerMsg.includes('otp') || lowerMsg.includes('code')) {
        return `[MOCK MODE] Scanning for recent authentication codes... ${context || ''}`;
      } else if (lowerMsg.includes('hello') || lowerMsg.includes('hi')) {
        return '[MOCK MODE] GREETINGS USER. I am online and ready to assist with your communication workflows.';
      } else {
        return `[MOCK MODE] I have processed your query regarding: "${message}". In demo mode, my cognitive functions are limited, but my systems are fully operational.`;
      }
    }
  }

  async classifyEmail(subject: string, body: string): Promise<string> {
    const text = `${subject} ${body}`.toLowerCase();
    
    if (this.openai) {
      try {
        const response = await this.openai.chat.completions.create({
          model: 'gpt-4o-mini',
          messages: [
            { role: 'system', content: 'You are an email classifier. Return ONLY ONE word from this list: OTP, Finance, Promotions, Support, Updates, General.' },
            { role: 'user', content: `Subject: ${subject}\nBody: ${body}` }
          ],
        });
        return response.choices[0]?.message?.content?.trim() || 'General';
      } catch (error) {
        this.logger.error('Classification Error', error);
      }
    }
    
    // Mock Mode Fast Regex Fallback
    if (text.includes('otp') || text.includes('code') || text.includes('verification') || text.includes('password')) return 'OTP';
    if (text.includes('invoice') || text.includes('receipt') || text.includes('payment') || text.includes('order')) return 'Finance';
    if (text.includes('offer') || text.includes('sale') || text.includes('discount') || text.includes('promo')) return 'Promotions';
    if (text.includes('support') || text.includes('ticket') || text.includes('help')) return 'Support';
    if (text.includes('meeting') || text.includes('calendar') || text.includes('schedule')) return 'Updates';
    
    return 'General';
  }

  async analyzeSecurity(subject: string, body: string): Promise<{ securityScore: number, classification: string, indicators: string[], details: string }> {
    const text = `${subject} ${body}`.toLowerCase();
    if (this.openai) {
      try {
        const response = await this.openai.chat.completions.create({
          model: 'gpt-4o-mini',
          messages: [
            {
              role: 'system',
              content: 'You are an email anti-phishing analyzer. Analyze the email subject and body for security threats. Return a JSON object with: { "securityScore": number (0-100, where 100 is perfectly safe and 0 is extremely dangerous/phishing), "classification": string ("Safe" | "Suspicious" | "Malicious"), "indicators": string[] (reasons/threats found), "details": string (short description) }'
            },
            { role: 'user', content: `Subject: ${subject}\nBody: ${body}` }
          ],
          response_format: { type: 'json_object' }
        });
        const result = JSON.parse(response.choices[0]?.message?.content || '{}');
        return {
          securityScore: typeof result.securityScore === 'number' ? result.securityScore : 90,
          classification: result.classification || 'Safe',
          indicators: Array.isArray(result.indicators) ? result.indicators : [],
          details: result.details || 'System scan completed.'
        };
      } catch (error) {
        this.logger.error('AI Security analysis error, falling back to heuristics', error);
      }
    }

    // Heuristic Fallback
    let securityScore = 100;
    const indicators: string[] = [];
    let classification = 'Safe';

    if (text.includes('urgent') || text.includes('action required') || text.includes('immediate')) {
      securityScore -= 20;
      indicators.push('Urgency tone detected');
    }
    if (text.includes('password') || text.includes('credential') || text.includes('login') || text.includes('verify your account')) {
      securityScore -= 30;
      indicators.push('Request for credentials or login link');
    }
    if (text.includes('http://') || text.includes('click here') || text.includes('free') || text.includes('gift')) {
      securityScore -= 20;
      indicators.push('Suspicious links or promotional bait');
    }

    if (securityScore < 50) {
      classification = 'Malicious';
    } else if (securityScore < 85) {
      classification = 'Suspicious';
    }

    return {
      securityScore,
      classification,
      indicators,
      details: `[MOCK MODE] Heuristic scanner rated this email as ${classification}.`
    };
  }

  async analyzeSentimentAndReply(subject: string, body: string): Promise<{ sentiment: string, draftedReply: string }> {
    const text = `${subject} ${body}`.toLowerCase();
    if (this.openai) {
      try {
        const response = await this.openai.chat.completions.create({
          model: 'gpt-4o-mini',
          messages: [
            {
              role: 'system',
              content: 'You are an email manager. Analyze the sentiment of this email and draft a suitable response in the same language as the email. Return a JSON object with: { "sentiment": string ("Positive" | "Negative" | "Neutral" | "Urgent" | "Anger"), "draftedReply": string }'
            },
            { role: 'user', content: `Subject: ${subject}\nBody: ${body}` }
          ],
          response_format: { type: 'json_object' }
        });
        const result = JSON.parse(response.choices[0]?.message?.content || '{}');
        return {
          sentiment: result.sentiment || 'Neutral',
          draftedReply: result.draftedReply || 'Thank you for your message. We are reviewing it.'
        };
      } catch (error) {
        this.logger.error('AI Sentiment analysis error, falling back to mock', error);
      }
    }

    // Heuristic Fallback
    let sentiment = 'Neutral';
    let draftedReply = 'Thank you for your email. We have received it and will follow up shortly.';

    if (text.includes('angry') || text.includes('hate') || text.includes('bad') || text.includes('worst') || text.includes('terrible') || text.includes('disappointed')) {
      sentiment = 'Anger';
      draftedReply = 'We apologize sincerely for the negative experience you had. Our team is actively looking into this issue to resolve it as quickly as possible. Thank you for your patience.';
    } else if (text.includes('urgent') || text.includes('asap') || text.includes('immediately') || text.includes('emergency')) {
      sentiment = 'Urgent';
      draftedReply = 'Thank you for your urgent request. We have prioritized this email and assigned it to our support specialists. We will get back to you immediately.';
    } else if (text.includes('thank') || text.includes('great') || text.includes('good') || text.includes('happy') || text.includes('love')) {
      sentiment = 'Positive';
      draftedReply = 'Thank you so much for the positive feedback! We are thrilled to hear you had a great experience. Have a wonderful day!';
    } else if (text.includes('problem') || text.includes('fail') || text.includes('broken') || text.includes('issue')) {
      sentiment = 'Negative';
      draftedReply = 'We are sorry to hear you are encountering issues. Could you please provide additional details or screenshots so we can troubleshoot this for you?';
    }

    return {
      sentiment,
      draftedReply: `[MOCK MODE] ${draftedReply}`
    };
  }
}
