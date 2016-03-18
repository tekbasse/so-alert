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

CREATE index soa_earth_sun_moon_events_type on soa_earth_sun_moon_events(type);
CREATE index soa_earth_sun_moon_events_date on soa_earth_sun_moon_events(date);

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

-- Header info from JPL Horizon's web query. 
-- Note that observer is really the Sun, and target is Earth,
-- but for some reason, the query requires the opposite. 
-- *******************************************************************************
--  Revised : Jul 31, 2013                  Sun                                 10
-- 
--  PHYSICAL PROPERTIES (revised Jan 16, 2014):
--   GM (10^11 km^3/s^2)   = 1.3271244004193938  Mass (10^30 kg)   ~ 1.988544
--   Radius (photosphere)  = 6.963(10^5) km  Angular diam at 1 AU  = 1919.3"
--   Solar Radius (IAU)    = 6.955(10^5) km  Mean density          = 1.408 g/cm^3
--   Surface gravity       =  274.0 m/s^2    Moment of inertia     = 0.059
--   Escape velocity       =  617.7 km/s     Adopted sidereal per  = 25.38 d
--   Pole (RA,DEC in deg.) =  286.13,63.87   Obliquity to ecliptic = 7 deg 15'        
--   Solar constant (1 AU) = 1367.6 W/m^2    Solar lumin.(erg/s)   =  3.846(10^33)
--   Mass-energy conv rate = 4.3(10^12 gm/s) Effective temp (K)    =  5778
--   Surf. temp (photosphr)= 6600 K (bottom) Surf. temp (photosphr)=  4400 K (top)
--   Photospheric depth    = ~400 km         Chromospheric depth   = ~2500 km
--   Sunspot cycle         = 11.4 yr         Cycle 22 sunspot min. =  1991 A.D.
-- 
--   Motn. rel to nrby strs= apex : RA=271 deg; DEC=+30 deg
--                           speed: 19.4 km/s = 0.0112 AU/day
--   Motn. rel to 2.73K BB = apex : l=264.7+-0.8; b=48.2+-0.5
--                           speed: 369 +-11 km/s
-- *******************************************************************************
--  
-- 
--  
-- 
-- *******************************************************************************
-- Ephemeris / WWW_USER Mon Mar 14 21:43:24 2016 Pasadena, USA      / Horizons    
-- *******************************************************************************
-- Target body name: Sun (10)                        {source: DE431mx}
-- Center body name: Earth (399)                     {source: DE431mx}
-- Center-site name: GEOCENTRIC
-- *******************************************************************************
-- Start time      : A.D. 1995-Jan-01 00:00:00.0000 UT      
-- Stop  time      : A.D. 2020-Jan-01 00:00:00.0000 UT      
-- Step-size       : 1440 minutes
-- *******************************************************************************
-- Target pole/equ : IAU_SUN                         {East-longitude +}
-- Target radii    : 696000.0 x 696000.0 x 696000.0 k{Equator, meridian, pole}    
-- Center geodetic : 0.00000000,0.00000000,0.0000000 {E-lon(deg),Lat(deg),Alt(km)}
-- Center cylindric: 0.00000000,0.00000000,0.0000000 {E-lon(deg),Dxy(km),Dz(km)}
-- Center pole/equ : High-precision EOP model        {East-longitude +}
-- Center radii    : 6378.1 x 6378.1 x 6356.8 km     {Equator, meridian, pole}    
-- Target primary  : Sun
-- Vis. interferer : MOON (R_eq= 1737.400) km        {source: DE431mx}
-- Rel. light bend : Sun, EARTH                      {source: DE431mx}
-- Rel. lght bnd GM: 1.3271E+11, 3.9860E+05 km^3/s^2                              
-- Atmos refraction: NO (AIRLESS)
-- RA format       : HMS
-- Time format     : CAL 
-- EOP file        : eop.160314.p160605                                           
-- EOP coverage    : DATA-BASED 1962-JAN-20 TO 2016-MAR-14. PREDICTS-> 2016-JUN-04
-- Units conversion: 1 au= 149597870.700 km, c= 299792.458 km/s, 1 day= 86400.0 s 
-- Table cut-offs 1: Elevation (-90.0deg=NO ),Airmass (>38.000=NO), Daylight (NO )
-- Table cut-offs 2: Solar Elongation (  0.0,180.0=NO ),Local Hour Angle( 0.0=NO )
-- *******************************************************************************
-- 
--  data has been adjusted to fit sql input standards. For example,
--   1995-Jan-01 00:00     349.03  -2.99
--  becomes
--  1995-01-01;00:00;349.03;-2.99

