rollback;
set search_path to public;
begin;
do
$test$
    begin
        raise notice 'TEST: BR-12 - Pas de table pour une réservation pending ou cancelled';
        INSERT INTO reservations (id, client, restaurant, datetime, number_of_guests, status, special_requests)
        VALUES (50, 3, 1, '2026-06-15 20:00:00', 2, 'pending', null);
        perform should_fail($$
            INSERT INTO reservation_tables (reservation, "table") VALUES (50, 1);
            $$, 'raise_exception');
        raise notice 'TEST BR-12 réussi: l''attribution de la table a bien été bloquée';
    end;
$test$;
rollback;