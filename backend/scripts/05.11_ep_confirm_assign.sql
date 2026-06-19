/* Fonction qui permet de confirmer et assigner */

drop function if exists confirm_and_assign_tables(int, jsonb);

create or replace function confirm_and_assign_tables(res_id int, table_ids jsonb)
    returns void as
$$
begin
    delete from reservation_tables
    where reservation = res_id;

    insert into reservation_tables (reservation, "table")
    select res_id, value::int
    from jsonb_array_elements_text(table_ids);

    update reservations
    set status = 'confirmed'::status_type
    where id = res_id;

    set constraints all immediate;
end;
$$ language plpgsql security definer;

grant execute on function confirm_and_assign_tables(int, jsonb) to anon, authenticated;