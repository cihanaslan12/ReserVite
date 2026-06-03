rollback;
set search_path to public;
begin;
do
$test$
    begin
        raise notice 'TEST: BR-10 - Chaque restaurant doit avoir au moins un manager';
        INSERT INTO restaurants (id, name, address, city, phone, description, rating, price_range, slot_duration)
            VALUES (10, 'ORESTO', 'rue du resto 1', 1070, '+32 2 222 22 22', 'resto pour se remplir le ventre', 5.0, 3, 60);
        INSERT INTO restaurant_managers (restaurant, manager) VALUES (10, 3);
        perform should_fail($$
            UPDATE restaurant_managers SET restaurant = 1 WHERE restaurant = 6;
            $$, 'raise_exception');
        perform should_fail($$
            DELETE FROM restaurant_managers WHERE restaurant = 5;
            $$, 'raise_exception');
        raise notice 'TEST BR-10 réussi: Le restaurant ne peut pas rester sans manager';
    end;
$test$;
rollback;