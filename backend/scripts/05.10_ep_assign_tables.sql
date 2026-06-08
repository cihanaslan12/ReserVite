/* Fonction qui fourni les tables dispo du service */

drop function if exists get_tables_for_assign(int);

create or replace function get_tables_for_assign(res_id int)
    returns table (
        id int,
        name text,
        capacity int,
        is_occupied boolean
    ) as
$$
declare
    v_restaurant_id int;
    v_res_datetime timestamp;
begin
    select restaurant, datetime into v_restaurant_id, v_res_datetime
    from reservations
    where reservations.id = res_id;

    if v_restaurant_id is null then
        return;
    end if;

    return query
    select
        t.id::int,
        ('Table ' || t.table_number)::text as name,
        t.capacity::int,
        exists(
            select 1
            from reservation_tables rt
                join reservations r on r.id = rt.reservation
            where rt.table = t.id
                and r.datetime = v_res_datetime
                and r.status <> 'cancelled'
                and r.id <> res_id
        ) as is_occupied
    from tables t
        where t.restaurant = v_restaurant_id
        order by t.table_number asc;
end;
$$ language plpgsql security definer;

grant execute on function get_tables_for_assign(int) to anon, authenticated;