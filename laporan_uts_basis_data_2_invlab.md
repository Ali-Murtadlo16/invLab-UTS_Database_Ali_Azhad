# LAPORAN UTS BASIS DATA 2: SISTEM INVENTARIS LABORATORIUM (`invLab`)

**Mata Kuliah:** Basis Data 2  
**Proyek:** Sistem Inventaris Komputer Laboratorium (`invLab`)  
**Anggota Kelompok:** 
1. M. Azhad Salim Al-Haqqoni
2. Ahmad Ali Murtadlo Asadillah  
**Institusi:** Universitas Darussalam Gontor  

---

## 1. Pendahuluan
Proyek ini bertujuan untuk merancang dan mengimplementasikan sistem basis data relasional guna mengelola inventaris perangkat komputer di laboratorium komputer. Database ini dinamakan `invLab` dan dibangun menggunakan sistem manajemen basis data MariaDB. Selain struktur tabel relasional, sistem ini juga menerapkan *Stored Procedure* dengan fitur validasi data untuk menjamin integritas aset laboratorium.

---

## 2. Struktur Basis Data & Skrip SQL
Database `invLab` terdiri dari beberapa tabel utama yang saling berelasi:
* `kategori`: Menyimpan data kategori perangkat (misal: PC Desktop, Laptop).
* `ruangan`: Menyimpan data lokasi ruangan laboratorium.
* `user`: Menyimpan data pengguna/admin sistem.
* `komputer`: Menyimpan data aset utama komputer, terhubung ke tabel `kategori` dan `ruangan`.
* `perawatan`: Mencatat riwayat pemeliharaan perangkat.
* `mutasi_komputer`: Mencatat riwayat perpindahan/mutasi perangkat antar ruangan.

Berikut adalah skrip lengkap pembuatan tabel dan *Stored Procedure* `sp_tambah_komputer`:

```sql
CREATE DATABASE IF NOT EXISTS invLab;
USE invLab;

CREATE TABLE kategori (
    id_kategori INT AUTO_INCREMENT PRIMARY KEY,
    nama_kategori VARCHAR(50) NOT NULL
);

CREATE TABLE ruangan (
    id_ruangan INT AUTO_INCREMENT PRIMARY KEY,
    kode_ruangan VARCHAR(20) NOT NULL,
    nama_ruangan VARCHAR(50) NOT NULL
);

CREATE TABLE user (
    id_user INT AUTO_INCREMENT PRIMARY KEY,
    kode_ruangan VARCHAR(50),
    password_hash VARCHAR(255) NOT NULL,
    nama VARCHAR(100) NOT NULL,
    role ENUM('admin', 'petugas') NOT NULL
);

CREATE TABLE komputer (
    id_komputer INT AUTO_INCREMENT PRIMARY KEY,
    kode_aset VARCHAR(50) UNIQUE NOT NULL,
    nama_perangkat VARCHAR(100) NOT NULL,
    merek VARCHAR(50),
    model VARCHAR(50),
    nomor_seri VARCHAR(100),
    id_kategori INT,
    id_ruangan INT,
    tanggal_pengadaan DATE,
    kondisi ENUM('baik', 'perlu_perbaikan', 'rusak', 'dihapus'),
    catatan TEXT,
    FOREIGN KEY (id_kategori) REFERENCES kategori(id_kategori),
    FOREIGN KEY (id_ruangan) REFERENCES ruangan(id_ruangan)
);

CREATE TABLE perawatan (
    id_perawatan INT AUTO_INCREMENT PRIMARY KEY,
    id_komputer INT,
    tanggal DATE,
    jenis_perawatan VARCHAR(100),
    biaya DECIMAL(10, 2),
    catatan TEXT,
    id_user INT,
    FOREIGN KEY (id_komputer) REFERENCES komputer(id_komputer),
    FOREIGN KEY (id_user) REFERENCES user(id_user)
);

CREATE TABLE mutasi_komputer (
    id_mutasi INT AUTO_INCREMENT PRIMARY KEY,
    id_komputer INT,
    id_ruangan_asal INT,
    id_ruangan_tujuan INT,
    tanggal_mutasi DATE,
    alasan TEXT,
    id_user INT,
    FOREIGN KEY (id_komputer) REFERENCES komputer(id_komputer),
    FOREIGN KEY (id_ruangan_tujuan) REFERENCES ruangan(id_ruangan)
);

-- Stored Procedure dengan validasi duplikasi kode aset
DELIMITER //

CREATE PROCEDURE sp_tambah_komputer(
    IN p_kode_aset VARCHAR(50),
    IN p_nama_perangkat VARCHAR(100),
    IN p_merek VARCHAR(50),
    IN p_model VARCHAR(50),
    IN p_nomor_seri VARCHAR(100), 
    IN p_id_kategori INT, 
    IN p_id_ruangan INT, 
    IN p_tanggal_pengadaan DATE, 
    IN p_kondisi ENUM('baik', 'perlu_perbaikan', 'rusak', 'dihapus'), 
    IN p_catatan TEXT
)
BEGIN
    IF EXISTS (SELECT 1 FROM komputer WHERE kode_aset = p_kode_aset) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Gagal: Kode aset komputer sudah terdaftar!';
    ELSE
        INSERT INTO komputer (
            kode_aset, nama_perangkat, merek, model, nomor_seri, 
            id_kategori, id_ruangan, tanggal_pengadaan, kondisi, catatan
        )
        VALUES (
            p_kode_aset, p_nama_perangkat, p_merek, p_model, p_nomor_seri, 
            p_id_kategori, p_id_ruangan, p_tanggal_pengadaan, p_kondisi, p_catatan
        );
    END IF;
END //

DELIMITER ;
```

