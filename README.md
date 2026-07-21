# 📊 Global Retail Sales Analysis

## 📌 Project Overview
End-to-end business intelligence project using SQL, Excel, and Power BI to analyze retail sales, customer behavior, product performance, and revenue trends, helping identify actionable business opportunities

## 🎯 Business Problem
Retail businesses generate thousands of transactions every year, but raw data alone can not answer critical business question such as:
Which Customer generate the most revenue?
Are repeat customers more valuable than new customers?
Which Products or categories drive profitability?
How have Sales changed overtime?
what opportunities exist to increase revenue?

## 📂 Dataset Overview
| Attribute    |    Details |
|---------------|--------------|
| **Dataset Name**  | Global Retail Sales Dataset |
| **Total Records**       | 62884 |
| **Total Customers**     | 15266 |
| **Total Products**      | 2517 |
| **Total Stores**        | 67 |
| **File Format** | CSV |

## 📂 Dataset Structure

The analysis is based on four interconnected tables that together provide a complete view of the retail business.

| Table | Description |
|--------|-------------|
| **Sales** | Transaction-level sales data including order details, revenue, quantity, unit price, and sales dates. |
| **Products** | Product information such as product name, category, subcategory, brand, and cost. |
| **Customers** | Customer details including customer ID, demographics, and location. |
| **Stores** | Store information including store ID, store name, city, state, country, and store attributes. | 

### 🧹 Data Preparation

Before analysis, the dataset was prepared by:

- Validating missing values
- Checking duplicate records
- Standardizing data types
- Creating calculated metrics
- Transforming data using Power Query and SQL

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| SQL (PostgreSQL) | Data extraction, cleaning, and business analysis |
| Power BI | Interactive dashboard development and visualization |
| Python | Data transformation and preprocessing |
| Microsoft Excel | Initial data exploration and validation |

## 🚀 Skills Demonstrated

- SQL Joins
- CTEs
- Window Functions
- Aggregate Functions
- Data Cleaning
- Data Validation
- Power BI Dashboarding
- Business Analysis


## 📋 Business Requirements

The objective of this project is to answer key business questions, including:

- How is overall sales performance changing over time?
- Which products generate the highest revenue and profit?
- Who are the most valuable customers?
- Which stores perform the best?
- How do repeat customers contribute to business growth?
- What purchasing patterns can be identified from customer behavior?
- Which product categories require greater business focus?
  
## 📈 Key Performance Indicators (KPIs)

- Total Revenue
- Total Orders
- Total Customers
- Average Order Value
- Median Order Value
- Total Profit
- Repeat Customer Rate

## 📊 Analysis Performed

### 📈 Sales Analysis
- Analyzed overall sales, revenue, profit, and order performance.
- Evaluated monthly and yearly sales trends to identify business growth patterns.
- Compared online and offline sales channels to measure their contribution to total revenue.

### 📦 Product Analysis
- Identified top-performing and underperforming product categories and subcategories.
- Performed year-over-year category performance analysis to identify growth and declining segments.
- Evaluated product contribution to overall business revenue.

### 👥 Customer Analysis
- Analyzed new vs. existing customers to evaluate customer acquisition and retention.
- Identified high-value customer segments based on purchasing behavior.
- Evaluated inactive customers to identify customer re-engagement opportunities.

### 🏪 Store & Regional Analysis
- Compared sales performance across different stores and regions.
- Identified top-performing markets and underperforming locations.
- Analyzed regional revenue contribution to overall business performance.

### 📈 Trend Analysis
- Analyzed monthly and yearly business trends to identify seasonality.
- Evaluated customer and order growth over time.
- Compared year-over-year category performance to identify business growth opportunities.

### 💡 Opportunity Analysis
- Identified declining product categories requiring strategic improvements.
- Analyzed untapped customer opportunities, including registered customers with no purchases.
- Developed actionable business insights and recommendations based on analytical findings.

## 📊 Dashboard Preview

### Overall Performance Dashboard

- 📊 [Overall Performance Dashboard](Overall_Performance_Dashboard.png)

---

### Top Contributors Analysis

- 👥 [Top Contributors Dashboard](Top_Contrubutors_Dasboard.png)

---

### Opportunities Analysis

- 🎯 [Opportunity Dashboard](Opportunity_Dashboard.png)

### 📊 Dashboard Features

- Interactive slicers
- Drill-through
- Tooltips
- Dynamic KPIs
- Responsive visuals

### ⚠️ Dataset Limitations

- Dataset ends in 2020.
- Customer acquisition source not available.
- Revenue decline root cause cannot be confirmed from available data.

## 💡 Key Business Insights

- A large portion of the customer base became inactive after their last purchase in **2019**, highlighting a significant opportunity for customer re-engagement.

- Online sales increased by **6.49 percentage points**, reflecting the growing importance of digital channels in the overall sales mix.

- Demand for the **Home Appliances** category declined over time, while **Computers** and **Cell Phones** experienced strong growth, indicating changing customer preferences.

- Sales consistently declined during **April** across all years, suggesting a recurring seasonal slowdown in demand.

- Customers aged **60+** generated the highest revenue and placed the highest number of orders, making them the most valuable customer segment.

- The share of **existing customers** increased over time, while the proportion of **new customers** declined, indicating stronger customer retention but slowing customer acquisition.

- Australia has the **second-highest number of registered customers who have never made a purchase**, highlighting a strong opportunity to convert registered users into first-time buyers.

- The dataset does not provide sufficient information to determine the exact cause of the revenue decline. However, the decline in new customer acquisition, despite stable customer retention, may have contributed to the overall slowdown.

- Average Orders per Customer (**AOPC**) varies across countries and age groups, indicating that purchasing behavior differs by market and customer demographics.
---

## 🚀 Business Recommendations

- Launch personalized marketing campaigns and product recommendations to re-engage customers who became inactive, particularly those whose last purchase was in **2019**.

- Continue investing in digital marketing initiatives and exclusive online promotions to further accelerate online sales growth.

- Investigate potential data quality or data entry issues related to unusual purchasing patterns among customers under **18** in the **Home Appliances** category. Additionally, prioritize retention campaigns for middle-aged and older customers, who represent the primary customer base for this category.

- Strengthen customer acquisition initiatives while maintaining effective customer retention strategies to support sustainable business growth.

- Conduct customer surveys and analyze customer reviews to understand changing customer preferences and identify the factors contributing to the decline in the **Home Appliances** category.

- Implement country-specific marketing and retention strategies by targeting the age group with the highest purchase frequency in each market, while using broader engagement campaigns in countries with similar purchasing behavior across age groups.

- Execute customer re-engagement campaigns across all markets, while prioritizing countries with a higher concentration of inactive customers, such as **Australia**, to maximize campaign effectiveness.---

## 📂 Repository Structure

```text
sql/
powerbi/
images/
dataset/
README.md
```

---

---

## 👤 Author

Hempreet Singh

## LinkedIn: https://www.linkedin.com/in/hempreet-singh-8543b4247/
## GitHub: https://github.com/hempreetsingh21122-rgb
