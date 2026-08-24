# Pizza-Sales-Analysis-Using-MySQL-and-Power-Bi

# 🍕 Pizza Sales Analysis — Plato's Pizza

**A two-part analysis of a year of transactional sales data for Plato's Pizza, a fictitious Greek-inspired pizzeria in Hazelwood — built as part of a Maven Analytics challenge.** The same dataset is analyzed two ways: a **Power BI dashboard** for exploratory, visual reporting, and a **MySQL EDA** that layers on a dual-metric segmentation approach to flag which menu items are actually worth keeping.

[PIzzaSales.sql] · [PizzaSalesPowerBi.pbix file]

---

## 📌 Project Overview

Acting as a BI Consultant hired by Plato's Pizza, this project turns a year of raw, multi-table transactional data into a decision-ready set of findings and recommendations — mirroring a real consulting engagement: messy relational data, no predefined KPIs, and a business that needed clear answers to "what's driving our sales, and what should we do about it?"

Most menu analyses rank items by volume sold *or* by revenue alone — and both can mislead. A high-volume item might be a low-margin loss leader; a high-revenue item might only look good because it has more SKUs than its competitors. So alongside the dashboard, this project also builds a **dual-metric segmentation approach in SQL** — evaluating products on both customer demand (quantity sold) *and* value generated (revenue), while accounting for size and category — to surface which pizzas deserve investment and which are dead weight on the menu.

**Business questions answered:**

- How much revenue did we generate this year, and is there seasonality?
- What's our average order value, and how price-sensitive are customers?
- When are we busiest — which days, and which rush hours — and are we staffed for it?
- Which pizzas should we cut — or double down on?
- Which pizza category generates the most revenue, and is that actually a fair comparison?
- Which products are underperforming on *both* volume and revenue, and should be reviewed or cut?

---

## 🗂️ Data

Four relational tables provided by Maven Analytics, joined on `Order_Id`, `Pizza_Id`, and `Pizza_Type_Id`:

| Table | Contents |
|---|---|
| `Orders` / `orders` | Order ID, date, time |
| `Order_Details` / `order_details` | Order-to-pizza mapping, quantity |
| `Pizzas` / `pizzas` | Pizza ID, size, price |
| `Pizza_Types` / `pizza_types` | Pizza name, category, ingredients |

In Power BI, the four tables were merged into a single **`PizzaSalesClean`** table — the foundation for the dashboard. In MySQL, the same four tables were loaded via the table data import wizard and joined directly within each query.

---

## 🧹 Data Cleaning & Preparation (Power Query)

- **Merged** four source tables into one clean fact table using Power Query's Merge Queries, joining on `order_id`, `pizza_id`, and `pizza_type_id`
- **Validated** data quality — no missing values or duplicates found
- **Standardized formats** — applied `PROPER()` for text consistency; converted fields to Date, Time, Number, and Currency types
- **Engineered calculated columns**, including:
  - `Total Revenue = SUMX(PizzaSalesClean, PizzaSalesClean[price] * PizzaSalesClean[total quantity])`
  - `Day = WEEKDAY(PizzaSalesClean[orders.date].[Date])` (i.e. 1-Sun, 2-Mon, 3-Tues, 4-Wed, 5-Thur, 6-Fri, 7-Sat)
  - `Hour = HOUR(PizzaSalesClean[orders.time])`
  - `Average Order Value = DIVIDE(PizzaSalesClean[Total Revenue], DISTINCTCOUNT(PizzaSalesClean[order_id]), 0)`
  - `Total quantity = SUM(PizzaSalesClean[quantity])`

---

## 🛠️ SQL Methodology

The MySQL EDA was conducted entirely in SQL using:

- **Aggregations** (`SUM`, `COUNT`, `AVG`, `ROUND`)
- **`CASE WHEN`** for day-of-week labeling
- **CTEs** for per-order value calculation
- **`HAVING`** clauses to filter underperforming products against a defined threshold

The "weak SKU" threshold (**< 800 units sold AND < R10,000 revenue**) was set analyst-side as a starting point — adjusting either threshold changes the population of flagged items, and is a natural next tuning step.

---

## 📊 Dashboard KPIs

| Peak Month | Total Customers | Pizza Types | Pizzas Sold | Avg Order Price | Total Revenue |
|---|---|---|---|---|---|
| July (4,301 orders) | 21,350 | 32 | 50,000 | R38.31 | R817,860 |

## 🔍 Key Queries & Findings (SQL)

| # | Question | Finding |
|---|---|---|
| 1 | Total revenue generated? | **R817,860.05** — primary KPI |
| 2 | Average order value? | **R38.31** — benchmark for combo/bundle pricing |
| 3 | Busiest days of the week? | **Friday, Thursday, Saturday** lead; Sunday is slowest |
| 4 | Rush hours? | Two peaks: **12:00–13:00** (lunch) and **17:00–19:00** (dinner) |
| 5 | Best-selling category by revenue? | **Classic** leads — but likely because it has more SKUs, not because each item outperforms |
| 6–9 | Top 5 pizzas per category | Identified for Classic, Supreme, Chicken, and Veggie |
| 10–11 | Weak products (low volume *and* low revenue) | **65 product–size combinations** flagged for review |

