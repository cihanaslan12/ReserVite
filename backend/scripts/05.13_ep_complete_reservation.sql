/* Fonction qui termine une réservation */

drop function if exists complete_reservation(int);

create or replace function complete_reservation(res_id int)
    returns void as
$$
begin
    perform auth.check_logged();

    update reservations
    set status = 'completed'
    where id = res_id
        and status = 'confirmed';
    set constraints all immediate;
end;
$$ language plpgsql security definer;

grant execute on function complete_reservation(int) to anon, authenticated;