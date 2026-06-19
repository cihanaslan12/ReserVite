/* Fonction qui annule une réservation */

drop function if exists cancel_reservation(int);

create or replace function cancel_reservation(res_id int)
returns void as
$$
declare
    v_status status_type;
begin
    perform auth.check_logged();

    select status into v_status
    from reservations
    where id = res_id;

    if v_status = 'confirmed' then
        delete from reservation_tables
        where reservation = res_id;
    end if;

    update reservations
    set status = 'cancelled'
    where id = res_id
        and status in('pending', 'confirmed');
    set constraints all immediate;
end;
$$ language plpgsql security definer;

grant execute on function cancel_reservation(int) to anon, authenticated;