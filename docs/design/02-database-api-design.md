# 02 - Database dan API Design

**Sistem** : Campus Service Request and Maintenance System (Sistem Tiketing Laporan Fasilitas Kampus)

**Tanggal** : 2026-06-29

**Skill Digunakan** : `07-database-dan-api-design`

**Input**

* CASE.md
* docs/requirements/
* docs/design/01-architecture.md

**Output**

* docs/design/02-database-api-design.md
* database/schema.sql
* database/seed.sql

**Versi** : 1.0

**Status** : Draft — Menunggu Human Review

---

# 1. Tujuan

Dokumen ini mendefinisikan rancangan database dan REST API sebagai dasar implementasi backend.

Tujuan utama:

* Menentukan struktur penyimpanan data.
* Menentukan relasi antar tabel.
* Mendesain endpoint REST API.
* Menjamin seluruh Functional Requirement dapat diimplementasikan.

---

# 2. Identifikasi Data

Berdasarkan requirement, sistem membutuhkan penyimpanan data berikut.

| Data           | Keterangan                     |
| -------------- | ------------------------------ |
| User           | Data pengguna sistem           |
| Ticket         | Data laporan kerusakan         |
| Comment        | Komentar pada tiket            |
| Status History | Riwayat perubahan status tiket |

---

# 3. Desain Database

## 3.1 Tabel users

| Field      | Tipe     | Keterangan                           |
| ---------- | -------- | ------------------------------------ |
| id         | INTEGER  | Primary Key                          |
| name       | TEXT     | Nama pengguna                        |
| email      | TEXT     | Email                                |
| role       | TEXT     | reporter, admin, technician, manager |
| created_at | DATETIME | Waktu dibuat                         |

---

## 3.2 Tabel tickets

| Field         | Tipe     | Keterangan                                                       |
| ------------- | -------- | ---------------------------------------------------------------- |
| id            | INTEGER  | Primary Key                                                      |
| ticket_number | TEXT     | Nomor tiket unik                                                 |
| title         | TEXT     | Judul                                                            |
| description   | TEXT     | Deskripsi                                                        |
| location      | TEXT     | Lokasi                                                           |
| category      | TEXT     | Kategori                                                         |
| priority      | TEXT     | Low, Medium, High                                                |
| status        | TEXT     | Submitted, Under Review, Assigned, In Progress, Resolved, Closed |
| reporter_id   | INTEGER  | FK ke users                                                      |
| technician_id | INTEGER  | FK ke users (nullable)                                           |
| created_at    | DATETIME | Waktu dibuat                                                     |
| updated_at    | DATETIME | Waktu diperbarui                                                 |

---

## 3.3 Tabel comments

| Field      | Tipe     | Keterangan     |
| ---------- | -------- | -------------- |
| id         | INTEGER  | Primary Key    |
| ticket_id  | INTEGER  | FK ke tickets  |
| user_id    | INTEGER  | FK ke users    |
| comment    | TEXT     | Isi komentar   |
| created_at | DATETIME | Waktu komentar |

---

## 3.4 Tabel status_history

| Field      | Tipe     | Keterangan        |
| ---------- | -------- | ----------------- |
| id         | INTEGER  | Primary Key       |
| ticket_id  | INTEGER  | FK ke tickets     |
| user_id    | INTEGER  | FK ke users       |
| old_status | TEXT     | Status sebelumnya |
| new_status | TEXT     | Status baru       |
| created_at | DATETIME | Waktu perubahan   |

---

# 4. Relasi Database

```
users
│
├────< tickets (reporter_id)
│
├────< tickets (technician_id)
│
├────< comments
│
└────< status_history

tickets
│
├────< comments

└────< status_history
```

---

# 5. Entity Relationship Diagram (ERD)

