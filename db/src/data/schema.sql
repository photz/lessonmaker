drop schema if exists data cascade;
create schema data;
set search_path = data, public;

-- import the type specifying the types of users we have (this is an enum).
-- you most certainly will have to redefine this type for your application
\ir ../libs/auth/data/user_role_type.sql

-- import the default table definition for the user model used by the auth lib
-- you can choose to define the "user" table yourself if you need additional columns
\ir ../libs/auth/data/user.sql

-- import our application models
\ir todo.sql


create table "language" (
  code text primary key,
  name text unique not null
);

create table recording (
  id serial primary key,
  created_by int not null references "user" default request.user_id(),
  created_at timestamptz default now() not null
);

create table drill_section (
  id serial primary key,
  name text not null,
  created_at timestamptz default now() not null,
  created_by int not null references "user" default request.user_id(),
  teacher_language text not null references "language" on delete cascade,
  student_language text not null references "language" on delete cascade,
  order_fixed boolean not null default false,
  check (teacher_language <> student_language)
);

create table drill (
  id serial primary key,
  drill_section int not null references drill_section on delete cascade,
  student_text text,
  teacher_text text,
  student_audio int references recording,
  teacher_audio int references recording,
  created_at timestamptz default now() not null,
  created_by int not null references "user" default request.user_id(),
  check (student_text notnull or student_audio notnull),
  check (teacher_text notnull or teacher_audio notnull),
  check (student_audio <> teacher_audio)
);


