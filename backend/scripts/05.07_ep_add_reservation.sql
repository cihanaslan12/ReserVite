/* Fonction qui ajoute une réservation */

drop function if exists add_reservation(int, timestamp, int, text);

create or replace function add_reservation(rest_id int, res_time timestamp, nb_of_guests int, spec_requ text)
    returns int as
$$
    declare
        reservation_id int;
begin
    perform auth.check_logged();
    insert into reservations (client, restaurant, datetime, number_of_guests, status, special_requests)
        values (auth.id(), rest_id, res_time, nb_of_guests, 'pending'::status_type,  spec_requ)
        returning id into reservation_id;
    return reservation_id;
end;
$$ language plpgsql security definer;

grant execute on function add_reservation(int, timestamp, int, text) to anon, authenticated;