---

## 3. Log Riwayat Eksekusi Terminal & Pengujian Data
Berikut adalah transkrip asli riwayat perintah yang diketikkan di terminal MariaDB saat pengisian data master dan eksekusi *Stored Procedure* untuk 10 data komputer:

```sql
-- Pengisian Data Master Kategori & Ruangan
MariaDB [invLab]> INSERT INTO kategori (nama_kategori) VALUES ('PC Desktop'), ('Laptop'); 
MariaDB [invLab]> INSERT INTO ruangan (kode_ruangan, nama_ruangan) VALUES ('LAB-01', 'Laboratorium Jaringan');

-- Eksekusi Stored Procedure untuk Memasukkan 10 Data Aset Komputer
MariaDB [invLab]> CALL sp_tambah_komputer('KOMP-001', 'PC Core i7', 'Lenovo', 'ThinkCentre', 'SN12345', 1, 1, '2026-10-01', 'baik', 'Unit utama'); 
MariaDB [invLab]> CALL sp_tambah_komputer('KOMP-002', 'PC Core i7', 'Lenovo', 'ThinkCentre', 'SN12346', 1, 1, '2026-10-01', 'baik', 'Unit kedua'); 
MariaDB [invLab]> CALL sp_tambah_komputer('KOMP-003', 'PC Core i5', 'Dell', 'OptiPlex', 'SN12347', 1, 1, '2026-10-02', 'baik', 'Unit ketiga'); 
MariaDB [invLab]> CALL sp_tambah_komputer('KOMP-004', 'PC Core i5', 'Dell', 'OptiPlex', 'SN12348', 1, 1, '2026-10-02', 'perlu_perbaikan', 'Kabel longgar'); 
MariaDB [invLab]> CALL sp_tambah_komputer('KOMP-005', 'PC Ryzen 5', 'HP', 'ProDesk', 'SN12349', 1, 1, '2026-10-03', 'baik', 'Unit kelima'); 
MariaDB [invLab]> CALL sp_tambah_komputer('KOMP-006', 'PC Ryzen 5', 'HP', 'ProDesk', 'SN12350', 1, 1, '2026-10-03', 'rusak', 'Mati total'); 
MariaDB [invLab]> CALL sp_tambah_komputer('KOMP-007', 'PC Core i3', 'Acer', 'Veriton', 'SN12351', 1, 1, '2026-10-04', 'baik', 'Unit ketujuh'); 
MariaDB [invLab]> CALL sp_tambah_komputer('KOMP-008', 'PC Core i3', 'Acer', 'Veriton', 'SN12352', 1, 1, '2026-10-04', 'baik', 'Unit kedelapan'); 
MariaDB [invLab]> CALL sp_tambah_komputer('KOMP-009', 'Laptop i5', 'Asus', 'ExpertBook', 'SN12353', 2, 1, '2026-10-05', 'baik', 'Laptop lab'); 
MariaDB [invLab]> CALL sp_tambah_komputer('KOMP-010', 'Laptop i7', 'Lenovo', 'ThinkPad', 'SN12354', 2, 1, '2026-10-05', 'baik', 'Laptop instruktur');

-- Menampilkan Seluruh Isi Tabel Komputer
MariaDB [invLab]> SELECT * FROM komputer;
```

