-- packages/so-alert/sql/postgresql/so-alert-drop.sql

DROP index soa_sdo_input_date_idx;
DROP index soa_sdo_input_priority;
DROP TABLE soa_sdo_input;

DROP index soa_earthquakes_event_id_idx;
DROP index soa_earthquakes_date_idx;
DROP TABLE soa_earthquakes;
