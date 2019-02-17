-- some setting to make the output less verbose
\set QUIET on
\set ON_ERROR_STOP on
set client_min_messages to warning;

-- load some variables from the env
\setenv base_dir :DIR
\set base_dir `if [ $base_dir != ":"DIR ]; then echo $base_dir; else echo "/docker-entrypoint-initdb.d"; fi`
\set anonymous `echo $DB_ANON_ROLE`
\set authenticator `echo $DB_USER`
\set authenticator_pass `echo $DB_PASS`
\set jwt_secret `echo $JWT_SECRET`
\set quoted_jwt_secret '\'' :jwt_secret '\''
\set minio_port `echo $MINIO_PORT`
\set minio_host `echo $MINIO_HOST`
\set minio_access_key `echo $MINIO_ACCESS_KEY`
\set minio_secret_key `echo $MINIO_SECRET_KEY`

\echo # Loading database definition
begin;

create language plpython3u;

\echo # Loading dependencies
-- functions for storing different settins in a table
\ir libs/settings/schema.sql
-- functions implementing authentication (parts of the lib are included in data and api schema)
\ir libs/auth/schema.sql
-- functions for reading different http request properties exposed by PostgREST
\ir libs/request/schema.sql
-- functions for sending messages to RabbitMQ entities
\ir libs/rabbitmq/schema.sql
\ir libs/minio/schema.sql

-- save app settings
select settings.set('jwt_secret', :quoted_jwt_secret);
select settings.set('jwt_lifetime', '3600');
select settings.set('auth.default-role', 'webuser');
select settings.set('minio_port', :'minio_port');
select settings.set('minio_host', :'minio_host');
select settings.set('minio_access_key', :'minio_access_key');
select settings.set('minio_secret_key', :'minio_secret_key');

\echo # Loading application definitions
-- private schema where all tables will be defined
-- you can use othere names besides "data" or even spread the tables
-- between different schemas. The schema name "data" is just a convention
\ir data/schema.sql
-- entities inside this schema (which should be only views and stored procedures) will be 
-- exposed as API endpoints. Access to them however is still governed by the 
-- privileges defined for the current PostgreSQL role making the requests
\ir api/schema.sql


\echo # Loading roles and privilege settings
\ir authorization/roles.sql
\ir authorization/privileges.sql

\echo # Loading sample data
\ir sample_data/data.sql


commit;
\echo # ==========================================
