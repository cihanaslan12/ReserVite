/* Fonction qui change le mode VIP de la réservation */

drop function if exists toggle_reservation_vip(int);

create or replace function toggle_reservation_vip(
    res_id int
)
    returns void as
$$
begin
    -- user connecté
    if auth.check_logged() is null then
        raise exception 'Veuillez vous connecter';
    end if;

    -- réservation existant
    if not exists(
        select 1
        from reservations
        where id = res_id
        ) then
            raise exception 'La réservation n\''existe pas';
    end if;

    -- user connecté (manager) gère le restaurant de cette réservation
    if not exists(
        select 1
        from reservations res
            join restaurants rest on res.restaurant = rest.id
            join restaurant_managers rm on rest.id = rm.restaurant
        where rm.manager = auth.id()
            and rm.restaurant = res.restaurant
            and res.id = res_id
        ) then
            raise exception 'Vous ne gérez pas ce restaurant.';
    end if;

    -- réservation valide (pending ou confirmed et dans le futur)
    if exists(
        select 1
        from reservations res
        where res.id = res_id
            and (status in ('cancelled', 'completed')
            or res.datetime < timestamp '2024-12-04 16:00:00')
        ) then
            raise exception 'La réservation n\''est pas valide pour changer de mode';
    end if;

    update reservations
    set is_vip = not is_vip
    where id = res_id;
end;
$$ language plpgsql security definer;

grant execute on function toggle_reservation_vip(int) to anon, authenticated;