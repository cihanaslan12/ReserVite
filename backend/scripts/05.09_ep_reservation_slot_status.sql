/* Fonction (utilitaire) qui fourni les crénaux */

drop function if exists get_restaurant_slots(int, int);

create or replace function get_restaurant_slots(rest_id int, week_day int)
    returns table (slot_time time) as
$$
declare
    slot_duration int;
    slot_interval interval;
begin
    select rest.slot_duration into slot_duration
    from restaurants rest
    where rest.id = rest_id;

    slot_interval := (slot_duration || ' minutes')::interval;

    return query
        -- on récupère les services du jour
    with day_services as (
        select start_time, end_time
        from services
        where restaurant = rest_id
            and day_of_week = week_day
    )
        -- on génère les séries de créneaux par services du jour
    select s.slot::time
    from day_services ds,
    generate_series(
        '2000-01-01'::date + ds.start_time,
        '2000-01-01'::date + (ds.end_time - slot_interval),
        slot_interval
    ) as s(slot);
end;
$$ language plpgsql security definer;

/* Fonction (utilitaire) qui calcule les places déjà occupées des créneaux */

drop function if exists get_restaurant_reserved_seats(int, date);

create or replace function get_restaurant_reserved_seats(rest_id int, date date)
    returns table (
        res_time time,
        total_reserved int
    ) as
$$
begin
    return query
    select
        res.datetime::time as res_time,
        sum(res.number_of_guests)::int as total_reserved
    from reservations res
    where res.restaurant = rest_id
        and res.datetime::date = date
        and res.status in ('pending', 'confirmed')
    group by res.datetime::time;
end;
$$ language plpgsql security definer;

/* Fonction (principale) qui récupère la capacité en fonction des crénaux */

drop function if exists get_reservation_slot_status(int, date, int);

create or replace function get_reservation_slot_status(rest_id int, date date, nb_of_guests int)
    returns table (
                      slot_time time,
                      is_closed boolean,
                      already_reserved boolean,
                      available_capacity int,
                      is_overbooked boolean) as
$$
declare
    week_day int;
    rest_total_capacity int;
begin
    perform auth.check_logged();

    week_day := extract(isodow from date)::int;

    select coalesce(sum(capacity), 0)::int into rest_total_capacity
    from tables
    where restaurant = rest_id;

    return query
        select
            slots.slot_time as slot_time,
            false as is_closed,
            exists(
                select 1
                from reservations res
                where res.restaurant = rest_id
                  and res.client = auth.id()
                  and res.datetime::date = date
                  and res.status in ('pending', 'confirmed')
            ) as already_reserved,
            (rest_total_capacity - coalesce(seats.total_reserved, 0))::int as available_capacity,
            (nb_of_guests > (rest_total_capacity - coalesce(seats.total_reserved, 0)))::boolean as is_overbooked
        from get_restaurant_slots(rest_id, week_day) slots
                 left join get_restaurant_reserved_seats(rest_id, date) seats
                           on seats.res_time = slots.slot_time
        order by slots.slot_time asc;
end;
$$ language plpgsql security definer;

grant execute on function get_reservation_slot_status(int, date, int) to anon, authenticated;
