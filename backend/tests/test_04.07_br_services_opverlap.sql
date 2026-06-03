rollback;
set search_path to public;

begin;
do
$test$
    begin
        raise notice 'TEST: BR-07 - chevauchement des services du jour';
        perform should_fail($$
            INSERT INTO services (id, restaurant, day_of_week, start_time, end_time)
            VALUES (89, 1, 1, '13:00:00', '17:00:00');
        $$, 'raise_exception');
        perform should_fail($$
            INSERT INTO services (id, restaurant, day_of_week, start_time, end_time)
            VALUES (89, 1, 1, '20:30:00', '23:00:00');
        $$, 'raise_exception');
        raise notice 'TEST BR-07 réussi: Les services de ce jour ne se chevauchent pas';
    end;
$test$;
rollback;