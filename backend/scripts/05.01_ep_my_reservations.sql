/* Fonction qui récupère les réservations du client connecté */

drop function if exists get_my_reservations();

create or replace function get_my_reservations()
returns table (
id int, restaurant_name text, city text, datetime timestamp, number_of_guests int, status status_type) as
$$
begin
perform auth.check_logged();
return query
select r.id, rest.name::text as restaurant_name, rest.city::text, r.datetime, r.number_of_guests, r.status
from reservations r
join restaurants rest on rest.id = r.restaurant
where r.client = auth.id()
order by r.datetime desc;
end;
$$ language plpgsql security definer;

grant execute on function get_my_reservations() to anon, authenticated;