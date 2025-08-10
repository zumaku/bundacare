-- Supabase SQL schema for BundaCare
create extension if not exists "uuid-ossp";

create table public.profiles (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade,
  full_name text,
  avatar_url text,
  pregnancy_start_date date
);

create table public.food_logs (
  id bigserial primary key,
  user_id uuid references auth.users(id) on delete cascade,
  food_name text not null,
  image_url text,
  calories numeric,
  protein numeric,
  fat numeric,
  carbohydrate numeric,
  created_at timestamptz default now()
);

alter table public.profiles enable row level security;
alter table public.food_logs enable row level security;

create policy "profiles_is_owner" on public.profiles
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "food_logs_is_owner" on public.food_logs
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
