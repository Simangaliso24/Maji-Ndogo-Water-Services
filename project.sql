-- =========================================================
-- Project 4: Maji Ndogo Water Services Analysis 💧
-- Database: md_water_services
-- =========================================================

-- Select the database
USE md_water_services;

-- =========================================================
-- Step 1: Join location and visits tables 🗺️
-- This gives us location details for each visit
-- =========================================================
SELECT l.province_name, l.town_name, v.visit_count, v.location_id
FROM visits AS v
JOIN location AS l
  ON l.location_id = v.location_id;

-- =========================================================
-- Step 2: Join water_source table to visits 💧
-- Add type_of_water_source and number_of_people_served
-- =========================================================
SELECT l.province_name, l.town_name, v.visit_count, v.location_id,
       w.type_of_water_source, w.number_of_people_served
FROM visits AS v
JOIN location AS l
  ON l.location_id = v.location_id
JOIN water_source AS w
  ON v.source_id = w.source_id;

-- =========================================================
-- Step 3: Filter for single visits only 🔍
-- =========================================================
SELECT l.province_name, l.town_name, w.type_of_water_source,
       l.location_type, w.number_of_people_served, v.time_in_queue
FROM visits AS v
JOIN location AS l
  ON l.location_id = v.location_id
JOIN water_source AS w
  ON v.source_id = w.source_id
WHERE v.visit_count = 1;

-- =========================================================
-- Step 4: Include well pollution results 🧪
-- LEFT JOIN ensures wells without pollution data still appear
-- =========================================================
SELECT l.province_name, l.town_name, w.type_of_water_source,
       l.location_type, w.number_of_people_served, v.time_in_queue,
       wp.results AS well_pollution
FROM visits AS v
LEFT JOIN well_pollution AS wp
  ON wp.source_id = v.source_id
INNER JOIN location AS l
  ON l.location_id = v.location_id
INNER JOIN water_source AS w
  ON v.source_id = w.source_id
WHERE v.visit_count = 1;

-- =========================================================
-- Step 5: Create combined_analysis_table view 📋
-- Consolidates all relevant columns for analysis
-- =========================================================
CREATE VIEW combined_analysis_table AS
SELECT l.province_name, l.town_name, w.type_of_water_source,
       l.location_type, w.number_of_people_served, v.time_in_queue,
       wp.results AS well_pollution
FROM visits AS v
LEFT JOIN well_pollution AS wp
  ON wp.source_id = v.source_id
INNER JOIN location AS l
  ON l.location_id = v.location_id
INNER JOIN water_source AS w
  ON v.source_id = w.source_id
WHERE v.visit_count = 1;

-- =========================================================
-- Step 6: Province-level aggregation 📊
-- Calculates total population per province and water source percentages
-- =========================================================
WITH province_totals AS (
    SELECT province_name, SUM(number_of_people_served) AS total_ppl_serv
    FROM combined_analysis_table
    GROUP BY province_name
)
SELECT ct.province_name,
       ROUND((SUM(CASE WHEN type_of_water_source = 'river'
                  THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
       ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
                  THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
       ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
                  THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
       ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
                  THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
       ROUND((SUM(CASE WHEN type_of_water_source = 'well'
                  THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN province_totals pt
  ON ct.province_name = pt.province_name
GROUP BY ct.province_name
ORDER BY ct.province_name;

-- =========================================================
-- Step 7: Town-level aggregation 🏘️
-- =========================================================
WITH town_totals AS (
    SELECT province_name, town_name, SUM(number_of_people_served) AS total_ppl_serv
    FROM combined_analysis_table
    GROUP BY province_name, town_name
)
SELECT ct.province_name, ct.town_name,
       ROUND((SUM(CASE WHEN type_of_water_source = 'river'
                  THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
       ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
                  THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
       ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
                  THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
       ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
                  THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
       ROUND((SUM(CASE WHEN type_of_water_source = 'well'
                  THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN town_totals tt
  ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY ct.province_name, ct.town_name
ORDER BY ct.town_name;

-- =========================================================
-- Step 8: Create temporary table for town-level water access ⚡
-- =========================================================
CREATE TEMPORARY TABLE town_aggregated_water_access AS
WITH town_totals AS (
    SELECT province_name, town_name, SUM(number_of_people_served) AS total_ppl_serv
    FROM combined_analysis_table
    GROUP BY province_name, town_name
)
SELECT ct.province_name, ct.town_name,
       ROUND((SUM(CASE WHEN type_of_water_source = 'river'
                  THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
       ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
                  THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
       ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
                  THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
       ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
                  THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
       ROUND((SUM(CASE WHEN type_of_water_source = 'well'
                  THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN town_totals tt
  ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY ct.province_name, ct.town_name
ORDER BY ct.town_name;

-- =========================================================
-- Step 9: Calculate % of broken taps per town 🚰
-- =========================================================
SELECT province_name, town_name,
       ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100, 0) AS pct_broken_taps
FROM town_aggregated_water_access;

-- =========================================================
-- Step 10: Create Project_progress table for engineers 🛠️
-- =========================================================
CREATE TABLE Project_progress (
    Project_id SERIAL PRIMARY KEY,
    source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    Address VARCHAR(50),
    Town VARCHAR(30),
    Province VARCHAR(30),
    Source_type VARCHAR(50),
    Improvement VARCHAR(50),
    Source_status VARCHAR(50) DEFAULT 'Backlog'
        CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
    Date_of_completion DATE,
    Comments TEXT
);

-- =========================================================
-- Step 11: Populate Project_progress query 🔧
-- =========================================================
SELECT
    location.address,
    location.town_name,
    location.province_name,
    water_source.source_id,
    CASE
        WHEN water_source.type_of_water_source = 'river' THEN 'Drill well'
        WHEN water_source.type_of_water_source = 'shared_tap' THEN 'Install X taps'
        WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose infrastructure'
        ELSE NULL
    END AS type_of_water_source,
    CASE
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter'
        ELSE NULL
    END AS results
FROM water_source
LEFT JOIN well_pollution 
  ON water_source.source_id = well_pollution.source_id
INNER JOIN visits 
  ON water_source.source_id = visits.source_id
INNER JOIN location 
  ON location.location_id = visits.location_id
WHERE visits.visit_count = 1
  AND (well_pollution.results != 'Clean'
       OR water_source.type_of_water_source IN ('tap_in_home_broken', 'river')
       OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
 );

