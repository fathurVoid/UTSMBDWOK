-- A. Transaksi + SAVEPOINT
BEGIN;
  INSERT INTO SALAM.mahasiswas (nim, nama, ipk, angkatan, kode_prodi)
  VALUES ('2024001', 'Farid', 3.80, 2024, 'TIF');
  SAVEPOINT sp1;
  INSERT INTO SALAM.mahasiswas (nim, nama, ipk, angkatan, kode_prodi)
  VALUES ('2024002', 'Salah', 9.99, 2024, 'TIF');
  ROLLBACK TO sp1;
COMMIT;

-- B. Atomicity
BEGIN;
  UPDATE SALAM.mahasiswas SET ipk = 4.00 WHERE nim = '2024001';
ROLLBACK;
SELECT nim, ipk FROM SALAM.mahasiswas;

-- C. Foreign key (gagal)
INSERT INTO SALAM.mahasiswas (nim, nama, kode_prodi) VALUES ('X1', 'Tes', 'ZZZ');

-- D. Audit log
SET ROLE backend_dev;
UPDATE SALAM.mahasiswas SET ipk = 3.90 WHERE nim = '2024001';
RESET ROLE;
SELECT tabel, aksi, oleh, data_lama->>'ipk' AS ipk_lama, data_baru->>'ipk' AS ipk_baru, waktu
FROM SALAM.audit_log ORDER BY id;

-- E. bi_dev read-only
SET ROLE bi_dev;
SELECT * FROM SALAM.v_statistik_angkatan;
DELETE FROM SALAM.mahasiswas;
RESET ROLE;

-- F. backend_dev tidak bisa baca audit_log
SET ROLE backend_dev;
SELECT * FROM SALAM.audit_log;
RESET ROLE;

-- G. data_engineer: CREATE, ALTER, DROP
SET ROLE data_engineer;
CREATE TABLE SALAM.tes (id INT);
ALTER TABLE SALAM.tes ADD COLUMN nama TEXT;
DROP TABLE SALAM.tes;
RESET ROLE;
