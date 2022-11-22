drop table if exists  job_history ;
drop table if exists employee;
drop table if exists jobs;
CREATE TABLE jobs
(
    job_id     varchar unique ,
    job_title  varchar,
    min_salary integer,
    max_salary integer
);
CREATE TABLE employee
(
  user_id int unique,
  hire_date date,
  job_id varchar,
  foreign key (job_id) references  jobs(job_id),
  salary int,
  years int
);
CREATE TABLE job_history
(
    employee_id integer,
    job_id varchar,
    hire_day date,
    fire_day date,
    FOREIGN KEY (employee_id) references employee(user_id),
    FOREIGN KEY (job_id) references jobs(job_id)
);
--Task 1
create or replace procedure new_job(id IN jobs.job_id%TYPE, title jobs.job_title%TYPE,
                                    min_sal jobs.min_salary%TYPE)
    LANGUAGE plpgsql
AS
$$
DECLARE
    max_sal jobs.max_salary%TYPE = 2 * min_sal;
BEGIN
    INSERT into jobs(job_id, job_title, min_salary, max_salary)
    values (id, title, min_sal, max_sal);
    --raise notice 'Работа добавлена';
end;
$$;
call new_job('SY_ANAL', 'System Analyst', 6000);
call new_job('AI_PROG', 'AI Programmer', 10000);

-- Task 2
create or replace procedure add_job_history(e_id in employee.user_id%TYPE, new_job_id IN jobs.job_id%TYPE)
  LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT into job_history(employee_id, job_id, hire_day, fire_day)
    values (e_id, (select job_id from employee
                                 where user_id = e_id), (select hire_date from employee where user_id = e_id), current_date);
    update employee
    set job_id=new_job_id,
    hire_date=CURRENT_DATE,
    salary=(select min_salary from jobs where job_id = new_job_id) + 500
    where user_id = e_id;
end;
$$;
-- No need to disable trigger that we don`t have..
ALTER TABLE employee DISABLE TRIGGER ALL;
ALTER TABLE jobs DISABLE TRIGGER ALL;
ALTER TABLE job_history DISABLE TRIGGER ALL;

insert into employee values (106, '2021-1-1', 'AI_PROG', 13000, 15);
call add_job_history(106, 'SY_ANAL');
-- Enable
ALTER TABLE employee ENABLE TRIGGER ALL;
ALTER TABLE jobs ENABLE TRIGGER ALL;
ALTER TABLE job_history ENABLE TRIGGER ALL;

--Task3
create or replace procedure upd_job_sal(j_id jobs.job_id%type, new_min jobs.min_salary%type,
                                            new_max jobs.max_salary%type)
language plpgsql
as
$$
begin
    if (new_min > new_max) then
        RAISE EXCEPTION 'min salary > max salary';
    end if;

    update jobs set min_salary= new_min,
                    max_salary=new_max
                where job_id = j_id;
exception
    when OTHERS then
            raise notice 'Locked error';
end;
$$;
call upd_job_sal('SY_ANAL', 7000, 140);
ALTER TABLE jobs DISABLE TRIGGER ALL;
call upd_job_sal('SY_ANAL', 7000, 14000);
ALTER TABLE jobs ENABLE TRIGGER ALL;
-- Task 4

create or replace function get_years_service(u_id in employee.user_id%TYPE) returns integer
language plpgsql
as
$$
begin
     if ((SELECT COUNT(*) as count FROM employee WHERE user_id= u_id) = 0) then
            raise notice 'Locked error';
            return -1;
    end if;
    return (select years from employee where user_id = u_id);
end;
$$;
select get_years_service(999);
--DBMS_OUTPUT.PUT_LINE - oracle? idk
select get_years_service(106);
-- Task 5
create or replace function get_job_count(u_id in employee.user_id%TYPE) returns integer
language plpgsql
as
$$
begin
     if ((SELECT COUNT(*) as count FROM employee WHERE user_id= u_id) = 0) then
            raise notice 'Locked error';
            return -1;
    end if;
    return (select count(distinct job_id) from job_history where employee_id = u_id and job_id !=
                                                                                (select job_id from employee
                                                                                               where u_id = user_id)) +1;
end;
$$;
select get_job_count(106);
select get_job_count(176);