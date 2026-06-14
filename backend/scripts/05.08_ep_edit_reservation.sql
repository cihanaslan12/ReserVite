/* Fonction qui modifie une réservation */

drop function if exists edit_reservation(int, text, int, text, text);

create or replace function edit_reservation(
    res_id int,
    res_time text,
    nb_of_guests int,
    new_status text,
    spec_requ text
)
    returns void as
$$
begin
    perform auth.check_logged();
    update reservations
    set number_of_guests = nb_of_guests,
        datetime = res_time::timestamp,
        status = new_status::public.status_type,
        special_requests = spec_requ
    where id = res_id;
end;
$$ language plpgsql security definer;

grant execute on function edit_reservation(int, text, int, text, text) to anon, authenticated;