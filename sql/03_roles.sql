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

GRANT CONNECT ON DATABASE postgres TO backend_dev, bi_dev, data_engineer;
GRANT USAGE ON SCHEMA salam TO backend_dev, bi_dev;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA salam TO backend_dev;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA salam TO backend_dev;

GRANT SELECT ON ALL TABLES IN SCHEMA salam TO bi_dev;

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

ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA salam
  GRANT SELECT ON TABLES TO bi_dev;
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA salam
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO backend_dev;
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA salam
  GRANT USAGE, SELECT ON SEQUENCES TO backend_dev;