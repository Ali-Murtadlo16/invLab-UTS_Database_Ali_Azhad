import getpass
import sys
import pymysql
from tabulate import tabulate

def connect_db(password):
    return pymysql.connect(
        host='localhost',
        user='root',
        password=password,
        database='invLab',
        cursorclass=pymysql.cursors.DictCursor
    )

def cetak_tabel(rows):
    if rows:
        print("\n" + tabulate(rows, headers="keys", tablefmt="psql"))
    else:
        print("\n[!] Data kosong / tidak ditemukan.")

def tampilkan_laporan(conn, filter_kondisi='SEMUA'):
    with conn.cursor() as cursor:
        cursor.callproc('sp_laporan_inventaris', (filter_kondisi,))
        cetak_tabel(cursor.fetchall())

def lihat_data_pendukung(conn, jenis):
    queries = {
        'ruangan': "SELECT id_ruangan, kode_ruangan, nama_ruangan FROM ruangan ORDER BY id_ruangan",
        'kategori': "SELECT id_kategori, nama_kategori FROM kategori ORDER BY id_kategori",
        'user': "SELECT id_user, nama, role, kode_ruangan FROM user ORDER BY id_user",
        'perawatan': """
            SELECT p.id_perawatan, k.kode_aset, k.nama_perangkat, p.tanggal, p.jenis_perawatan, p.biaya, u.nama AS petugas
            FROM perawatan p
            JOIN komputer k ON p.id_komputer = k.id_komputer
            JOIN user u ON p.id_user = u.id_user
            ORDER BY p.id_perawatan DESC
        """,
        'mutasi': """
            SELECT m.id_mutasi, k.kode_aset, r_asal.nama_ruangan AS dari_ruang, r_tujuan.nama_ruangan AS ke_ruang,
                   m.tanggal_mutasi, m.catatan, u.nama AS petugas
            FROM mutasi_komputer m
            JOIN komputer k ON m.id_komputer = k.id_komputer
            JOIN ruangan r_asal ON m.id_ruangan_asal = r_asal.id_ruangan
            JOIN ruangan r_tujuan ON m.id_ruangan_tujuan = r_tujuan.id_ruangan
            JOIN user u ON m.id_user = u.id_user
            ORDER BY m.id_mutasi DESC
        """
    }
    with conn.cursor() as cursor:
        cursor.execute(queries[jenis])
        cetak_tabel(cursor.fetchall())

def tambah_komputer(conn):
    print("\n--- TAMBAH ASET KOMPUTER BARU (sp_tambah_komputer) ---")
    try:
        kode = input("Kode Aset (contoh: KOMP-021): ").strip()
        nama = input("Nama Perangkat: ").strip()
        merek = input("Merek: ").strip()
        model = input("Model: ").strip()
        sn = input("Nomor Seri: ").strip()
        id_kat = int(input("ID Kategori (1-20): ").strip())
        id_ruang = int(input("ID Ruangan (1=Lab DS 121, 2=Lab RPL 329, 3=Lab AI 328, dst): ").strip())
        tgl = input("Tanggal Pengadaan (YYYY-MM-DD): ").strip()
        kondisi = input("Kondisi (baik/perlu_perbaikan/rusak/dihapus): ").strip()
        catatan = input("Catatan: ").strip()

        with conn.cursor() as cursor:
            cursor.callproc('sp_tambah_komputer', (
                kode, nama, merek, model, sn, id_kat, id_ruang, tgl, kondisi, catatan
            ))
        conn.commit()
        print("[✓] Sukses: Data komputer berhasil ditambahkan!")
    except ValueError:
        print("[✗] Input ID harus berupa angka!")
    except pymysql.MySQLError as e:
        print(f"[✗] Error Database: {e.args[1]}")

def ubah_kondisi(conn):
    print("\n--- UBAH KONDISI KOMPUTER (sp_ubah_kondisi_komputer) ---")
    try:
        id_komp = int(input("ID Komputer (contoh: 11-30): ").strip())
        kondisi = input("Kondisi Baru (baik/perlu_perbaikan/rusak/dihapus): ").strip()
        catatan = input("Catatan Kondisi: ").strip()

        with conn.cursor() as cursor:
            cursor.callproc('sp_ubah_kondisi_komputer', (id_komp, kondisi, catatan))
        conn.commit()
        print("[✓] Sukses: Kondisi komputer berhasil diperbarui!")
    except ValueError:
        print("[✗] Input ID harus berupa angka!")
    except pymysql.MySQLError as e:
        print(f"[✗] Error Database: {e.args[1]}")

