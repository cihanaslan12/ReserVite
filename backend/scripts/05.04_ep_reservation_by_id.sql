/* Fonction qui récupère une réservation par son id */

drop function if exists get_reservation_by_id();

create or replace function get_reservation_by_id(res_id int)
    returns table(
        id int, restaurant_name text, city text, datetime timestamp, number_of_guests int, status text,
        client_name text, address text, phone text, special_requests text) as
    $$
    begin
        return query
        select res.id, rest.name::text, rest.city::text, res.datetime, res.number_of_guests, res.status::text,
               u.full_name::text, rest.address::text, rest.phone::text, res.special_requests::text
        from reservations res
            join restaurants rest on rest.id = res.restaurant
            join users u on res.client = u.id
        where res.id = res_id;
    end;
    $$ language plpgsql;

grant execute on function get_reservation_by_id(int) to anon, authenticated;