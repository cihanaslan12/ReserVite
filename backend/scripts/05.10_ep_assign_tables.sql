/* Fonction qui fourni les tables dispo du service */

drop function if exists get_tables_for_assign(int);

create or replace function get_tables_for_assign(res_id int)
    returns table (
        id int,
        name text,
        capacity int,
        is_available boolean
    ) as
$$
declare
    restaurant_id int;
    res_datetime timestamp;
begin
    select restaurant, reservations.datetime into restaurant_id, res_datetime
    from reservations
    where reservations.id = res_id;

    return query
    select
        t.id,
        t.name::text,
        t.capacity,
        exists(
            select 1
            from reservation_tables rt
                join reservations r on r.id = rt.reservation
            where rt.table = t.id
                and r.datetime = res_datetime
                and r.status <> 'cancelled'
                and r.id <> res_id
        ) as is_available
    from tables t
    where t.restaurant = restaurant_id
    order by t.name asc;
end;
$$ language plpgsql security definer;

grant execute on function get_tables_for_assign(int) to anon, authenticated;