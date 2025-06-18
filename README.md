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

`PORT`=5000

`MONGO_URI`=mongodb+srv://<user>:<password>@<cluster>.mongodb.net/<dbname>?retryWrites=true&w=majority

`JWT_SECRET`=your_jwt_secret_key

`EMAIL_HOST`=smtp.your-email-provider.com

`EMAIL_PORT`=465

`EMAIL_USER`=your-email@example.com

`EMAIL_PASS`=your-email-password


### Tambahkan FIle Firebase

Tambahkan file firebase-admin.json ke direktori root. File ini dapat diunduh dari:

`Firebase Console > Project Settings > Service Accounts > Generate New Private Key`


### Jalankan Server

```bash
  node server.js
```


## Sadewa Smart Farm Frontend

Pada file `api_service.dart` terdapat base URL API yang menghubungkan antara backend dengan frontend.

Secara default, backend telah dideploy ke platform Railway dengan base URL production sebagai berikut:

`static const String baseUrl = "https://backendsadewasmartfarm-production.up.railway.app/api";`

Untuk penggunaan di perangkat lain seperti smartphone untuk keperluan testing dapat menggunakan URL:

`static const String baseUrl = "http://<IP Lokal>/api";`



### Cara Mengetahui IP Lokal

Untuk mengakses backend dari perangkat lain seperti HP (misalnya saat testing Flutter), Anda perlu mengetahui IP lokal dari komputer yang menjalankan backend.


### 🖥️ Windows

Buka **Command Prompt** lalu jalankan perintah berikut:

```bash
ipconfig
```

Cari bagian seperti ini:

```bash
Wireless LAN adapter Wi-Fi:

   IPv4 Address. . . . . . . . . . . : 192.168.xx.xx
```

Gunakan IP tersebut dalam URL Anda, misalnya:

`static const String baseUrl = "http://192.168.xx.xx:5000/api";`


### 🖥️ MAC/Linux

Buka Terminal dan jalankan salah satu perintah berikut:

```bash
ifconfig
```

atau

```bash
hostname -I
```

Hasilnya akan menampilkan IP lokal seperti:

```bash
192.168.xx.xx
```
