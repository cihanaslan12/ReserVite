rollback;
set search_path to public;

begin;
do $test$
    begin
        raise notice 'TEST: Users';
        perform should_fail($$
        insert into users (email, password, full_name, role)
        values ('test@test.be', 'Password1,', 'Ab', 'client');
    $$, 'check_violation');
        perform should_fail($$
        update users set role = 'manager' where id = 3;
    $$, 'raise_exception');
        perform should_fail($$
        update users set full_name = 'Nouveau Nom' where id = 1;
    $$, 'raise_exception');
    end $test$;
rollback;

begin;
do $test$
    begin
        raise notice 'TEST: Restaurants';
        perform should_fail($$
        insert into restaurants (name, address, city, phone, description, rating, price_range, slot_duration)
        values ('Rest', 'Rue de la Loi 1', 'Bruxelles', '+3221234567', 'Description assez longue', 4, 2, 30);
    $$, 'check_violation');
        perform should_fail($$
        update restaurants set rating = 6.0 where id = 1;
    $$, 'check_violation');
        perform should_fail($$
        update restaurants set phone = '0475123456' where id = 1;
    $$, 'check_violation');
        perform should_fail($$
        update restaurants set slot_duration = 45 where id = 1;
    $$, 'check_violation');
    end $test$;
rollback;

begin;
do $test$
    begin
        raise notice 'TEST: Reservations';
        perform should_fail($$
        update reservations set number_of_guests = -1 where id = 1;
    $$, 'check_violation');
        perform should_fail($$
        update reservations set restaurant = 2 where id = 1;
    $$, 'raise_exception');
        perform should_fail($$
        update reservations set special_requests = 'Court' where id = 1;
    $$, 'check_violation');
    end $test$;
rollback;

begin;
do $test$
    begin
        raise notice 'TEST: Général';
        perform should_fail('update tables set id = 999 where id = 1', 'raise_exception');
        perform should_fail('update restaurant_managers set restaurant = 2 where restaurant = 1', 'raise_exception');
    end $test$;
rollback;