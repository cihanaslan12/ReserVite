/* Fonction qui récupère une réservation par son id */

drop function if exists get_reservation_by_id(int);

create or replace function get_reservation_by_id(res_id int)
    returns table(
        id int,
        restaurant_name text,
        city text,
        datetime timestamp,
        number_of_guests int,
        status text,
        client_name text,
        address text,
        special_requests text,
        restaurant_phone text,
        client_phone text,
        client_email text
    ) as
    $$
    begin
        return query
        select res.id,
               rest.name::text as restaurant_name,
               rest.city::text,
               res.datetime,
               res.number_of_guests,
               res.status::text,
               u.full_name::text as client_name,
               rest.address::text,
               res.special_requests::text,
               rest.phone::text as restaurant_phone,
               u.phone::text as client_phone,
               u.email::text as client_email
        from reservations res
            join restaurants rest on rest.id = res.restaurant
            join users u on res.client = u.id
        where res.id = res_id;
    end;
    $$ language plpgsql;

grant execute on function get_reservation_by_id(int) to anon, authenticated;