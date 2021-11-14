-----------------
-- 2
-----------------
--2a
--PennDOT built a new road which crosses “Allegheny National Forest”. The road is
--named “Route Five”, which has road no 105 and length 426.
begin ;
INSERT INTO ROAD VALUES (105,'Route Five',426);
end;
--2b
--The administration office has switched John and Jason’s duties.
--They are now maintaining sensors that have been maintained by the other in the past.
begin;
UPDATE WORKER
end;
--2c
--The administration office have hired a new worker, Natalia, who is employed by “OH”
--state. Natalia’s ssn is “105588973”, and her rank is 1. She is assigned to maintain
--sensor 2 from now on (and the previous maintainer of sensor 2 will not maintain it anymore).
begin;
INSERT INTO WORKER VALUES (105588973, 'Natalia', 1, 'OH' );
end;
