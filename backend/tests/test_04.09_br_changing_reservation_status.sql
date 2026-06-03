rollback;
set search_path to public;
begin;
do
$test$
begin
    raise notice 'TEST: BR09 - Transition des statuts de réservations';
    perform should_fail($$
        INSERT INTO reservations (id, client, restaurant, datetime, number_of_guests, status, special_requests)
        VALUES (23, 3, 4, '2026-06-12 19:00:00', 2, 'cancelled', null);
        $$, 'raise_exception');
    raise notice 'TEST BR-09.1 réussi: Une nouvelle réservation ne peut avoir un autre statut qu''en attente';
    perform should_fail($$
        UPDATE reservations SET status = 'completed' WHERE id = 2;
        $$, 'raise_exception');
    raise notice 'TEST BR-09.2 réussi: une réservation en attente ne peut pas transiter à terminer';
    perform should_fail($$
        UPDATE reservations SET status = 'confirmed' WHERE id = 8;
        $$, 'raise_exception');
    raise notice 'TEST BR-09.3 réussi: une réservation annulée ne peut plus être modifiée!';
    perform should_fail($$
        UPDATE reservations SET status = 'pending' WHERE id = 20;
        $$, 'raise_exception');
    raise notice 'TEST BR-09.4 réussi: Une réservation termniée ne peut plus revenir en arrière';
end;
$test$;
rollback;