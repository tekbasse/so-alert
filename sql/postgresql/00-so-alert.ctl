\copy soa_earthquakes from '[acs_root_dir]/packages/so-alert/sql/common/IEBQuakesExport-to-20160213.dat' delimiter ';' null as ''
\copy soa_soli_input from '[acs_root_dir]/packages/so-alert/sql/common/sdo.dat' delimiter ';' null as ''
\copy soa_soli_input from '[acs_root_dir]/packages/so-alert/sql/common/soho-ii.dat' delimiter ';' null as ''
\copy soa_neo_ca from '[acs_root_dir]/pacakgs/so-alert/sql/common/neo-db-20120226.dat' delimter ';' null as ''
