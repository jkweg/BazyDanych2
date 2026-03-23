insert into trip(trip_name, country, trip_date, max_no_places)
values ('Sloneczna Barcelona', 'Hiszpania', to_date('2025-07-10', 'YYYY-MM-DD'), 5);

insert into trip(trip_name, country, trip_date, max_no_places)
values ('Rzymskie wakacje', 'Wlochy', to_date('2026-08-15', 'YYYY-MM-DD'), 4);

insert into trip(trip_name, country, trip_date, max_no_places)
values ('Zimowy Wieden', 'Austria', to_date('2026-12-05', 'YYYY-MM-DD'), 3);

insert into person(firstname, lastname) values ('Anna', 'Wisniewska');
insert into person(firstname, lastname) values ('Piotr', 'Zelazny');
insert into person(firstname, lastname) values ('Katarzyna', 'Lewandowska');
insert into person(firstname, lastname) values ('Marek', 'Dabrowski');
insert into person(firstname, lastname) values ('Ewa', 'Kaczmarek');
insert into person(firstname, lastname) values ('Tomasz', 'Mazur');

insert into reservation(trip_id, person_id, status) values (5, 8, 'P');
insert into reservation(trip_id, person_id, status) values (5, 9, 'P');
insert into reservation(trip_id, person_id, status) values (5, 10, 'C');

insert into reservation(trip_id, person_id, status) values (6, 5, 'N');
insert into reservation(trip_id, person_id, status) values (6, 6, 'P');
insert into reservation(trip_id, person_id, status) values (6, 7, 'P');

insert into reservation(trip_id, person_id, status) values (7, 1, 'P');
insert into reservation(trip_id, person_id, status) values (7, 5, 'C');

insert into reservation(trip_id, person_id, status) values (4, 3, 'N');

commit