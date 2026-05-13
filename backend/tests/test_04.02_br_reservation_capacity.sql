rollback;
set search_path to public;

begin;
do
$test$
    begin
        raise notice 'TEST: BR-02 - Surnombre de convives';
        INSERT INTO reservations (id, client, restaurant, datetime, number_of_guests, status, special_requests)
        VALUES (100, 3, 1, '2026-05-29 20:00:00', 5, 'pending', null);
        perform should_fail($$
            INSERT INTO reservation_tables (reservation, "table") VALUES (100, 1);
            UPDATE reservations SET status = 'completed' WHERE id = 100;
            $$, 'raise_exception');
        raise notice 'TEST BR-02 réussi : Le nombre de convive ne peut dépasser la capacité totale';
    end;
$test$;
rollback;