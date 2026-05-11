create table public.activity_logs (
  id uuid not null default gen_random_uuid (),
  resident_id uuid null,
  source_type public.ingestion_source not null,
  daily_steps integer not null default 0,
  weekly_exercise_mins integer not null default 0,
  is_synced boolean null default true,
  local_timestamp timestamp without time zone not null,
  server_timestamp timestamp without time zone null default CURRENT_TIMESTAMP,
  walking_mins_weekly integer not null default 0,
  running_mins_weekly integer not null default 0,
  biking_mins_weekly integer not null default 0,
  other_sports_mins_weekly integer not null default 0,
  field_agent_id uuid null,
  constraint activity_logs_pkey primary key (id),
  constraint activity_logs_resident_id_fkey foreign KEY (resident_id) references residents (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_activity_resident on public.activity_logs using btree (resident_id) TABLESPACE pg_default;

create index IF not exists idx_activity_date on public.activity_logs using btree (local_timestamp) TABLESPACE pg_default;


create table public.barangays (
  id serial not null,
  name character varying(100) not null,
  district character varying(50) not null,
  target_population integer null default 0,
  infrastructure_score integer null default 50,
  created_at timestamp without time zone null default CURRENT_TIMESTAMP,
  constraint barangays_pkey primary key (id)
) TABLESPACE pg_default;


create table public.field_agents (
  id serial not null,
  agent_code character varying(20) not null,
  assigned_barangay_id integer null,
  is_active boolean null default true,
  created_at timestamp without time zone null default CURRENT_TIMESTAMP,
  constraint field_agents_pkey primary key (id),
  constraint field_agents_agent_code_key unique (agent_code),
  constraint field_agents_assigned_barangay_id_fkey foreign KEY (assigned_barangay_id) references barangays (id)
) TABLESPACE pg_default;

create table public.residents (
  id uuid not null default gen_random_uuid (),
  barangay_id integer null,
  age_group character varying(20) null,
  primary_source public.ingestion_source not null,
  created_at timestamp without time zone null default CURRENT_TIMESTAMP,
  gender_at_birth public.gender_type null,
  constraint residents_pkey primary key (id),
  constraint residents_barangay_id_fkey foreign KEY (barangay_id) references barangays (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_resident_barangay on public.residents using btree (barangay_id) TABLESPACE pg_default;

create table public.user_roles (
  id uuid not null,
  email text not null,
  role public.app_role not null default 'field_agent'::app_role,
  created_at timestamp with time zone null default now(),
  constraint user_roles_pkey primary key (id),
  constraint user_roles_id_fkey foreign KEY (id) references auth.users (id) on delete CASCADE
) TABLESPACE pg_default;


CREATE TYPE public.app_role AS ENUM ('field_agent', 'researcher');
CREATE TYPE public.gender_type AS ENUM ('Male', 'Female');
CREATE TYPE public.ingestion_source AS ENUM ('HEALTH_CONNECT', 'WEB_PORTAL', 'FIELD_AGENT');