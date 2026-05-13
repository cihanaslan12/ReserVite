rollback;
set search_path to public;
begin;
do
$test$
    begin
        raise notice 'TEST: BR-11 - Réservations terminées ou annulées non modifiables';
        perform should_fail($$
            UPDATE reservations SET number_of_guests = 5 WHERE id = 7;
            UPDATE reservations SET special_requests = 'on garde la résa' WHERE id = 8;
            $$, 'raise_exception');
        raise notice 'TEST BR-11 réussi: La réservation terminée ou annulée n''a pas pu être modifiée';
    end;
$test$;
rollback;