/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.20-12.3.3-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: invLab
-- ------------------------------------------------------
-- Server version	12.3.3-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `kategori`
--

DROP TABLE IF EXISTS `kategori`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `kategori` (
  `id_kategori` int(11) NOT NULL AUTO_INCREMENT,
  `nama_kategori` varchar(100) NOT NULL,
  PRIMARY KEY (`id_kategori`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kategori`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `kategori` WRITE;
/*!40000 ALTER TABLE `kategori` DISABLE KEYS */;
INSERT INTO `kategori` VALUES
(1,'PC Desktop'),
(2,'Laptop');
/*!40000 ALTER TABLE `kategori` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `komputer`
--

DROP TABLE IF EXISTS `komputer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `komputer` (
  `id_komputer` int(11) NOT NULL AUTO_INCREMENT,
  `kode_aset` varchar(50) NOT NULL,
  `nama_perangkat` varchar(100) NOT NULL,
  `merek` varchar(50) DEFAULT NULL,
  `model` varchar(50) DEFAULT NULL,
  `nomor_seri` varchar(100) DEFAULT NULL,
  `id_kategori` int(11) DEFAULT NULL,
  `id_ruangan` int(11) DEFAULT NULL,
  `tanggal_pengadaan` date DEFAULT NULL,
  `kondisi` enum('baik','perlu_perbaikan','rusak','dihapus') DEFAULT 'baik',
  `catatan` text DEFAULT NULL,
  PRIMARY KEY (`id_komputer`),
  UNIQUE KEY `kode_aset` (`kode_aset`),
  KEY `id_kategori` (`id_kategori`),
  KEY `id_ruangan` (`id_ruangan`),
  CONSTRAINT `1` FOREIGN KEY (`id_kategori`) REFERENCES `kategori` (`id_kategori`),
  CONSTRAINT `2` FOREIGN KEY (`id_ruangan`) REFERENCES `ruangan` (`id_ruangan`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `komputer`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `komputer` WRITE;
/*!40000 ALTER TABLE `komputer` DISABLE KEYS */;
INSERT INTO `komputer` VALUES
(11,'KOMP-001','PC Core i7','Lenovo','ThinkCentre','SN12345',1,1,'2026-10-01','baik','Unit utama'),
(12,'KOMP-002','PC Core i7','Lenovo','ThinkCentre','SN12346',1,1,'2026-10-01','baik','Unit kedua'),
(13,'KOMP-003','PC Core i5','Dell','OptiPlex','SN12347',1,1,'2026-10-02','baik','Unit ketiga'),
(14,'KOMP-004','PC Core i5','Dell','OptiPlex','SN12348',1,1,'2026-10-02','perlu_perbaikan','Kabel longgar'),
(15,'KOMP-005','PC Ryzen 5','HP','ProDesk','SN12349',1,1,'2026-10-03','baik','Unit kelima'),
(16,'KOMP-006','PC Ryzen 5','HP','ProDesk','SN12350',1,1,'2026-10-03','rusak','Mati total'),
(17,'KOMP-007','PC Core i3','Acer','Veriton','SN12351',1,1,'2026-10-04','baik','Unit ketujuh'),
(18,'KOMP-008','PC Core i3','Acer','Veriton','SN12352',1,1,'2026-10-04','baik','Unit kedelapan'),
(19,'KOMP-009','Laptop i5','Asus','ExpertBook','SN12353',2,1,'2026-10-05','baik','Laptop lab'),
(20,'KOMP-010','Laptop i7','Lenovo','ThinkPad','SN12354',2,1,'2026-10-05','baik','Laptop instruktur');
/*!40000 ALTER TABLE `komputer` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mutasi_komputer`
--

DROP TABLE IF EXISTS `mutasi_komputer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mutasi_komputer` (
  `id_mutasi` int(11) NOT NULL AUTO_INCREMENT,
  `id_komputer` int(11) DEFAULT NULL,
  `id_ruangan_asal` int(11) DEFAULT NULL,
  `id_ruangan_tujuan` int(11) DEFAULT NULL,
  `tanggal_mutasi` datetime DEFAULT NULL,
  `catatan` text DEFAULT NULL,
  `id_user` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_mutasi`),
  KEY `id_komputer` (`id_komputer`),
  KEY `id_ruangan_asal` (`id_ruangan_asal`),
  KEY `id_ruangan_tujuan` (`id_ruangan_tujuan`),
  KEY `id_user` (`id_user`),
  CONSTRAINT `1` FOREIGN KEY (`id_komputer`) REFERENCES `komputer` (`id_komputer`),
  CONSTRAINT `2` FOREIGN KEY (`id_ruangan_asal`) REFERENCES `ruangan` (`id_ruangan`),
  CONSTRAINT `3` FOREIGN KEY (`id_ruangan_tujuan`) REFERENCES `ruangan` (`id_ruangan`),
  CONSTRAINT `4` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mutasi_komputer`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mutasi_komputer` WRITE;
/*!40000 ALTER TABLE `mutasi_komputer` DISABLE KEYS */;
/*!40000 ALTER TABLE `mutasi_komputer` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `perawatan`
--

DROP TABLE IF EXISTS `perawatan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `perawatan` (
  `id_perawatan` int(11) NOT NULL AUTO_INCREMENT,
  `id_komputer` int(11) DEFAULT NULL,
  `tanggal` date DEFAULT NULL,
  `jenis_perawatan` varchar(100) DEFAULT NULL,
  `biaya` decimal(10,2) DEFAULT NULL,
  `catatan` text DEFAULT NULL,
  `id_user` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_perawatan`),
  KEY `id_komputer` (`id_komputer`),
  KEY `id_user` (`id_user`),
  CONSTRAINT `1` FOREIGN KEY (`id_komputer`) REFERENCES `komputer` (`id_komputer`),
  CONSTRAINT `2` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `perawatan`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `perawatan` WRITE;
/*!40000 ALTER TABLE `perawatan` DISABLE KEYS */;
/*!40000 ALTER TABLE `perawatan` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ruangan`
--

DROP TABLE IF EXISTS `ruangan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ruangan` (
  `id_ruangan` int(11) NOT NULL AUTO_INCREMENT,
  `kode_ruangan` varchar(20) NOT NULL,
  `nama_ruangan` varchar(100) NOT NULL,
  PRIMARY KEY (`id_ruangan`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ruangan`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ruangan` WRITE;
/*!40000 ALTER TABLE `ruangan` DISABLE KEYS */;
INSERT INTO `ruangan` VALUES
(1,'LAB-01','Laboratorium Jaringan');
/*!40000 ALTER TABLE `ruangan` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id_user` int(11) NOT NULL AUTO_INCREMENT,
  `kode_ruangan` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `role` enum('admin','laboran') NOT NULL,
  PRIMARY KEY (`id_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Dumping routines for database 'invLab'
--
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tambah_komputer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tambah_komputer`(
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
END
;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-11-05 14:35:31
