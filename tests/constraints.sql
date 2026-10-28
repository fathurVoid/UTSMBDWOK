-- Berhasil
INSERT INTO SALAM.mahasiswas (nim, nama, email, ipk, angkatan, kode_prodi)
VALUES ('1234567060', 'Farid', 'farid@mail.com', 3.50, 2024, 'TIF');
-- Gagal: UNIQUE
INSERT INTO SALAM.mahasiswas (nim, nama, email, ipk, angkatan)
VALUES ('1234567060', 'Budi', 'budi@mail.com', 3.00, 2024);
-- Gagal: CHECK
INSERT INTO SALAM.mahasiswas (nim, nama, email, ipk, angkatan)
VALUES ('999', 'Ani', 'ani@mail.com', 5.00, 2024);
-- Gagal: PRIMARY KEY
INSERT INTO SALAM.mahasiswas (id, nim, nama, ipk, angkatan)
VALUES (1, '888', 'Cici', 3.00, 2024);
