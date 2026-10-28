-- Editable public-facing company data. Reads and writes go through the Dart
-- Frog API so only its service role can reach this table; admin writes are
-- guarded by a verified Supabase access token and the profile role.
create table public.site_content (
  id         text primary key check (id = 'main'),
  content    jsonb not null check (jsonb_typeof(content) = 'object'),
  updated_at timestamptz not null default now()
);

alter table public.site_content enable row level security;
revoke all on public.site_content from anon, authenticated;
grant select, insert, update on public.site_content to service_role;

create trigger site_content_set_updated_at
  before update on public.site_content
  for each row execute function public.set_updated_at();
