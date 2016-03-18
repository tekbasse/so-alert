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

DROP TABLE soa_earth_sun_moon_event_sources;

DROP index soa_earth_sun_moon_events_type;
DROP index soa_earth_sun_moon_events_date;
DROP TABLE soa_earth_sun_moon_events;

DROP index soa_solar_tilt_date_idx;
DROP TABLE soa_solar_tilt;


DROP index soa_ace_mag_date_idx;
DROP TABLE soa_ace_mag;

DROP index soa_ace_swepam_date_idx;
DROP TABLE soa_ace_swepam;

DROP index soa_ace_epam_date_idx;
DROP TABLE soa_ace_epam;

DROP index soa_ace_loc_date_idx;
DROP TABLE soa_ace_loc;

DROP index soa_ace_sis_date_idx;
DROP TABLE soa_ace_sis;

DROP index soa_tromsoe_mag_date_idx;
DROP TABLE soa_tromsoe_mag;