CREATE TABLE soa_solar_tilt (
       --- yyyy-mm-dd
       date date,
       -- center of the event orientation
       time_utc time without time zone,
       -- observer is at Sun, negative means Earth is below Solar equator
       -- observer_longitude
       ob_lon numeric,
       -- observer_latitude 
       ob_lat numeric
);

CREATE index soa_solar_tilt_date_idx on soa_solar_tilt (date);


--  
--  Magnetometer values are in GSM coordinates.
--  Units: Bx, By, Bz, Bt in nT
--  Units: Latitude  degrees +/-  90.0
--  Units: Longitude degrees 0.0 - 360.0
--  Status(S): 0 = nominal data, 1 to 8 = bad data record, 9 = no data
--  Missing data values: -999.9
--  Source: ACE Satellite - Magnetometer
-- 
--               Hourly Averaged Real-time Interplanetary Magnetic Field Values 
--  
--                  Modified Seconds
--  UT Date   Time  Julian   of the   ----------------  GSM Coordinates ---------------
--  YR MO DA  HHMM    Day      Day    S     Bx      By      Bz      Bt     Lat.   Long.
-- ------------------------------------------------------------------------------------
CREATE TABLE soa_ace_mag (
       -- yyyy-mm-dd
       date date,
       -- hh::mm
       time_utc time without time zone,
       -- seconds
       duration_s integer,
       --  Status(S): 0 = nominal data, 1 to 8 = bad data record, 9 = no data
       status varchar(1),
       -- Bx ie magnentic field x-axis
       bx numeric,
       -- By ie ma...
       by numeric,
       bz numeric,
       bt numeric,
       latitude numeric,
       longitude numeric
);

CREATE index soa_ace_mag_date_idx on soa_ace_mag (date);

-- Data originally 
-- prepared by the U.S. Dept. of Commerce, NOAA, Space Weather Prediction Center
-- Units: Proton density p/cc
-- Units: Bulk speed km/s
-- Units: Ion tempeture degrees K
-- Status(S): 0 = nominal data, 1 to 8 = bad data record, 9 = no data
-- Missing data values: Density and Speed = -9999.9, Temp. = -1.00e+05
-- Source: ACE Satellite - Solar Wind Electron Proton Alpha Monitor
--
--   Hourly Averaged Real-time Bulk Parameters of the Solar Wind Plasma
-- 
--                Modified Seconds   -------------  Solar Wind  -----------
-- UT Date   Time  Julian  of the          Proton      Bulk         Ion
-- YR MO DA  HHMM    Day     Day     S    Density     Speed     Temperature
---------------------------------------------------------------------------
CREATE TABLE soa_ace_swepam (
       -- yyyy-mm-dd
       date date,
       -- hh::mm
       time_utc time without time zone,
       -- seconds
       duration_s integer,
       --  Status(S): 0 = nominal data, 1 to 8 = bad data record, 9 = no data
       status varchar(1),
       proton_density numeric,
       bulk_speed numeric,
       -- ion temperature
       ion_temp numeric
);

CREATE index soa_ace_swepam_date_idx on soa_ace_swepam (date);

