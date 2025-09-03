Maji Ndogo Water Services Analysis 💧
Project Overview 📝

This project analyzes water services data in Maji Ndogo to identify infrastructure issues, water contamination, and instances of corruption. The goal is to transform raw data into actionable insights that guide engineers and decision-makers in improving water access for the community.

Database & Tools 🛠️

Database Name: md_water_services

Tools: MySQL / PostgreSQL (any SQL engine that supports standard SQL)

Techniques:

Joins (INNER JOIN, LEFT JOIN)

Common Table Expressions (CTEs)

Views

Aggregations and percentages

Conditional logic with CASE statements

How to Run ▶️

Restore the Database:

Extract database.zip and restore md_water_services to your SQL server.

Run Queries:

Open project4.sql in your SQL client.

Ensure the database is selected: USE md_water_services;
Run queries in order; they are commented to explain each step.

Check Outputs:

Aggregated tables and views summarize water access, broken taps, and well contamination.

The Project_progress table provides actionable steps for engineers.

Key Steps in the Analysis 📊

Joining Tables:

visits + location + water_source to combine data on water sources and their locations.

LEFT JOIN with well_pollution to include well contamination results.

Building the Combined View:

combined_analysis_table simplifies repeated analysis by consolidating all relevant columns.

Aggregations:

Province-level analysis with province_totals.

Town-level analysis with town_aggregated_water_access.

Actionable Insights:

Identify towns with high percentages of broken taps.

Detect wells contaminated with chemical or biological agents.

Calculate the population served by each type of water source per town/province.

Project Progress Tracking:

Project_progress table stores tasks for engineers, including repairs, improvements, and status tracking.

Key Insights 📈

Percentage of households using rivers, shared taps, taps in home, broken taps, and wells.

Towns with the highest number of broken taps or long queues.

Wells that require filtration due to contamination.

Data-driven decisions to address corruption and improve water access.

Conclusion ✅

This project demonstrates the power of SQL for real-world data analysis. By joining multiple tables, aggregating data, and applying conditional logic, we transformed raw data into meaningful insights. The resulting tables provide a clear roadmap for engineers and decision-makers to take action, improving water services and addressing corruption in Maji Ndogo.
