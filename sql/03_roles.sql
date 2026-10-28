\getenv backend_pw BACKEND_DEV_PASSWORD
\getenv bi_pw      BI_DEV_PASSWORD
\getenv de_pw      DATA_ENGINEER_PASSWORD

SELECT 'CREATE ROLE backend_dev LOGIN'
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'backend_dev') \gexec
SELECT 'CREATE ROLE bi_dev LOGIN'
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'bi_dev') \gexec
SELECT 'CREATE ROLE data_engineer LOGIN'
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'data_engineer') \gexec

ALTER ROLE backend_dev   PASSWORD :'backend_pw';
ALTER ROLE bi_dev        PASSWORD :'bi_pw';
ALTER ROLE data_engineer PASSWORD :'de_pw';

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