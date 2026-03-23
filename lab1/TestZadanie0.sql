-- select * from PERSON

-- Test ROLLBACK
insert into person(firstname, lastname) values ('Adam', 'Testowy');
rollback; -- Wiersz wycofany

-- Test COMMIT
insert into person(firstname, lastname) values ('Ewa', 'Zatwierdzona');
commit; -- Wiersz zostaje trwale zapisany