Full queries and outputs are in (./PizzaSales.sql).

---

## 🔍 Key Insights

**Seasonality:** July is the clear peak month (4,301 orders) — worth investigating whether this was driven by promotions, seasonal demand, or marketing, so it can be replicated.

**Bestsellers:** The Classic Deluxe and Pepperoni pizzas dominate sales, showing customers favor familiar options. The Thai Chicken Pizza's strong performance points to appetite for bolder flavors as a potential growth area.

**Category mix:** Orders are fairly balanced across Classic (~30%), Chicken (~24%), Supreme (~24%), and Veggie (~22%) — Veggie is the weakest performer by volume. The SQL analysis confirms Classic leads by revenue too, but flags that this comparison is likely inflated by Classic simply having more SKUs than the other categories.

**Timing patterns:** Orders are steady across the week with a mid-week uptick (Thu–Sat) — confirmed in SQL as Friday, Thursday, and Saturday being the busiest days, with Sunday slowest. Daily demand peaks sharply at lunch (~12:00–13:00) and again in early evening (~17:00–19:00).

**Price sensitivity:** Most orders cluster in the R10–R20 range; there's a negative correlation between price and order volume, indicating a price-sensitive customer base.

**Weak SKUs:** Filtering for products selling fewer than 800 units *and* generating less than R10,000 in revenue flags **65 product–size combinations** — dead weight on the menu that a volume-only or revenue-only ranking would not have surfaced on its own.

---

## 💡 Recommendations

1. **Replicate the July peak** — audit what drove it (promotions, seasonality, marketing) and design a repeatable seasonal campaign.
2. **Promote bestsellers** — feature Classic Deluxe and Pepperoni prominently; bundle the top 5 into a "Customer Favourites" promo.
3. **Anchor combo pricing to AOV** — price bundles at R42–49 to nudge the R38.31 average upward without feeling like a jump.
4. **Staff to demand** — full coverage on Thu–Sat and during the two rush windows (11:00–14:00, 17:00–20:00); lighter staffing early-week and consider off-peak promotions to smooth demand.
5. **Run a structured menu audit on the 65 weak SKUs** — Improve / Reposition / Remove, prioritizing the bottom 20 by revenue, with a 90-day review window for anything repositioned.
6. **Normalize the category comparison** — calculate revenue-per-SKU so Classic (more menu options) isn't unfairly favored over Chicken or Veggie (fewer options); use the result to decide where to grow (e.g. expand Veggie, test premium upsells like Thai Chicken).
7. **Target slow days** — run Monday–Wednesday specials (e.g. a "Tuesday Special") to flatten the weekly demand curve and reduce ingredient waste.
8. **Address price sensitivity** — introduce value bundles and a loyalty program to increase order frequency.
9. **Extend to a 2×2 segmentation matrix** — classify every SKU into Stars / Cash Cows / Question Marks / Dogs by volume × revenue; this is the natural next step that fully operationalizes the project's dual-metric thesis.

---

## ⚠️ Known Limitations & Next Steps

This analysis was built strictly from the data provided — being upfront about its gaps is part of doing the analysis honestly:

- **No cost/margin data** — "weak" or underperforming here means low demand and low revenue, not necessarily low profitability; a low-volume premium item could still be worth keeping. Can't calculate true profit margin by pizza, only revenue.
- **No customer-level ID** — can't distinguish new vs. returning customers or measure retention.
- **Single location** — no geographic comparison possible.
- **Category revenue comparison is unadjusted for SKU count** — flagged in the category-revenue finding; the recommended fix (revenue-per-SKU) hasn't been run yet.
- **Weak-SKU threshold is a starting assumption, not a validated cutoff** — sensitivity testing on the 800-unit / R10k boundary would strengthen the recommendation.

*Next iteration: incorporate ingredient cost data to shift the analysis from revenue to margin (which would change some of the menu recommendations above), and build out the revenue-per-SKU normalization and full 2×2 BCG-style segmentation matrix referenced in the recommendations.*

---

## 🛠️ Tools Used

- **Power Query** — data merging, cleaning, and transformation
- **Power BI (DAX)** — calculated columns/measures and dashboard visualization
- **MySQL** — querying, aggregation, and dual-metric segmentation logic
- **Excel** — initial data inspection

---

## 📁 Repository Contents

```
├── README.md
├── PizzaSalesPowerBI.pbix              # Power BI file
├── Pizza_Sales_Analysis_Report.dox     # Static export of the dashboard
├── PizzaSales.sql                      # All 11 SQL queries, commented
├── Pizza+Place+Sales                   # Source tables (orders, order_details, pizzas, pizza_types)
```

---

## 👤 About This Project

Built by Portia as part of a data analytics portfolio, pairing a Power BI consulting-style dashboard with a SQL-based dual-metric segmentation analysis on the same dataset — demonstrating the ability to move from raw relational data, through Power Query cleaning and DAX measures, to a strategic, decision-ready menu segmentation framework end to end.
