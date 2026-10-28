CREATE SCHEMA IF NOT EXISTS SALAM;

CREATE TABLE SALAM.prodi (
    kode_prodi CHAR(3) PRIMARY KEY,
    nama_prodi VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE SALAM.mahasiswas (
    id SERIAL PRIMARY KEY,
    nim VARCHAR(15)  NOT NULL UNIQUE,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE CHECK (email LIKE '%@%'),
    ipk NUMERIC(3,2) CHECK (ipk BETWEEN 0 AND 4),
    angkatan INT CHECK (angkatan >= 2000),
    kode_prodi CHAR(3) REFERENCES SALAM.prodi(kode_prodi),
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_mahasiswas_angkatan ON SALAM.mahasiswas(angkatan);

INSERT INTO SALAM.prodi VALUES ('TIF', 'Teknik Informatika'), ('SIF', 'Sistem Informasi');
