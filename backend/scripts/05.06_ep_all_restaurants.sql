/* Fonction qui récupère tous les restaurants de la db */

drop function if exists get_all_restaurants();

create or replace function get_all_restaurants()
    returns table (
        id int,
        restaurant_name text,
        address text,
        city text,
        rating double precision,
        price_range int,
        description text,
        services json,
        last_reservation timestamp,
        in_pending int
    ) as
$$
begin
    perform auth.check_logged();
    return query
    select
        rest.id,
        rest.name::text as restaurant_name,
        rest.address::text as address,
        rest.city::text as city,
        rest.rating,
        rest.price_range,
        rest.description,
        coalesce((select json_agg(json_build_object(
                                          'day_of_week', s.day_of_week,
                                          'start_time', to_char(s.start_time, 'HH24:MI'),
                                          'end_time', to_char(s.end_time, 'HH24:MI')
                                  ) order by s.day_of_week, s.start_time)
                  from services s
                  where s.restaurant = rest.id), '[]'::json
        ) as services,
        max(res.datetime) as last_reservation,
        count(case when res.status = 'pending' then 1 end)::int as in_pending
    from restaurants rest
        left join reservations res on res.restaurant = rest.id and res.client = auth.id()
    group by rest.id, rest.name,rest.address, rest.city, rest.rating, rest.price_range, rest.description
    order by rest.name asc;
end;
$$ language plpgsql security definer;

grant execute on function get_all_restaurants() to anon, authenticated;