def catat_perawatan(conn):
    print("\n--- CATAT PERAWATAN KOMPUTER (sp_catat_perawatan) ---")
    try:
        id_komp = int(input("ID Komputer (11-30): ").strip())
        tgl = input("Tanggal Perawatan (YYYY-MM-DD): ").strip()
        jenis = input("Jenis Perawatan: ").strip()
        biaya = float(input("Biaya Perawatan (contoh: 50000): ").strip())
        catatan = input("Catatan: ").strip()
        id_user = int(input("ID User/Laboran (1-20): ").strip())

        with conn.cursor() as cursor:
            cursor.callproc('sp_catat_perawatan', (id_komp, tgl, jenis, biaya, catatan, id_user))
        conn.commit()
        print("[✓] Sukses: Riwayat perawatan berhasil disimpan!")
    except ValueError:
        print("[✗] Input ID/Biaya harus berupa angka!")
    except pymysql.MySQLError as e:
        print(f"[✗] Error Database: {e.args[1]}")

def pindah_komputer(conn):
    print("\n--- MUTASI / PINDAH RUANGAN KOMPUTER (sp_pindah_komputer) ---")
    try:
        id_komp = int(input("ID Komputer yang dipindah (11-30): ").strip())
        id_tujuan = int(input("ID Ruangan Tujuan (1=Lab DS, 2=Lab RPL, 3=Lab AI, dst): ").strip())
        id_user = int(input("ID User/Laboran Penanggung Jawab (1-20): ").strip())
        catatan = input("Alasan / Catatan Pemindahan: ").strip()

        with conn.cursor() as cursor:
            cursor.callproc('sp_pindah_komputer', (id_komp, id_tujuan, id_user, catatan))
        conn.commit()
        print("[✓] Sukses: Lokasi diperbarui & riwayat mutasi tercatat dalam 1 transaksi!")
    except ValueError:
        print("[✗] Input ID harus berupa angka!")
    except pymysql.MySQLError as e:
        print(f"[✗] Error Transaksi: {e.args[1]}")

def main():
    print("==========================================================")
    print("  SISTEM INVENTARIS LAB TI UNIDA GONTOR (invLab) - CLI    ")
    print("==========================================================")
    db_pass = getpass.getpass("Masukkan Password root MariaDB: ")

    try:
        conn = connect_db(db_pass)
        print("[✓] Terhubung ke MariaDB (Database: invLab)")
    except pymysql.MySQLError as e:
        print(f"[✗] Gagal terhubung ke MariaDB: {e}")
        sys.exit(1)

    while True:
        print("\n================ MENU UTAMA INVLAB CLI ===================")
        print("1. Lihat Semua Inventaris Komputer   (sp_laporan_inventaris)")
        print("2. Filter Inventaris per Kondisi     (sp_laporan_inventaris)")
        print("3. Tambah Aset Komputer Baru         (sp_tambah_komputer)")
        print("4. Ubah Kondisi Komputer             (sp_ubah_kondisi_komputer)")
        print("5. Catat Perawatan Komputer          (sp_catat_perawatan)")
        print("6. Pindah / Mutasi Ruangan Komputer  (sp_pindah_komputer)")
        print("----------------------------------------------------------")
        print("7. Lihat Daftar Ruangan, Kategori & User (Referensi ID)")
        print("8. Lihat Tabel Riwayat Perawatan & Mutasi")
        print("0. Keluar")
        print("==========================================================")

        pilihan = input("Pilih menu [0-8]: ").strip()

        if pilihan == '1':
            tampilkan_laporan(conn, 'SEMUA')
        elif pilihan == '2':
            kond = input("Masukkan kondisi (baik/perlu_perbaikan/rusak/dihapus): ").strip()
            tampilkan_laporan(conn, kond)
        elif pilihan == '3':
            tambah_komputer(conn)
        elif pilihan == '4':
            ubah_kondisi(conn)
        elif pilihan == '5':
            catat_perawatan(conn)
        elif pilihan == '6':
            pindah_komputer(conn)
        elif pilihan == '7':
            print("\n--- DAFTAR RUANGAN ---")
            lihat_data_pendukung(conn, 'ruangan')
            print("\n--- DAFTAR KATEGORI ---")
            lihat_data_pendukung(conn, 'kategori')
            print("\n--- DAFTAR USER / LABORAN ---")
            lihat_data_pendukung(conn, 'user')
        elif pilihan == '8':
            print("\n--- RIWAYAT PERAWATAN ---")
            lihat_data_pendukung(conn, 'perawatan')
            print("\n--- RIWAYAT MUTASI KOMPUTER ---")
            lihat_data_pendukung(conn, 'mutasi')
        elif pilihan == '0':
            print("Menutup koneksi database. Wassalamualaikum!")
            conn.close()
            break
        else:
            print("[!] Pilihan tidak valid, silakan masukkan angka 0-8.")

if __name__ == '__main__':
    main()