-- Data originally
-- prepared by the U.S. Dept. of Commerce, NOAA, Space Weather Prediction Center
-- Units: Differential Flux particles/cm2-s-ster-MeV
-- Units: Anisotropy Index 0.0 - 2.0
-- Status(S): 0 = nominal, 4,6,7,8 = bad data, unable to process, 9 = no data
-- Missing data values: -1.00e+05, index = -1.00
-- Source: ACE Satellite - Electron, Proton, and Alpha Monitor
--
--                      Hourly Averaged Real-time Differential Electron and Proton Flux 
-- 
--                Modified Seconds ---------------------------- Differential Flux ---------------------------
-- UT Date   Time  Julian  of the  ----- Electron -----   ------------------- Protons keV -------------------  Anis.
-- YR MO DA  HHMM    Day    Day    S    38-53   175-315   S    47-68   115-195   310-580   795-1193 1060-1900  Index
--------------------------------------------------------------------------------------------------------------------
CREATE TABLE soa_ace_epam (
       -- yyyy-mm-dd
       date date,
       -- hh::mm
       time_utc time without time zone,
       -- seconds
       duration_s integer,
       -- Electron Status(S): 0 = nominal, 4,6,7,8 = bad data, unable to process, 9 = no data
       e_status varchar(1),
       -- values are Differential Flux:
       -- 38 to 53
       electron_46 numeric,
       -- 175 to 315
       electron_245 numeric,
       -- proton status
       p_status varchar(1),
       -- 47 to 68
       proton_58 numeric,
       -- 175 to 315
       proton_155 numeric,
       -- 310 to 580
       proton_445 numeric,
       -- 795 to 1193
       proton_644 numeric,
       -- 1060 to 1900
       proton_1480 numeric,
       -- anistropy index
       anistropy_idx numeric
);

CREATE index soa_ace_epam_date_idx on soa_ace_epam (date);

-- Data originally
-- prepared by the U.S. Dept. of Commerce, NOAA, Space Weather Prediction Center
-- Please send comments and suggestions to SWPC.Webmaster@noaa.gov 
-- 
-- Units: X, Y, and Z position in GSE coordinates in earth radii(Re)
--        Accuracy 0.1 earth radii (about 600 km)
-- Range: X 0.0 to 300.0
-- Range: Y and Z -200.0 to 200.0
-- Missing data values: -999.9
--
--    Predicted ACE Satellite Locations in GSE Coordinates
-- 
--                 Modified Seconds
-- UT Date   Time  Julian   of the    --- GSE Coordinates ---
-- YR MO DA  HHMM    Day      Day       X        Y        Z
-------------------------------------------------------------
CREATE TABLE soa_ace_loc (
       -- yyyy-mm-dd
       date date,
       -- hh::mm
       time_utc time without time zone,
       -- seconds, refers to change in time per data point
       duration_s integer,
       x_gse numeric,
       y_gse numeric,
       z_gse numeric
);

CREATE index soa_ace_loc_date_idx on soa_ace_loc (date);


-- Prepared by the U.S. Dept. of Commerce, NOAA, Space Weather Prediction Center
-- Please send comments and suggestions to SWPC.Webmaster@noaa.gov 
-- 
-- Units: proton flux p/cs2-sec-ster
-- Status(S): 0 = nominal data, 1 to 8 = bad data record, 9 = no data
-- Missing data values: -1.00e+05
-- Source: ACE Satellite - Solar Isotope Spectrometer
--
-- Hourly Averaged Real-time Integral Flux of High-energy Solar Protons
-- 
--                 Modified Seconds
-- UT Date   Time   Julian  of the     ---- Integral Proton Flux ----
-- YR MO DA  HHMM     Day     Day      S    > 10 MeV    S    > 30 MeV
---------------------------------------------------------------------
CREATE TABLE soa_ace_sis (
       -- yyyy-mm-dd
       date date,
       -- hh:mm
       time_utc time without time zone,
       -- seconds, refers to change in time per data point
       duration_s integer,
       --  Status(S): 0 = nominal data, 1 to 8 = bad data record, 9 = no data
       status_10 varchar(1),
       -- integral proton flux greater than 10MeV
       ipf_gt_10 numeric,
       status_30 varchar(1),
       -- integral proton flux greater than 30MeV
       ipf_gt_30 numeric
);

CREATE index soa_ace_sis_date_idx on soa_ace_sis (date);


-- Activity index for Tromso
-- The activity index is the absolute mean deviation from last 24 hrs mean H
CREATE TABLE soa_tromsoe_mag (
       -- yyyy-mm-dd
       date date,
       -- hh:mm
       time_utc time without time zone,
       -- seconds, refers to change in time per data point
       duration_s integer,
       -- -99 means data not available
       mag_index numeric
);

CREATE index soa_tromsoe_mag_date_idx on soa_tromsoe_mag (date);

