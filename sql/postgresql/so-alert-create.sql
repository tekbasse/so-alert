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

-- sol image (soli) input refernces
-- sources from sdo and soho
CREATE TABLE soa_soli_input (
       date date,
       time_utc time without time zone,
       size varchar(10),
       instrument varchar(10),
       priority integer,
       note	text
);

CREATE index soa_soli_input_date_idx on soa_soli_input (date);
CREATE index soa_soli_input_priority on soa_soli_input (priority);
CREATE index soa_soli_input_instrument on soa_soli_input (instrument);


CREATE TABLE soa_soli_map (
       image_id integer,
       image_external_ref varchar(30),
       local_url text
);

CREATE index soa_soli_map_image_id on soa_soli_map (image_id); 

-- soli analysis indexes (mapped to profile data)
CREATE TABLE soa_soli_analysis (
       image_id integer,
       -- types:
       -- brightness, position, ion, ray
       -- etc.
       profile_type varchar(30),
       -- if a single value makes sense. Here it is
       profile_value numeric,
       -- parameters
       profile_id integer
);

CREATE index soa_soli_analysis_image_id on soa_soli_analysis (image_id);
CREATE index soa_soli_analysis_profile_type on soa_soli_analysis (profile_type);


CREATE TABLE soa_soli_profile_data (
       profile_id integer,
       param_nbr integer,
       value numeric
);

CREATE index soa_soli_profile_data_profile_id on soa_soli_profile_data (profile_id);
      
-- NEO object close appraoches
-- Between 1900AD and 2200AD , less than 10LD
-- This is for data with little modifying from neo database
CREATE TABLE soa_neo_ca (
       object_ref varchar(30),
       -- YYYY-mmm-DD HH:MM +/- D_HH:MM
       date text,
       -- LD/AU
       dist_nom text,
       -- LD/AU
       dist_min text,
       -- km / s
       v_relative text,
       -- km / s
       v_inf text,
       n_sigma text,
       -- magnitude
       h_mag text,
       ref text,
       class text
);

-- neo data adapted for data analysis
CREATE TABLE soa_neo_approaches (
       approach_id integer,
       object_ref varchar(30),
       date date,
       time_utc time without time zone,
       dist_nom_ld numeric,
       dist_min_ld numeric,
       v_rel numeric,
       v_inf numeric,
       n_sigma numeric
);

CREATE index soa_neo_approaches_approach_id on soa_neo_approaches(approach_id);
CREATE index soa_neo_approaches_object_ref on soa_neo_approaches(object_ref);
CREATE index soa_neo_approaches_date on soa_neo_approaches(date);


CREATE TABLE soa_earth_sun_moon_events (
       -- source ie catalog etc
       -- for example: SE
       -- see cross-reference soa_earth_sun_moon_events.source    
       source varchar(16),
       -- event reference assigned by source
       source_ref varchar(30),
       -- event type basic
       -- solar eclipse, lunar eclipse, lunar 1st qtr, lunar full moon, lunar 3rd quarter etc.
       -- for example:
       -- solar-eclipse, luna-eclipse, luna-first, luna-full luna-third, luna-new
       type varchar(14),
       -- yyyy-mm-dd
       date date,
       -- the 'center' of the event orientation
       time_utc time without time zone,
       duration_s integer,
       -- distance between Earth and Moon centers
       lunar_dist_km numeric,
       -- source of lunar_distance calculation
       lunar_dist_km_by varchar(30),
       -- other notes that may have been included with original data
       notes text
);

CREATE TABLE soa_earth_sun_moon_event_sources (
       -- source ie catalog etc,
       -- for example: SE, see cross-reference soa_earth_sun_moon_events.source
       source varchar(16),
       -- notes could contain for example:

       -- Five Millennium Catalog of Solar Eclipses: -1999 to 3000 (2000 BCE to 3000CE)
       -- by Fred Espenak nd Jean Meeus 
       -- Based on NASA Technical Publication TP-2006-21414, 2007 Jan 26
       -- retrieved from: http://eclipse.gsfc.nasa.gov/5MCSE/5MCSEcatalog.txt
       notes text
);
