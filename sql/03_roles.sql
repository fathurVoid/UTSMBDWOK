-- 1. Buat role (kalau sudah ada, hanya update password)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'backend_dev') THEN
    CREATE ROLE backend_dev LOGIN PASSWORD 'backend123';
  ELSE
    ALTER ROLE backend_dev LOGIN PASSWORD 'backend123';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'bi_dev') THEN
    CREATE ROLE bi_dev LOGIN PASSWORD 'bi123';
  ELSE
    ALTER ROLE bi_dev LOGIN PASSWORD 'bi123';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'data_engineer') THEN
    CREATE ROLE data_engineer LOGIN PASSWORD 'de123';
  ELSE
    ALTER ROLE data_engineer LOGIN PASSWORD 'de123';
  END IF;
END $$;

-- 2. Hak koneksi dan akses schema
GRANT CONNECT ON DATABASE postgres TO backend_dev, bi_dev, data_engineer;
GRANT USAGE ON SCHEMA salam TO backend_dev, bi_dev;

-- 3a. backend_dev: CRUD semua table
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA salam TO backend_dev;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA salam TO backend_dev;

-- 3b. bi_dev: hanya read/select table dan view
GRANT SELECT ON ALL TABLES IN SCHEMA salam TO bi_dev;

-- 3c. data_engineer: CREATE, MODIFY, DROP semua object + CRUD semua table
ALTER SCHEMA salam OWNER TO data_engineer;

DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT tablename FROM pg_tables WHERE schemaname = 'salam' LOOP
    EXECUTE format('ALTER TABLE salam.%I OWNER TO data_engineer', r.tablename);
  END LOOP;
  FOR r IN SELECT viewname FROM pg_views WHERE schemaname = 'salam' LOOP
    EXECUTE format('ALTER VIEW salam.%I OWNER TO data_engineer', r.viewname);
  END LOOP;
  FOR r IN SELECT sequencename FROM pg_sequences WHERE schemaname = 'salam' LOOP
    EXECUTE format('ALTER SEQUENCE salam.%I OWNER TO data_engineer', r.sequencename);
  END LOOP;
END $$;

ALTER FUNCTION salam.fn_audit() OWNER TO data_engineer;

-- 4. Object baru yang dibuat data_engineer otomatis bisa diakses role lain
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA salam
  GRANT SELECT ON TABLES TO bi_dev;
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA salam
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO backend_dev;
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA salam
  GRANT USAGE, SELECT ON SEQUENCES TO backend_dev;