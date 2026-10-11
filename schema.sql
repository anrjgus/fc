-- Supabase SQL Editor: run once. Add authorized operators in Authentication > Users.
create table if not exists public.operators (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '운영진'
);
create table if not exists public.team_state (
  id integer primary key check (id = 1),
  payload jsonb not null default '{}'::jsonb,
  version bigint not null default 0,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);
insert into public.team_state(id) values(1) on conflict do nothing;
alter table public.operators enable row level security;
alter table public.team_state enable row level security;
revoke all on public.operators from anon, authenticated;
revoke all on public.team_state from anon, authenticated;
grant select on public.operators to authenticated;
grant select on public.team_state to authenticated;
create policy "operators read self" on public.operators for select to authenticated using (user_id=auth.uid());
create policy "operators read team" on public.team_state for select to authenticated using (exists(select 1 from public.operators where user_id=auth.uid()));
create or replace function public.save_team_state(expected_version bigint, new_payload jsonb)
returns bigint language plpgsql security definer set search_path=public as $$
declare v bigint;
begin
 if auth.uid() is null or not exists(select 1 from public.operators where user_id=auth.uid()) then raise exception 'not authorized'; end if;
 update public.team_state set payload=new_payload,version=version+1,updated_at=now(),updated_by=auth.uid()
 where id=1 and version=expected_version returning version into v;
 return v; -- null means stale version; client must reload
end; $$;
revoke all on function public.save_team_state(bigint,jsonb) from public, anon;
grant execute on function public.save_team_state(bigint,jsonb) to authenticated;
-- After inviting operators in Authentication > Users, authorize them using their user UUID:
-- insert into public.operators(user_id,display_name) values('PASTE-USER-UUID','운영진 이름');
