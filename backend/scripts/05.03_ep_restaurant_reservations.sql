/* Fonction qui récupère les réservations d'un restaurant */

drop function if exists get_restaurant_reservations(int);

create or replace function get_restaurant_reservations(restaurant_id int)
    returns table (
        id int,
        restaurant_name text,
        city text,
        datetime timestamp,
        number_of_guests int,
        status text,
        client_name text,
        address text,
        restaurant_phone text,
        special_requests text,
        client_phone text,
        client_email text,
        is_vip bool
    ) as
$$
begin
    perform auth.check_logged();
    return query
        select
            res.id,
            rest.name::text as restaurant_name,
            ''::text as city,
            res.datetime,
            res.number_of_guests,
            res.status::text,
            u.full_name::text as client_name,
            ''::text as address,
            ''::text as restaurant_phone,
            res.special_requests::text,
            u.phone::text as client_phone,
            u.email::text as client_email,
            res.is_vip as is_vip
        from reservations res
                 join users u on u.id = res.client
                 join restaurants rest on rest.id = res.restaurant
        where res.restaurant = restaurant_id
        order by res.datetime desc;
end;

$$ language plpgsql security definer;
grant execute on function get_restaurant_reservations(int) to anon, authenticated;