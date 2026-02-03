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

**3. RECOMMENDATIONS**
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
![Dashboard](https://github.com/bhawna407/SUPPLY-CHAIN-MANAGEMENT/blob/main/executive%20summary%20supply%20chain%20mang.png)


AtliQ Mart’s objective to expand into Tier 1 cities is currently compromised by a significant decline in service reliability, leading to the potential loss of key annual contracts. Analysis of current supply chain performance reveals that the company is operating well below its target service levels, with an overall On-Time (OT) % of 59.03% and an In-Full (IF) % of 52.78%, resulting in a critical On-Time In-Full (OTIF) % of only 29.02%. While the Volume Fill Rate (VOFR) remains high at 96.59%, the Line Fill Rate (LIFR) lags at 65.96%, indicating that while most of the total quantity is delivered, individual product lines within orders are frequently missing or delayed. High-risk customers like Lotus Mart, Coolblue, and Acclaimed Stores are experiencing the most severe service gaps, with average delivery delays of 0.42 days beyond the agreed-upon dates. To stabilize operations for future expansion, AtliQ Mart must prioritize inventory optimization for the Dairy category (which shows the lowest fill rates) and implement urgent logistics interventions in Vadodara, the city currently showing the weakest performance across all key delivery metrics.

Below is the overview page from the Power BI dashboard, and more examples are included throughout the report. The entire interactive dashboard can be downloaded HERE.

**OVERALL SERVICE LEVEL PERFORMANCE**

![Dashboard](https://github.com/bhawna407/SUPPLY-CHAIN-MANAGEMENT/blob/main/service%20level%20supply%20chain%20mang.png)

This section evaluates the "Perfect Order" efficiency of AtliQ Mart against its internal targets. It highlights the massive gap between the company's current reality and its service goals.

**Metric Analysis**: The company is currently operating at an **OTIF % of 29.02%**, which is a staggering **36.89% below the target of 65.91%**.

**Order Reliability**: While the **On-Time (OT) % is 59.03%** and **In-Full (IF) % is 52.78%**, both are significantly underperforming, indicating that more than half of all customer orders are failing either the punctuality or the quantity requirement.

**Operational Strain**: With **13.11K** orders failing the **In-Full** criteria and **11.39K** orders failing the **On-Time** criteria, there is a systemic failure in matching production/logistics output with customer demand.

**PRODUCT FULFILLMENT & INVENTORY DYNAMICS**

![Dashboard](https://github.com/bhawna407/SUPPLY-CHAIN-MANAGEMENT/blob/main/product%20level%20perf.%20supply%20chain%20mang.png)

This analysis focuses on how well AtliQ Mart is filling individual lines and volumes, highlighting a discrepancy between total volume shipped and order accuracy.

**Fill Rate Disparity**: There is a notable gap between the **Volume Fill Rate (VOFR) of 96.59%** and the **Line Fill Rate (LIFR) of 65.96%**. This suggests that while AtliQ delivers the bulk of the requested quantity, they frequently miss specific product lines (SKUs) within an order.

**Category Stress**: The **Dairy** and **Food** categories are the primary drivers of volume, yet they suffer from high order incompletion. Missing even a single line in an FMCG order can lead to a "Service Failure" in the eyes of the retailer.

**Efficiency Metric**: The **Average Days to Deliver** is currently **0.42**, but the high **OT % gap** implies that deliveries are highly inconsistent—some arrive very fast while others are significantly delayed.

**CUSTOMER VULNERABILITY & CONTRACT RISK**

![Dashboard](https://github.com/bhawna407/SUPPLY-CHAIN-MANAGEMENT/blob/main/customer%20RISK%20Supply%20chain%20mang.png)

This section identifies which key partners are at the highest risk of churn due to the service issues mentioned in the project background.

**Critical Churn Risks**: **Lotus Mart, Coolblue, and Acclaimed Stores** are the most neglected customers, with **OTIF % scores** hovering between **20% and 23%**. This explains the speculation that "essential products were not delivered on time or in full."

**Service Inconsistency**: Even the "best" performing customers like Elite Mart only achieve an **OTIF % of ~32%**, which is still less than half of the acceptable service level, indicating no customer is currently receiving "Good" service.

**Priority Metric**: **Lotus Mart** has the highest volume of total orders but a very **low OTIF %**, making it the #1 priority for the supply chain team to prevent a major contract loss.

**GEOGRAPHIC PERFORMANCE BREAKDOWN**

![Dashboard](https://github.com/bhawna407/SUPPLY-CHAIN-MANAGEMENT/blob/main/geographical%20perf.%20supply%20chain%20mang.png)

An analysis of the three operational hubs (Ahmedabad, Surat, and Vadodara) to identify localized logistics bottlenecks.

**Regional Laggard**: **Vadodara** consistently shows the weakest performance, with the **lowest OT % (58.33%)** and **IF % (52.28%)**, leading to the worst regional **OTIF % of 28.51%**.

**Distribution Hub Comparison**: **Ahmedabad** and **Surat** are performing slightly better but still remain within a negligible margin of each other **(approx. 29-30% OTIF)**.

**Expansion Barrier**: Given that not a single city has reached even **50% of its OTIF target**, expanding to Tier 1 cities without fixing the **Vadodara and Ahmedabad logistics networks** would likely lead to a wider failure and brand damage.

**RECOMMENDATIONS**
Based on the uncovered insights, the following recommendations have been provided:

**Establish a "Priority Response Team" for Top-Tier Customers**: Immediate focus must be placed on **Lotus Mart, Coolblue,** and **Acclaimed Stores**. Since their **OTIF % (20-23%)** is dangerously low, assigning a dedicated supply chain coordinator to these accounts can help bridge the gap and prevent contract termination.

**Inventory Optimization for the Dairy Category**: Given the high volume and frequent "Incomplete" orders, AtliQ Mart should implement **Dynamic Safety Stock levels** specifically for Dairy products. Improving the **Line Fill Rate (LIFR)** here will have the most significant impact on overall **IF %**.

**Logistics Audit in Vadodara**: As the city with the lowest **OTIF % (28.51%)**, a deep-dive audit of the Vadodara distribution center is required. Investigating local traffic patterns, vehicle availability, and warehouse processing times is essential to bring it at par with Ahmedabad and Surat.

**Bridge the Gap between VOFR and LIFR**: The high **Volume Fill Rate (96.59%)** versus the **low Line Fill Rate (65.96%)** indicates that while bulk quantity is moving, specific items are missing. Management should shift KPIs from "Total Volume" to **"Order Completeness"** to ensure customers receive exactly what they requested.

**Real-Time OTIF Tracking Dashboard for Operations**: Deploy a simplified version of this Power BI Dashboard on the warehouse floor. By **tracking Daily OTIF metrics in real-time, supervisors can identify and expedite "Late" or "Incomplete" orders** before they leave the facility.

**Expansion Moratorium**: It is strongly recommended to **halt expansion into new Tier 1 cities** until the current **OTIF %** reaches a **minimum threshold of 50-55%**. Scaling a broken fulfillment process will only lead to brand dilution and further service failures.