Hasil keluaran eksekusi terminal (*Output*):
```text
+-------------+-----------+----------------+--------+-------------+------------+-------------+------------+-------------------+-----------------+-------------------+
| id_komputer | kode_aset | nama_perangkat | merek  | model       | nomor_seri | id_kategori | id_ruangan | tanggal_pengadaan | kondisi         | catatan           |
+-------------+-----------+----------------+--------+-------------+------------+-------------+------------+-------------------+-------------------+-------------------+
|          11 | KOMP-001  | PC Core i7     | Lenovo | ThinkCentre | SN12345    |           1 |          1 | 2026-10-01        | baik            | Unit utama        |
|          12 | KOMP-002  | PC Core i7     | Lenovo | ThinkCentre | SN12346    |           1 |          1 | 2026-10-01        | baik            | Unit kedua        |
|          13 | KOMP-003  | PC Core i5     | Dell   | OptiPlex    | SN12347    |           1 |          1 | 2026-10-02        | baik            | Unit ketiga       |
|          14 | KOMP-004  | PC Core i5     | Dell   | OptiPlex    | SN12348    |           1 |          1 | 2026-10-02        | perlu_perbaikan | Kabel longgar     |
|          15 | KOMP-005  | PC Ryzen 5     | HP     | ProDesk     | SN12349    |           1 |          1 | 2026-10-03        | baik            | Unit kelima       |
|          16 | KOMP-006  | PC Ryzen 5     | HP     | ProDesk     | SN12350    |           1 |          1 | 2026-10-03        | rusak           | Mati total        |
|          17 | KOMP-007  | PC Core i3     | Acer   | Veriton     | SN12351    |           1 |          1 | 2026-10-04        | baik            | Unit ketujuh      |
|          18 | KOMP-008  | PC Core i3     | Acer   | Veriton     | SN12352    |           1 |          1 | 2026-10-04        | baik            | Unit kedelapan    |
|          19 | KOMP-009  | Laptop i5      | Asus   | ExpertBook  | SN12353    |           2 |          1 | 2026-10-05        | baik            | Laptop lab        |
|          20 | KOMP-010  | Laptop i7      | Lenovo | ThinkPad    | SN12354    |           2 |          1 | 2026-10-05        | baik            | Laptop instruktur |
+-------------+-----------+----------------+--------+-------------+------------+-------------+------------+-------------------+-------------------+-------------------+
10 rows in set (0.000 sec)
```

---

## 4. Cara Membuat Salinan (*Backup/Dump*) Database `invLab` Beserta Isinya

Bagi kamu yang ingin membuat salinan fisik dari database `invLab` beserta seluruh struktur tabel dan isinya ke dalam file SQL (misalnya untuk dimasukkan ke repositori GitHub), jalankan perintah berikut langsung di terminal sistem operasi komputer kamu (bukan di dalam prompt MariaDB):

```bash
# Perintah untuk melakukan backup/dump database invLab beserta prosedur dan isinya
mariadb-dump -u root -p invLab > backup_invLab.sql
```

* **Penjelasan perintah:**
  * `mariadb-dump` : Alat utilitas bawaan MariaDB untuk mencadangkan basis data.
  * `-u root -p` : Menggunakan username `root` dan akan diminta memasukkan kata sandi database.
  * `invLab` : Nama database yang ingin disalin.
  * `> backup_invLab.sql` : Mengarahkan hasil salinan ke dalam file baru bernama `backup_invLab.sql`.

File `backup_invLab.sql` tersebut nantinya dapat kamu *commit* dan *push* ke GitHub sebagai bukti autentik file cadangan database proyek UTS kalian!