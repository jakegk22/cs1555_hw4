----CS1555/2055 - DATABASE MANAGEMENT SYSTEMS (FALL 2021)
----DEPT. OF COMPUTER SCIENCE, UNIVERSITY OF PITTSBURGH
----ASSIGNMENT #4 DB creation


---DROP DATABASE ELEMENTS TO MAKE SURE THE SCHEMA IS CLEAR (E.G., TABLES, DOMAINS, ETC.)
DROP TABLE IF EXISTS FOREST CASCADE;
DROP TABLE IF EXISTS STATE CASCADE;
DROP TABLE IF EXISTS COVERAGE CASCADE;
DROP TABLE IF EXISTS ROAD CASCADE;
DROP TABLE IF EXISTS INTERSECTION CASCADE;
DROP TABLE IF EXISTS WORKER CASCADE;
DROP TABLE IF EXISTS SENSOR CASCADE;
DROP TABLE IF EXISTS REPORT CASCADE;
DROP DOMAIN IF EXISTS energy_dom;

CREATE DOMAIN energy_dom AS integer CHECK (value >= 0 AND value <= 100);

CREATE TABLE FOREST (
    forest_no       varchar(10),
    name            varchar(30) NOT NULL,
    area            real NOT NULL,
    acid_level      real NOT NULL,
    mbr_xmin        real NOT NULL,
    mbr_xmax        real NOT NULL,
    mbr_ymin        real NOT NULL,
    mbr_ymax        real NOT NULL,
    CONSTRAINT FOREST_PK PRIMARY KEY (forest_no),
    CONSTRAINT FOREST_UN1 UNIQUE (name),
    CONSTRAINT FOREST_UN2 UNIQUE (mbr_xmin, mbr_xmax, mbr_ymin, mbr_ymax),
    CONSTRAINT FOREST_CH CHECK (acid_level >= 0 AND acid_level <= 1)
);


CREATE TABLE STATE (
    name            varchar(30) NOT NULL,
    abbreviation    varchar(2),
    area            real NOT NULL,
    population      integer NOT NULL,
    CONSTRAINT STATE_PK PRIMARY KEY (abbreviation),
    CONSTRAINT STATE_UN UNIQUE (name)
);


CREATE TABLE COVERAGE (
    forest_no       varchar(10),
    state           varchar(2),
    percentage      real NOT NULL,
    area            real NOT NULL,
    CONSTRAINT COVERAGE_PK PRIMARY KEY (forest_no, state),
    CONSTRAINT COVERAGE_FK1 FOREIGN KEY (forest_no) REFERENCES FOREST(forest_no),
    CONSTRAINT COVERAGE_FK2 FOREIGN KEY (state) REFERENCES STATE(abbreviation)
);


CREATE TABLE ROAD (
    road_no varchar(10),
    name    varchar(30) NOT NULL,
    length  real NOT NULL,
    CONSTRAINT ROAD_PK PRIMARY KEY (road_no)
);


CREATE TABLE INTERSECTION (
    forest_no varchar(10),
    road_no   varchar(10),
    CONSTRAINT INTERSECTION_PK PRIMARY KEY (forest_no, road_no),
    CONSTRAINT INTERSECTION_FK1 FOREIGN KEY (forest_no) REFERENCES FOREST(forest_no),
    CONSTRAINT INTERSECTION_FK2 FOREIGN KEY (road_no) REFERENCES ROAD(road_no)
  );


CREATE TABLE WORKER (
    ssn  varchar(9) ,
    name varchar(30) NOT NULL,
    rank integer NOT NULL,
    employing_state varchar(2) NOT NULL,
    CONSTRAINT WORKER_PK PRIMARY KEY (ssn),
    CONSTRAINT WORKER_UN UNIQUE (name),
    CONSTRAINT WORKER_FK FOREIGN KEY (employing_state) REFERENCES STATE(abbreviation)
);


CREATE TABLE SENSOR
  (
    sensor_id integer,
    x real NOT NULL,
    y real NOT NULL,
    last_charged timestamp NOT NULL,
    maintainer   varchar(9) DEFAULT NULL,
    last_read    timestamp NOT NULL,
    energy energy_dom NOT NULL,
    CONSTRAINT SENSOR_PK PRIMARY KEY (sensor_id),
    CONSTRAINT SENSOR_FK FOREIGN KEY (maintainer) REFERENCES WORKER(ssn),
    CONSTRAINT SENSOR_UN2 UNIQUE (x, y)
);

CREATE TABLE REPORT (
    sensor_id integer,
    report_time timestamp NOT NULL,
    temperature real NOT NULL,
    CONSTRAINT REPORT_PK PRIMARY KEY (sensor_id, report_time),
    CONSTRAINT REPORT_FK FOREIGN KEY (sensor_id) REFERENCES SENSOR(sensor_id)
);

