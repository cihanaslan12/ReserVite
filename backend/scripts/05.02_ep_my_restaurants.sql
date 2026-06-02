/* Fonction qui récupère les restaurants du manager connecté */

drop function if exists get_my_restaurants();

create or replace function get_my_restaurants()
    returns table (
        id int,
        restaurant_name text,
        address text,
        city text,
        rating double precision,
        price_range int,
        description text,
        last_reservation timestamp,
        in_pending int,
        services json
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
        rest.price_range as price_range,
        rest.description,
        (select max(res.datetime) from reservations res where res.restaurant = rest.id) as last_reservation,
        (select count(*) from reservations res where res.restaurant = rest.id and res.status = 'pending') as in_pending,
        coalesce((select json_agg(json_build_object(
                                          'day_of_week', s.day_of_week,
                                          'start_time', to_char(s.start_time, 'HH24:MI'),
                                          'end_time', to_char(s.end_time, 'HH24:MI')
                                  ) order by s.day_of_week, s.start_time)
                  from services s
                  where s.restaurant = rest.id), '[]'::json
        ) as services
    from restaurants rest
        join restaurant_managers rm on rm.restaurant = rest.id
    where rm.manager = auth.id()
    order by
        (select max(res.datetime)
          from reservations res
          where res.restaurant = rest.id) desc,
        rest.name::text asc;
    end;
    $$ language plpgsql security definer;

grant execute on function get_my_restaurants() to anon, authenticated;