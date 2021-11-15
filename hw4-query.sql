-- Jacob Kefalos , Matt Rindner
-- jgk22@pitt.edu, Mrv17@pitt.edu

-----------------
-- Question #2:
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

-----------------
-- Question #3:
-----------------

-- sensor 7 reported 9 times, sensor 11 reported 7 times. (just to check if produced correct values)
--3a
select sensor_id, RANK() OVER(
    ORDER BY num_reports DESC
) as rank
FROM ( select sensor_id, count(*) as num_reports from REPORT
    group by sensor_id
    order by num_reports) num_reports_taken fetch first 3 rows only;

-- rank sensor ids according to the number of reports taken by each sensor
-- then fetch the top three rows to get the top three sensors

--3b
select sensor_id, RANK() OVER(
    ORDER BY num_reports DESC
) as rank
FROM ( select sensor_id, count(*) as num_reports from REPORT
    group by sensor_id
    order by num_reports) num_reports_taken fetch first 2 rows only offset 3;
-- same premise as 3a but fetch the 2 rows and set the offset to 3 t
-- inorder to get the two sensors after the top three

--3c
--select * from coverage;
select state, sum(area) as total_area from coverage
group by state
having sum(area) >  (
        select sum(area) from COVERAGE where state = 'PA'
        )
order by total_area desc;
-- get the state and the total area of forrest coverage in that state
-- then select states if they have more forest coverage than Pennsylvania

--3d
--stone valley num is 3
select r.name
from road r NATURAL JOIN intersection i
where i.forest_no = '3'
group by r.name;
-- select the roads and intersections where the forest is equal to Big Woods (forrest_no 3)
-- then group those roads by their road name

--3e
select ssn, name, RANK() OVER(
    ORDER BY num_charges DESC
) as rank
FROM (
    select ssn, name, count(s) as num_charges
    from worker w join sensor s on s.maintainer = w.ssn
    where s.energy < 3
    group by ssn,name
    order by num_charges) num_reports_taken;
--select and rank workers from the sensor their working on
-- such that their sensor battery is less than or equal to 2, <3 also achieves this goal
-- order by the number of sensors each maintainer needs to charge

--3f
select f.name
from forest f join coverage c on f.forest_no = c.forest_no
where c.state = 'PA' and f.acid_level > .60;

-- select forest names based on their coverage in the state of PA and
-- if their Acid level is greater than 60% (.60)


-----------------
-- Question #4:
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
select  f.forest_no, f.name, s.sensor_id
from forest f, sensor s,  FOREST JOIN SENSOR ON SENSOR.x >= FOREST.mbr_xmin AND
                                                SENSOR.x <= FOREST.mbr_xmax AND
                                                SENSOR.y >= FOREST.mbr_ymin AND
                                                SENSOR.y <= FOREST.mbr_ymax
group by f.name, f.forest_no, s.sensor_id
order by f.forest_no;
-- create view of which sensors lie within the bounds of any of the Forrests


--select * from forest_sensor;

--4d
--A view named FOREST ROAD that lists the number of roads intersecting each forest.
drop view if exists FOREST_ROAD;
create view FOREST_ROAD as
    select f.forest_no, f.name, count(i.road_no) as num_of_roads
from intersection i, forest f
where f.forest_no = i.forest_no
group by f.forest_no;

-----------------
-- Question #5:
-----------------

--5a
select * from FOREST_ROAD
order by num_of_roads desc
fetch first 2 rows only offset 1;

--5b

select d.maintainer, w.name, w.employing_state, sum(co.area) as total_area
from Duties d, worker w , state s , coverage co
where d.maintainer = w.ssn  and co.state = w.employing_state
group by d.total_num_of_sensors_per_maintainer, w.name, d.maintainer, w.employing_state fetch first row only;
-- select the maintainer and their employing state and name from the workers table
-- sum the area of forest within the state each worker works in
-- then match their info across the table and group by who ever maintains the most
-- amount of sensors. fetch the first row to get the data for the right worker


--5c
select f.name
from forest f, sensor s, report r, FOREST JOIN SENSOR ON SENSOR.x >= FOREST.mbr_xmin AND
                                                SENSOR.x <= FOREST.mbr_xmax AND
                                                SENSOR.y >= FOREST.mbr_ymin AND
                                                SENSOR.y <= FOREST.mbr_ymax
where r.report_time not between
     to_timestamp('10/10/2020 00:00:00','mm/dd/yyyy hh24:mi') and to_timestamp('10/11/2020 00:00:00','mm/dd/yyyy hh24:mi')
group by f.name;
-- select the name of forest that are joined from the sensor and forest tables,
-- then match the areas each sensor lies in within each forest
-- finally find the the forrest where no sensors had reports from the given timestamps

-- -- select w.name, w.employing_state, c.area
-- 5d
select d.maintainer, d.total_num_of_sensors_per_maintainer
from  Duties d, worker w
order by total_num_of_sensors_per_maintainer desc
fetch first 1 rows only;
-- where d.maintainer = w.ssn;

--as worker_maintaining_most_num_of_sensors ;
--222222222,Mike,4,OH is the ans

--select * from worker;

--5e

select FOREST.name
from FOREST JOIN SENSOR ON SENSOR.x >= FOREST.mbr_xmin AND
                                                SENSOR.x <= FOREST.mbr_xmax AND
                                                SENSOR.y >= FOREST.mbr_ymin AND
                                                SENSOR.y <= FOREST.mbr_ymax
where FOREST.name != 'Big Woods' and SENSOR.x >= 150 AND
          SENSOR.x <= 180 AND
          SENSOR.y >= 20 AND
          SENSOR.y <= 120
group by FOREST.name;
-- use the same way to locate which sensors lie within each forests
-- and then find the sensors that lie within the range of the big woods forest
-- omit big woods so we only get the forests that share same sensors as big woods

