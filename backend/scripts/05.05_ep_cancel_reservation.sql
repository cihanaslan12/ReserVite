/* Fonction qui annule une réservation */

drop function if exists cancel_reservation();

create or replace function cancel_reservation(res_id int)
returns void as
$$
begin
    update reservations
    set status = 'cancelled'
    where id = res_id;
end;
$$ language plpgsql;

grant execute on function cancel_reservation(int) to anon, authenticated;