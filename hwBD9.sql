drop table demographics;
drop table names;
drop table encrypt;
drop table repositories;
drop table products;
CREATE TABLE demographics
(
    id       int,
    name1    varchar,
    birthday date,
    race     varchar
);
--Task 1
ALTER TABLE demographics
    ADD COLUMN "calculation" integer;
insert into demographics
values (1, 'Verile', to_date('20221124', 'YYYYMMDD'), 'Warren');
UPDATE demographics
SET calculation = (bit_length(name1) + char_length(race))
where true;
SELECT demographics.calculation
FROM demographics;

-- Task 2
SELECT id,
       bit_length(name1) as bit_length_name,
       birthday,
       bit_length(race)
                         as bit_length_race
FROM demographics;

-- Task 3
SELECT id, ascii(name1), birthday, ascii(race)
FROM demographics;

-- Task 4
create table names
(
    id     int,
    prefix varchar,
    first  varchar,
    last   varchar,
    suffix varchar
);
alter table names
    add column "full_name" varchar;
insert into names
values (1, 'a', 'b', 'c', 'd');
update names
set full_name = (concat(prefix, ' ', first, ' ', last, ' ', suffix))
where true;
select *
from names;

--Task 5
create table encrypt
(
    md5    varchar,
    sha1   varchar,
    sha256 varchar
);
insert into encrypt
values ('123', '321', '111222333');
select concat(md5, repeat('1', (length(sha256) - length(md5))))   as md5,
       concat(repeat('0', (length(sha256) - length(sha1))), sha1) as sha1,
       sha256
from encrypt;

--Task 6
create table repositories
(
    project      varchar,
    commits      int,
    contributors int,
    address      varchar
);
SELECT "left"(project, commits)       as project,
       commits,
       contributors,
       "right"(address, contributors) as adress
FROM repositories;
-- Task 7
SELECT project,
       commits,
       contributors,
       regexp_replace(address, '[0-9]', '!', 'g') as address
from repositories;

-- Task 8
create table products
(
    id       int,
    name     varchar,
    price    float,
    stock    int,
    weight   float,
    producer varchar,
    country  varchar
);
select id,
       name,
       weight,
       price,
       round((price * 1000 / weight) :: numeric, 2)::float
           as price_per_kg
from products
order by price_per_kg, name;