/* Fonction qui récupère les réservations d'un restaurant */

drop function if exists get_restaurant_reservations(int);

create or replace function get_restaurant_reservations(restaurant_id int)
    returns table (id int, datetime timestamp, number_of_guests int, status status_type, client_name text) as
$$
begin
    perform auth.check_logged();
    return query
        select res.id, res.datetime, res.number_of_guests, res.status, u.full_name::text as client_name
        from reservations res
                 join users u on u.id = res.client
        where res.restaurant = restaurant_id
        order by res.datetime desc;
end;

$$ language plpgsql security definer;
grant execute on function get_restaurant_reservations(int) to anon, authenticated;