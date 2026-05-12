rollback;
set search_path to public;

begin;
do
$test$
    begin
        raise notice 'TEST: BR-01 - le rôle de l''utilisateur doit être client';
        perform should_fail($$
            INSERT INTO reservations (restaurant, datetime, client, number_of_guests, status)
            VALUES (1, '2026-06-01 19:00:00', 2, 2, 'confirmed');
            $$, 'raise_exception');
            raise notice 'TEST BR-01 réussi: le manager n'' pas pu se faire passer pour un client';
end
$test$;
rollback;