```
+-------------+
| users       |
+-------------+
| id PK       |
| name        |
| email       |
| role        |
| created_at  |
+-------------+
      |
      | 1
      |
      | N
+-------------+
| tickets     |
+-------------+
| id PK       |
| ticket_no   |
| title       |
| description |
| location    |
| category    |
| priority    |
| status      |
| reporter_id FK
| technician_id FK
| created_at  |
| updated_at  |
+-------------+
     |        |
     |        |
     |        |
     |N       |N
     |        |
+---------+  +----------------+
|comments |  |status_history  |
+---------+  +----------------+
|id PK    |  |id PK           |
|ticket_id|  |ticket_id       |
|user_id  |  |user_id         |
|comment  |  |old_status      |
|created  |  |new_status      |
+---------+  |created_at      |
             +----------------+
```

---

# 6. REST API Design

## Authentication

| Method | Endpoint    | Fungsi         |
| ------ | ----------- | -------------- |
| POST   | /api/login  | Login pengguna |
| POST   | /api/logout | Logout         |

---

## Ticket

| Method | Endpoint          | Fungsi                           |
| ------ | ----------------- | -------------------------------- |
| GET    | /api/tickets      | Daftar tiket                     |
| GET    | /api/tickets/{id} | Detail tiket                     |
| POST   | /api/tickets      | Membuat tiket                    |
| PUT    | /api/tickets/{id} | Mengubah data tiket              |
| DELETE | /api/tickets/{id} | Menghapus tiket (opsional/admin) |

---

## Workflow

| Method | Endpoint                   | Fungsi             |
| ------ | -------------------------- | ------------------ |
| PATCH  | /api/tickets/{id}/status   | Mengubah status    |
| PATCH  | /api/tickets/{id}/assign   | Menugaskan teknisi |
| PATCH  | /api/tickets/{id}/priority | Mengubah prioritas |
| PATCH  | /api/tickets/{id}/category | Mengubah kategori  |

---

## Comment

| Method | Endpoint                   | Fungsi          |
| ------ | -------------------------- | --------------- |
| GET    | /api/tickets/{id}/comments | Daftar komentar |
| POST   | /api/tickets/{id}/comments | Tambah komentar |

---

## Dashboard

| Method | Endpoint       | Fungsi              |
| ------ | -------------- | ------------------- |
| GET    | /api/dashboard | Statistik dashboard |

---

# 7. Contoh Request dan Response

## POST /api/tickets

Request

```json
{
  "title": "AC Rusak",
  "description": "AC tidak menyala",
  "location": "Ruang A101",
  "category": "Elektronik"
}
```

Response

```json
{
  "message": "Ticket berhasil dibuat",
  "ticketNumber": "TKT-0001",
  "status": "Submitted"
}
```

---

## PATCH /api/tickets/{id}/status

Request

```json
{
  "status":"In Progress"
}
```

Response

```json
{
  "message":"Status berhasil diperbarui"
}
```

---

# 8. Pemetaan API terhadap Requirement

| Requirement | Endpoint          |
| ----------- | ----------------- |
| FR-01       | POST /tickets     |
| FR-05       | GET /tickets      |
| FR-06       | GET /tickets/{id} |
| FR-09       | PATCH /status     |
| FR-10       | PATCH /category   |
| FR-11       | PATCH /priority   |
| FR-12       | PATCH /assign     |
| FR-13       | PATCH /status     |
| FR-14       | PATCH /status     |
| FR-15       | PATCH /status     |
| FR-18       | POST /comments    |
| FR-19       | GET /comments     |
| FR-22       | GET /dashboard    |

---

# 9. Quality Check

| Pemeriksaan                                   | Status |
| --------------------------------------------- | ------ |
| Semua tabel memiliki Primary Key              | ✅      |
| Foreign Key digunakan                         | ✅      |
| Seluruh requirement memiliki penyimpanan data | ✅      |
| Endpoint mengikuti REST API                   | ✅      |
| Relasi database benar                         | ✅      |

---

# 10. Kesimpulan

Desain database terdiri dari empat tabel utama yaitu **users**, **tickets**, **comments**, dan **status_history**. Seluruh relasi telah menggunakan Primary Key dan Foreign Key sesuai kebutuhan sistem. REST API dirancang mengikuti prinsip RESTful sehingga dapat mendukung seluruh Functional Requirement yang telah didefinisikan pada tahap Requirements Engineering.
