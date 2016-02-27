-- packages/so-alert/sql/postgresql/so-alert-drop.sql

DROP index soa_soli_input_instrument;
DROP index soa_soli_input_date_idx;
DROP index soa_soli_input_priority;
DROP TABLE soa_soli_input;

DROP index soa_earthquakes_event_id_idx;
DROP index soa_earthquakes_date_idx;
DROP TABLE soa_earthquakes;

DROP index soa_soli_map_image_id;
DROP TABLE soa_soli_map;

DROP index soa_soli_analysis_image_id;
DROP index soa_soli_analysis_profile_type;
DROP TABLE soa_soli_analysis;


DROP index soa_soli_profile_data_profile_id;
DROP TABLE soa_soli_profile_data;

DROP TABLE soa_neo_ca;

DROP index soa_neo_approaches_approach_id;
DROP index soa_neo_approaches_object_ref;
DROP index soa_neo_approaches_date;
DROP TABLE soa_neo_approaches;

