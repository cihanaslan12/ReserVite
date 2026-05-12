rollback;
begin;
do
$test$
    begin
        raise notice 'TEST: BR-05 - Créneau de réservation';
        perform should_fail($$
        INSERT INTO reservations (id, client, restaurant, datetime, number_of_guests, status, special_requests)
        VALUES (50, 6, 5, '2026-05-30 19:10:00', 2, 'pending', null)
            $$, 'raise_exception');
        raise notice 'TEST BR-05 réussi: Le créneau de la réservation est incorrecte';
    end;
$test$;
end;
rollback;