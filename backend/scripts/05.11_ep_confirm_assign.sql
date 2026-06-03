/* Fonction qui permet de confirmer et assigner */

drop function if exists confirm_and_assign_tables(int, int[]);

create or replace function confirm_and_assign_tables(res_id int, table_ids int[])
    returns void as
$$
declare t_id int;
begin
    update reservations
    set status = 'confirmed'
    where id = res_id;

    delete from reservation_tables where reservation = res_id;

    foreach t_id in array table_ids loop
        insert into reservation_tables (reservation, "table")
        values (res_id, t_id);
        end loop;
end;
$$ language plpgsql security definer;

grant execute on function confirm_and_assign_tables(int, int[]) to anon, authenticated;