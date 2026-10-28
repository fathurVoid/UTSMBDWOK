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