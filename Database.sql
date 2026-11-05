-- 1. Buat Database
CREATE DATABASE IF NOT EXISTS invLab;
USE invLab;

-- 2. Buat Tabel Master & Transaksi
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

-- 3. Buat Stored Procedure untuk Tambah Komputer + Validasi Duplikat
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