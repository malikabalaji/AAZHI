-- AAZHI store: Supabase schema for favourites + orders.
-- Run this once in your Supabase SQL Editor (Dashboard -> SQL Editor -> New query).

-- ============================================================
-- FAVOURITES: one row per (user, product) pair.
-- product_id matches the numeric `id` in the P[] array in aazhi-store.html.
-- ============================================================
create table if not exists public.favourites (
  user_id    uuid        not null references auth.users(id) on delete cascade,
  product_id integer     not null,
  created_at timestamptz not null default now(),
  primary key (user_id, product_id)
);

alter table public.favourites enable row level security;

drop policy if exists "favourites: owner can read"   on public.favourites;
drop policy if exists "favourites: owner can insert" on public.favourites;
drop policy if exists "favourites: owner can delete" on public.favourites;

create policy "favourites: owner can read"
  on public.favourites for select
  using (auth.uid() = user_id);

create policy "favourites: owner can insert"
  on public.favourites for insert
  with check (auth.uid() = user_id);

create policy "favourites: owner can delete"
  on public.favourites for delete
  using (auth.uid() = user_id);

-- ============================================================
-- ORDERS: one row per completed checkout.
-- Items are stored as JSON so the schema doesn't break when the
-- product catalog changes. Shipping fields mirror the checkout form.
-- ============================================================
create table if not exists public.orders (
  id           uuid        primary key default gen_random_uuid(),
  user_id      uuid        not null references auth.users(id) on delete cascade,
  order_code   text        not null,
  items        jsonb       not null,
  total        integer     not null,
  full_name    text,
  email        text,
  phone        text,
  address      text,
  city         text,
  pincode      text,
  country      text,
  created_at   timestamptz not null default now()
);

create index if not exists orders_user_created_idx
  on public.orders (user_id, created_at desc);

alter table public.orders enable row level security;

drop policy if exists "orders: owner can read"   on public.orders;
drop policy if exists "orders: owner can insert" on public.orders;

create policy "orders: owner can read"
  on public.orders for select
  using (auth.uid() = user_id);

create policy "orders: owner can insert"
  on public.orders for insert
  with check (auth.uid() = user_id);
