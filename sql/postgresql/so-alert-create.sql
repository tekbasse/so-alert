-- packages/so-alert/sql/postgresql/so-alert-create.sql
--
-- @creation-date 2016-02-14
-- Data is from 

CREATE TABLE soa_earthquakes (
       magnitude numeric,
       depth_km numeric,
       date date,
       time_utc time without time zone,
       latitude numeric,
       longitude numeric,
       region text,
       IEB_timestamp varchar(20),
       -- IEB event_id
       event_id varchar(20)
);

CREATE index soa_earthquakes_event_id_idx on soa_earthquakes (event_id);
CREATE index soa_earthquakes_date_idx on soa_earthquakes (date);


