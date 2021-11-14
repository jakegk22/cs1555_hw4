-----------------
-- 2
-----------------
--2a
--PennDOT built a new road which crosses “Allegheny National Forest”. The road is
--named “Route Five”, which has road no 105 and length 426.
begin ;
INSERT INTO ROAD VALUES (105,'Route Five',426);
commit;
--2b
--The administration office has switched John and Jason’s duties.
--They are now maintaining sensors that have been maintained by the other in the past.
begin ;
UPDATE SENSOR
SET maintainer = '123456789'
where sensor_id = '4' AND sensor_id = '6' AND sensor_id = '12';

UPDATE  sensor
SET maintainer = '121212121'
where sensor_id = '1' AND sensor_id = '5' AND sensor_id = '8';
commit;
--2c
--The administration office have hired a new worker, Natalia, who is employed by “OH”
--state. Natalia’s ssn is “105588973”, and her rank is 1. She is assigned to maintain
--sensor 2 from now on (and the previous maintainer of sensor 2 will not maintain it anymore).
begin;
INSERT INTO WORKER VALUES (105588973, 'Natalia', 1, 'OH' );
end;

--SELECT * FROM sensor;

-----------------
-- 4
-----------------
--4a
drop view if exists Duties;
create view Duties as
select s.maintainer, count(s.maintainer) as total_num_of_sensors_per_maintainer
from worker w, sensor s
where s.maintainer = w.ssn
group by  s.maintainer;

--4b
drop materialized view if exists duties_mv;
create materialized view duties_mv as
select s.maintainer, count(s.maintainer) as total_num_of_sensors_per_maintainer
from worker w, sensor s
where s.maintainer = w.ssn
group by  s.maintainer;
--SELECT * from duties_mv;

--4c
drop view if exists forest_sensor;
create view forest_sensor as
    select f.name as forest_name, forest_no, s.sensor_id as sensor_id
from forest f, sensor s,  FOREST JOIN SENSOR ON SENSOR.x >= FOREST.mbr_xmin AND
                                                SENSOR.x <= FOREST.mbr_xmax AND
                                                SENSOR.y >= FOREST.mbr_ymin AND
                                                SENSOR.y <= FOREST.mbr_ymax

select * from forest_sensor;

--4d
--A view named FOREST ROAD that lists the number of roads intersecting each forest.
drop view if exists FOREST_ROAD;
create view FOREST_ROAD as
    select f.forest_no, f.name, count(i.road_no) as num_of_roads
from intersection i, forest f
where f.forest_no = i.forest_no
group by f.forest_no;

-----------------
-- 5
-----------------
--5a
select * from FOREST_ROAD
order by num_of_roads desc
fetch first 2 rows only offset 1;

--5b
select * from Duties;
-- -- select w.name, w.employing_state, c.area

select d.maintainer, d.total_num_of_sensors_per_maintainer
from  Duties d, worker w
order by total_num_of_sensors_per_maintainer desc
fetch first 1 rows only;
-- where d.maintainer = w.ssn;

--as worker_maintaining_most_num_of_sensors ;
--222222222,Mike,4,OH is the ans

select * from worker;