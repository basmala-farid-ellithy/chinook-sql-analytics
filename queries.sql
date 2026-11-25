-- 1. Revenue by year with year-over-year growth (CTE + LAG)
WITH yearly AS (
  SELECT strftime('%Y', InvoiceDate) AS yr, ROUND(SUM(Total),2) AS revenue
  FROM Invoice GROUP BY yr)
SELECT yr, revenue,
       ROUND(100.0*(revenue - LAG(revenue) OVER (ORDER BY yr)) / LAG(revenue) OVER (ORDER BY yr),1) AS yoy_pct
FROM yearly ORDER BY yr;

-- 2. Top 5 countries by revenue with share of total (window SUM)
SELECT BillingCountry, ROUND(SUM(Total),2) AS revenue,
       ROUND(100.0*SUM(Total)/SUM(SUM(Total)) OVER (),1) AS pct_of_total
FROM Invoice GROUP BY BillingCountry ORDER BY revenue DESC LIMIT 5;

-- 3. Top 3 genres per country by revenue (RANK partitioned)
WITH g AS (
  SELECT i.BillingCountry AS country, ge.Name AS genre, ROUND(SUM(il.UnitPrice*il.Quantity),2) AS revenue
  FROM InvoiceLine il JOIN Invoice i USING(InvoiceId)
  JOIN Track t USING(TrackId) JOIN Genre ge USING(GenreId)
  GROUP BY country, genre),
r AS (SELECT *, RANK() OVER (PARTITION BY country ORDER BY revenue DESC) AS rnk FROM g)
SELECT country, genre, revenue FROM r WHERE rnk<=3 AND country IN ('USA','Canada','Brazil') ORDER BY country, rnk;

-- 4. Customer lifetime value: top 10 customers and their spend tier (NTILE)
WITH c AS (
  SELECT cu.CustomerId, cu.FirstName||' '||cu.LastName AS customer, cu.Country,
         ROUND(SUM(i.Total),2) AS lifetime_value
  FROM Customer cu JOIN Invoice i USING(CustomerId) GROUP BY cu.CustomerId)
SELECT customer, Country, lifetime_value, NTILE(4) OVER (ORDER BY lifetime_value DESC) AS quartile
FROM c ORDER BY lifetime_value DESC LIMIT 10;

-- 5. Sales rep performance: customers handled and revenue per rep
SELECT e.FirstName||' '||e.LastName AS rep, COUNT(DISTINCT cu.CustomerId) AS customers,
       ROUND(SUM(i.Total),2) AS revenue
FROM Employee e JOIN Customer cu ON cu.SupportRepId=e.EmployeeId
JOIN Invoice i ON i.CustomerId=cu.CustomerId GROUP BY rep ORDER BY revenue DESC;

-- 6. Customers with no purchase in the last year of data (churn candidates)
SELECT cu.CustomerId, cu.FirstName||' '||cu.LastName AS customer, MAX(i.InvoiceDate) AS last_purchase
FROM Customer cu JOIN Invoice i USING(CustomerId)
GROUP BY cu.CustomerId
HAVING MAX(i.InvoiceDate) < (SELECT date(MAX(InvoiceDate),'-1 year') FROM Invoice)
ORDER BY last_purchase LIMIT 10;
