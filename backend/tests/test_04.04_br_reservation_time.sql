rollback;
begin;
do
$test$
    begin
        raise notice 'TEST: BR-04 - Heure de réservation dans les heures du service du jour';
        perform should_fail($$
            INSERT INTO reservations (id, client, restaurant, datetime, number_of_guests, status, special_requests)
            VALUES (40, 4, 2, '2026-06-11 23:00:00', 2, 'pending', null)
            $$, 'raise_exception');
        raise notice 'TEST BR-04 réussi: La réservation doit être dans les heures de services du jour';
    end;
$test$;
end;
rollback;