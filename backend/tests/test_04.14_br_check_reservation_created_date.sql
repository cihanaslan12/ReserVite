rollback;
set search_path to public;
begin;
do
$test$
    begin
        raise notice 'TEST: BR-14: Une réservation ne peut pas être créée dans le passé';
        perform should_fail($$
            INSERT INTO reservations (id, client, restaurant, datetime, number_of_guests, status, special_requests)
            VALUES (23, 3, 5, '2023-12-12 20:00:00', 2, 'pending', null);
            $$, 'raise_exception');
        raise notice 'TEST BR-14 réussi: Il n''est pas possible de créer une réservation dans le passé';
    end;
$test$;
end;
rollback;