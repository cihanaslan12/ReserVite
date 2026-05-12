rollback;
begin;
do
$test$
    begin
        raise notice 'TEST: BR-03 - Table appartenant au restaurant';
        perform should_fail($$
            INSERT INTO reservation_tables(reservation, "table")
            VALUES (9, 1)
            $$, 'raise_exception');
        perform should_fail($$
            INSERT INTO reservation_tables(reservation, "table")
            VALUES (10, 1)
            $$, 'raise_exception');
        raise notice 'TEST BR-03 réussi: Cette table n''appartient pas à ce restaurant';
    end;
$test$;
end;
rollback;