drop schema if exists api cascade;
create schema api;
set search_path = api, public;

-- this role will be used as the owner of the views in the api schema
-- it is needed for the definition of the RLS policies
drop role if exists api;
create role api;
grant api to current_user; -- this is a workaround for RDS where the master user does not have SUPERUSER priviliges  

-- redifine this type to control the user properties returned by auth endpoints
\ir ../libs/auth/api/user_type.sql
-- include all auth endpoints
\ir ../libs/auth/api/all.sql

-- our endpoints
\ir todos.sql


create or replace view languages as 
  select * from data.language;

alter view languages owner to api;

create or replace view drill_sections as
  select * from data.drill_section;

alter view drill_sections owner to api;

create or replace view drills as
  select * from data.drill;

alter view drills owner to api;

create function create_recording(
  out recording_id int,
  out presigned_url text
) returns record language plpgsql as $f$
begin
  insert into data.recording default values returning id into recording_id;

  presigned_url := minio.get_presigned_url('recordings'::text, recording_id::text);
end $f$ security definer;
