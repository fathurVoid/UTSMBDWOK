CREATE TABLE SALAM.audit_log (
    id BIGSERIAL PRIMARY KEY,
    tabel TEXT,
    aksi TEXT,
    data_lama JSONB,
    data_baru JSONB,
    oleh TEXT DEFAULT current_user,
    waktu TIMESTAMPTZ DEFAULT now()
);

CREATE FUNCTION SALAM.fn_audit() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = SALAM, pg_temp AS $$
BEGIN
  INSERT INTO SALAM.audit_log(tabel, aksi, data_lama, data_baru, oleh)
  VALUES (TG_TABLE_NAME, TG_OP,
          CASE WHEN TG_OP IN ('UPDATE','DELETE') THEN to_jsonb(OLD) END,
          CASE WHEN TG_OP IN ('INSERT','UPDATE') THEN to_jsonb(NEW) END,
          session_user);
  RETURN COALESCE(NEW, OLD);
END; $$;

CREATE TRIGGER trg_audit_mahasiswas
AFTER INSERT OR UPDATE OR DELETE ON SALAM.mahasiswas
FOR EACH ROW EXECUTE FUNCTION SALAM.fn_audit();

CREATE VIEW SALAM.v_statistik_angkatan AS
SELECT angkatan,
       COUNT(*) AS jumlah_mahasiswa,
       ROUND(AVG(ipk), 2) AS rata_rata_ipk,
       MAX(ipk) AS ipk_tertinggi
FROM SALAM.mahasiswas
GROUP BY angkatan;
