# Tools & Teknologi

- **Express.js** (Backend Framework)
- **MongoDB** (Database NoSQL untuk menyimpan data)
- **Firebase Realtime Database** (Integrasi realtime data IoT)
- **Flutter** (Frontend mobile apps)
- **VS Code** (Development Environment Backend)
- **Android Studio** (Development Environment Frontend)


## Sadewa Smart Farm Backend

Repository ini merupakan backend service untuk aplikasi **Sadewa Smart Farm** yang dibangun menggunakan **Node.js (Express.js)** dan berfungsi sebagai jembatan antara aplikasi Flutter dan layanan database seperti **Firebase Realtime Database** serta **MongoDB**.

### Instalasi

---

Clone the repositori

```bash
  git clone https://github.com/121140084-Rizki-Esa-Fadillah/Sadewa_SmartFarm.git
```

Navigate ke directori

```bash
  cd Sadewa_SmartFarm/backend
```

Install dependencies

```bash
  npm install
```

### Setup Environment

Buat file .env di direktori root dan tambahkan konfigurasi berikut:

* Konfigurasi server 

PORT=5000
MONGO_URI=mongodb+srv://<user>:<password>@<cluster>.mongodb.net/<dbname>?retryWrites=true&w=majority
JWT_SECRET=your_jwt_secret_key
EMAIL_HOST=smtp.your-email-provider.com
EMAIL_PORT=587
EMAIL_USER=your-email@example.com
EMAIL_PASS=your-email-password




