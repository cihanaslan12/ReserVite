rollback;
set search_path to public;
begin;
do
$test$
    begin
        raise notice 'TEST: BR-08 - Start et end service alignés aux créneaux du restaurant';
        perform should_fail($$
            INSERT INTO services (restaurant, day_of_week, start_time, end_time)
            VALUES (1, 1, '12:00:00', '14:15:00');
            $$, 'raise_exception');
        perform should_fail($$
            INSERT INTO services (restaurant, day_of_week, start_time, end_time)
            VALUES (1, 1, '12:10:00', '14:30:00');
            $$, 'raise_exception');
        perform should_fail($$
            INSERT INTO services (restaurant, day_of_week, start_time, end_time)
            VALUES (1, 1, '11:00:00', '15:00:00');
            $$, 'raise_exception');
        raise notice 'Les mauvaises heures de service ont bien été bloquées';
    end;
$test$;
rollback;