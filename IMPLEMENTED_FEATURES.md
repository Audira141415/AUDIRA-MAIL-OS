# Dokumen Hasil Implementasi Fitur - AUDIRA-MAIL-OS

Dokumen ini berfungsi sebagai **Single Source of Truth (SSOT)** atau peta fitur yang telah diimplementasikan dalam proyek **AUDIRA-MAIL-OS**. Gunakan dokumen ini sebagai acuan utama sebelum mengembangkan fitur baru guna menghindari duplikasi kode atau penumpukan fungsionalitas (*feature overlap*).

---

## 1. Arsitektur Global & Pemetaan Port

Sistem berjalan secara lokal menggunakan orkestrasi kontainer Docker ([docker-compose.yml](file:///f:/AUDIRA-MAIL-OS/docker-compose.yml)). Berikut adalah pemetaan layanan beserta port eksternalnya:

| Nama Layanan | Direktori | Port Lokal | Deskripsi |
| :--- | :--- | :--- | :--- |
| **`postgres`** | - | `5444` | Database PostgreSQL utama sistem. |
| **`redis`** | - | `6379` | Cache & Antrean (Queue) pesan sinkronisasi. |
| **`frontend-web`** | [/apps/frontend-web](file:///f:/AUDIRA-MAIL-OS/apps/frontend-web) | `3310` | Web dashboard panel Next.js (App Router). |
| **`backend-api`** | [/apps/backend-api](file:///f:/AUDIRA-MAIL-OS/apps/backend-api) | `3311` | Koordinator API utama (Auth, Users, Dashboard, dll.). |
| **`mail-engine`** | [/apps/mail-engine](file:///f:/AUDIRA-MAIL-OS/apps/mail-engine) | `3312` | Sinkronisasi Gmail API & Deteksi Kode OTP. |
| **`ai-engine`** | [/apps/ai-engine](file:///f:/AUDIRA-MAIL-OS/apps/ai-engine) | `3313` | Integrasi OpenAI (Klasifikasi, Sandbox, Sentimen). |
| **`worker-engine`** | [/apps/worker-engine](file:///f:/AUDIRA-MAIL-OS/apps/worker-engine) | `3314` | Worker untuk background jobs & webhook queuing. |
| **`notification-engine`** | [/apps/notification-engine](file:///f:/AUDIRA-MAIL-OS/apps/notification-engine) | `3315` | Gateway WebSocket (Socket.io) untuk OTP real-time. |

---

## 2. Peta Model Database ([schema.prisma](file:///f:/AUDIRA-MAIL-OS/packages/database/prisma/schema.prisma))

Semua modul menggunakan client database terpusat yang diekspor dari package `@audira/database`.

*   **Manajemen Organisasi & Akun**: `Organization`, `Subscription`, `ApiKey`, `User`, `Role`, `Permission`, `Session`, `Device`.
*   **Gmail & Email**:
    *   `GmailAccount`: Menampung status koneksi (`connected`/`disconnected`) dan tokens OAuth.
    *   `Email`: Modul pesan masuk. Ditambahkan field analisis: `category`, `sentiment`, `securityScore`, `securityAnalysis`.
    *   `Attachment`: Informasi file lampiran yang diunggah ke penyimpanan MinIO.
*   **Pusat OTP & Keamanan**:
    *   `OtpMessage`: Kode verifikasi 6-digit yang diekstraksi dari email.
    *   `OtpShareLink`: Token sharing publik untuk OTP yang memiliki waktu kedaluwarsa (*self-destruct*).
*   **Sistem Automasi Webhook**:
    *   `AutomationRule`: Kriteria pemicu (*Trigger*) dan aksi JSON (*Actions*).
    *   `AutomationLog`: Riwayat eksekusi automasi (Success/Failed).
*   **Tim & Tugas**: `Team`, `UserTeam`, `Assignment` (untuk mendistribusikan email sebagai tiket tugas ke tim).

---

## 3. Rincian Fitur yang Telah Diimplementasikan

Guna menghindari pembuatan fitur ganda, pastikan Anda merujuk pada kode modul yang sudah ada di bawah ini:

### A. Otentikasi & Keamanan Pengguna
*   **Fitur**: Login JWT, Registrasi, session management, dan verifikasi MFA.
*   **Lokasi Kode**:
    *   Backend: [auth.service.ts](file:///f:/AUDIRA-MAIL-OS/apps/backend-api/src/auth/auth.service.ts) & [auth.controller.ts](file:///f:/AUDIRA-MAIL-OS/apps/backend-api/src/auth/auth.controller.ts)
    *   Frontend: [store/auth.ts](file:///f:/AUDIRA-MAIL-OS/apps/frontend-web/src/store/auth.ts)

### B. Integrasi Gmail & Sinkronisasi Email
*   **Fitur**: Autentikasi Google OAuth2, bulk sync, bulk delete akun Gmail, pembaruan tag Gmail, dan sinkronisasi otomatis periodik menggunakan Cron Job setiap 5 menit.
*   **Lokasi Kode**:
    *   Backend: [gmail.service.ts](file:///f:/AUDIRA-MAIL-OS/apps/backend-api/src/gmail/gmail.service.ts)
    *   Frontend: [accounts/page.tsx](file:///f:/AUDIRA-MAIL-OS/apps/frontend-web/src/app/(dashboard)/accounts/page.tsx)

### C. Unified Inbox & Sandbox Preview (Anti-Phishing)
*   **Fitur**: Kotak masuk terpusat dari seluruh email dengan filter kategori otomatis. Email yang diklik akan terbuka di panel detail dengan:
    1.  **Phishing Safety Banner**: Menampilkan skor keamanan (0-100), klasifikasi ancaman (Safe, Suspicious, Malicious), dan indikator bahaya dari AI.
    2.  **Sandbox Frame**: Menampilkan isi HTML/Text email di dalam iframe terisolasi (`sandbox="allow-popups"`) dengan membuang tag `<script>` guna memblokir eksekusi javascript atau tracking pixel jahat.
*   **Lokasi Kode**:
    *   Analisis AI: `analyzeSecurity` di [copilot.service.ts](file:///f:/AUDIRA-MAIL-OS/apps/ai-engine/src/copilot/copilot.service.ts)
    *   Frontend View: [inbox/page.tsx](file:///f:/AUDIRA-MAIL-OS/apps/frontend-web/src/app/(dashboard)/inbox/page.tsx)

### D. Pusat OTP & Secure Expiry Sharing
*   **Fitur**: Ekstraksi otomatis kode OTP 6-digit dari subjek/isi email. Mengirim notifikasi push FCM dan event WebSocket secara real-time. Menyediakan tombol **"Share"** untuk menghasilkan tautan berbagi aman yang otomatis hancur (*self-destruct*) ketika dibuka sekali atau waktu kedaluwarsa habis.
*   **Lokasi Kode**:
    *   Backend: [otp-share.service.ts](file:///f:/AUDIRA-MAIL-OS/apps/backend-api/src/otp/otp-share.service.ts) & [otp-share.controller.ts](file:///f:/AUDIRA-MAIL-OS/apps/backend-api/src/otp/otp-share.controller.ts)
    *   WebSocket gateway: [notification.gateway.ts](file:///f:/AUDIRA-MAIL-OS/apps/notification-engine/src/gateway/notification.gateway.ts)
    *   Dashboard Share: [otp/page.tsx](file:///f:/AUDIRA-MAIL-OS/apps/frontend-web/src/app/(dashboard)/otp/page.tsx)
    *   Public Share Page: [otp/share/[token]/page.tsx](file:///f:/AUDIRA-MAIL-OS/apps/frontend-web/src/app/otp/share/[token]/page.tsx)

### E. AI Copilot Chat & Autopilot Drafts
*   **Fitur**: Chatbot AI kontekstual untuk membantu pencarian email. AI juga menganalisis sentimen email (Anger, Urgent, Positive, dll.) dan secara otomatis merancang draf balasan kontekstual (*Autopilot*) yang dapat dikirim langsung oleh staf admin.
*   **Lokasi Kode**:
    *   Copilot Engine: [copilot.service.ts](file:///f:/AUDIRA-MAIL-OS/apps/ai-engine/src/copilot/copilot.service.ts)
    *   Triage & Draft View: [inbox/page.tsx](file:///f:/AUDIRA-MAIL-OS/apps/frontend-web/src/app/(dashboard)/inbox/page.tsx)

### F. Automations & Webhook Builder
*   **Fitur**: Pembuat aturan automasi tanpa kode (*zero-code*). Ketika email masuk memenuhi kriteria (misal: kategori `Finance`, pengirim mengandung `@aws.com`), sistem akan memicu aksi:
    1.  **Webhook**: Mengirim payload JSON data email ke URL eksternal (Discord, Slack, REST API).
    2.  **Assign Team**: Mengalihkan email secara otomatis sebagai tiket tugas ke tim tertentu.
    3.  **Auto-Reply**: Menyiapkan template draf jawaban otomatis.
    4.  **Execution Logs**: Log status eksekusi aturan (Success/Failed) secara mendetail.
*   **Lokasi Kode**:
    *   Rule Runner & Execute: [automation.service.ts](file:///f:/AUDIRA-MAIL-OS/apps/backend-api/src/automations/automation.service.ts)
    *   API Endpoint: [automation.controller.ts](file:///f:/AUDIRA-MAIL-OS/apps/backend-api/src/automations/automation.controller.ts)
    *   UI Page: [automations/page.tsx](file:///f:/AUDIRA-MAIL-OS/apps/frontend-web/src/app/(dashboard)/automations/page.tsx)

---

## 4. Panduan Pengembangan Selanjutnya (Anti-Duplikasi)

*   **Jangan Membuat Pipeline Sinkronisasi Email Baru**: Pipeline sinkronisasi email masuk terpusat di `syncEmails()` pada [gmail.service.ts](file:///f:/AUDIRA-MAIL-OS/apps/backend-api/src/gmail/gmail.service.ts). Jika ingin menambahkan logika pasca-sinkronisasi (seperti analisis spam baru), kaitkan fungsinya di dalam blok pasca-upsert email pada file tersebut.
*   **Jangan Membuat Layanan HTTP Request Webhook Baru**: Gunakan runner terpadu di dalam `executeAction()` pada [automation.service.ts](file:///f:/AUDIRA-MAIL-OS/apps/backend-api/src/automations/automation.service.ts) yang sudah dilengkapi dengan logging otomatis ke tabel `AutomationLog` dan penanganan *timeout*.
*   **Gunakan Layanan Global**:
    *   Untuk operasi basis data, selalu inject `PrismaService` (Global).
    *   Untuk pengiriman push notification, gunakan `FirebaseService` (Global).
