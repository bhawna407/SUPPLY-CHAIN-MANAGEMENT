**Supply Chain Management Analysis: Service Level Tracking**

**1. PROJECT BACKGROUND**
AtliQ Mart is a growing FMCG manufacturer headquartered in Gujarat, India, with operations currently based in Surat, Ahmedabad, and Vadodara. With plans to expand into Tier 1 cities and metros within the next two years, the company has hit a critical roadblock: key customers are refusing to renew annual contracts.

The primary reason cited is poor service levels—specifically, failures in delivering essential products On Time and In Full (OTIF). This project was initiated to help the supply chain analytics team track delivery performance daily, allowing management to resolve service issues before scaling operations.

**2. KEY INSIGHTS**
Performance vs. Target: The overall OTIF % (On-Time In-Full) is significantly below the target across all cities, explaining the recent friction with contract renewals.

City-Wise Variation: While Surat shows higher delivery efficiency in some categories, Vadodara consistently struggles with the lowest On-Time (OT) %, indicating localized logistics bottlenecks.

Customer Sensitivity: High-value customers like Lotus Mart and Coolblue have experienced OTIF % as low as 20-22%, making them high-risk accounts for churn.

Category Lag: The Food and Beverages categories show a higher frequency of "Late" and "Incomplete" deliveries compared to Dairy, likely due to shorter shelf lives or higher demand volatility.

Lead Time Consistency: The Average Days to Deliver stands at 0.42, but the high volume of 16K Late Orders suggests that while the average is low, the variance in delivery times is unacceptably high.

**3. STRATEGIC RECOMMENDATIONS**
Warehouse Optimization: Implement a prioritized dispatch system for Lotus Mart and Coolblue to restore service levels to the 90%+ OTIF threshold immediately.

Route Review in Vadodara: Conduct a deep dive into the Vadodara distribution network to identify why OT % lags behind Surat and Ahmedabad.

Safety Stock Adjustments: Increase safety stock levels for the Food and Beverage categories to improve the In-Full (IF) % and reduce partial shipments.

Real-time Alert System: Integrate an automated notification system that flags orders as "At Risk" the moment they miss their scheduled dispatch window.

An interactive Power BI Dashboard can be downloaded HERE.

The SQL Queries utilized to inspect and perform quality checks can be found HERE.

SQL Queries utilized to clean, organize, and prepare data for the dashboard can be found HERE.

Targeted SQL Queries regarding various business questions and deeper analysis can be found HERE.

**Data Structure & Initial Checks**
AtliQ Mart'S database structure as seen below consists of 6 tables: dim_customers, dim_date, dim_products, dim_target_orders, fact_order_lines, fact_order_aggregate with a total row count of 508,627 records.

Prior to the beginning of the analysis, a variety of chechks were conducted for quality control & familizarization with the datasets. The SQL Queries utilized to inspect & perform quality checks can be found here.

**Executive Summary**
**Overview of Findings**

AtliQ Mart’s objective to expand into Tier 1 cities is currently compromised by a significant decline in service reliability, leading to the potential loss of key annual contracts. Analysis of current supply chain performance reveals that the company is operating well below its target service levels, with an overall On-Time (OT) % of 59.03% and an In-Full (IF) % of 52.78%, resulting in a critical On-Time In-Full (OTIF) % of only 29.02%. While the Volume Fill Rate (VOFR) remains high at 96.59%, the Line Fill Rate (LIFR) lags at 65.96%, indicating that while most of the total quantity is delivered, individual product lines within orders are frequently missing or delayed. High-risk customers like Lotus Mart, Coolblue, and Acclaimed Stores are experiencing the most severe service gaps, with average delivery delays of 0.42 days beyond the agreed-upon dates. To stabilize operations for future expansion, AtliQ Mart must prioritize inventory optimization for the Dairy category (which shows the lowest fill rates) and implement urgent logistics interventions in Vadodara, the city currently showing the weakest performance across all key delivery metrics.

Below is the overview page from the Power BI dashboard, and more examples are included throughout the report. The entire interactive dashboard can be downloaded HERE.
