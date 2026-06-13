# AUDIRA-MAIL-OS 🚀

AUDIRA-MAIL-OS adalah platform manajemen email tingkat lanjut yang didukung oleh kecerdasan buatan (AI) dan fitur otomatisasi yang komprehensif. Didesain untuk tim dan profesional yang menginginkan efisiensi maksimal, pemantauan ancaman keamanan, dan otomatisasi alur kerja dalam satu dashboard cerdas.

## ✨ Fitur Unggulan

- **Unified Inbox & Sandbox Preview**: Kotak masuk terpusat dengan *Phishing Safety Banner* dan rendering *Sandbox iframe* untuk menghindari eksekusi script jahat.
- **AI Copilot & Autopilot Drafts**: Analisis sentimen dari pesan masuk dan penyusunan draf balasan otomatis menggunakan AI.
- **Automations & Webhook Builder**: *Zero-code builder* untuk membuat aturan otomatis, meneruskan email via Webhook, atau menugaskan tim.
- **Pusat OTP & Secure Sharing**: Ekstraksi kode OTP secara otomatis dari email masuk dan tautan berbagi OTP publik dengan *self-destruct timer*.
- **Mobile App**: Dukungan integrasi aplikasi mobile (Flutter) untuk pemantauan real-time.

## 🏗️ Arsitektur Sistem

Proyek ini dibangun menggunakan arsitektur *microservices* dan diorkestrasi melalui Docker:

| Layanan | Teknologi | Port |
|---------|-----------|------|
| **Frontend Web** | Next.js (App Router) | 3310 |
| **Backend API** | NestJS | 3311 |
| **Mail Engine** | Node.js (Gmail API) | 3312 |
| **AI Engine** | Python / Node.js | 3313 |
| **Worker Engine** | Node.js (BullMQ) | 3314 |
| **Notif Engine** | WebSocket (Socket.io) | 3315 |

## 🚀 Cara Menjalankan (Local Development)

Pastikan Docker telah terinstall di sistem Anda.

1. Clone repositori ini:
   ```bash
   git clone https://github.com/Audira141415/AUDIRA-MAIL-OS.git
   cd AUDIRA-MAIL-OS
   ```
2. Jalankan sistem melalui file batch:
   ```bash
   ./start.bat
   ```
3. Untuk menghentikan sistem:
   ```bash
   ./stop.bat
   ```

## 🤝 Kontribusi

Harap baca [CONTRIBUTING.md](CONTRIBUTING.md) jika Anda ingin berkontribusi pada proyek ini.

## 📜 Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE). 
Copyright (c) 2026 Agus Dwi R (AUDIRA).
