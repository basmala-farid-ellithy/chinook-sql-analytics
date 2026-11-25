# Chinook SQL Analytics

Business questions answered in SQLite on the public Chinook music-store database (11 tables: customers, invoices, tracks, employees). Focus: CTEs and window functions (LAG, RANK, NTILE, SUM OVER).

| # | Question | Techniques |
|---|----------|-----------|
| 1 | Revenue by year and YoY growth | CTE, LAG |
| 2 | Top countries and their share of revenue | SUM() OVER |
| 3 | Top 3 genres per country | RANK, PARTITION BY |
| 4 | Customer lifetime value and spend quartile | CTE, NTILE |
| 5 | Sales rep performance | multi-table JOIN |
| 6 | Customers with no purchase in the last year of data | HAVING, subquery |

## Highlights (see `results.txt`)
- The USA is 22.5% of revenue, Canada 13.1%. Rock, Latin and Metal lead in every top market.
- Yearly revenue is flat (about 450-480 per year; +7.1% in 2022, -5.6% in 2025).
- Jane Peacock's customers generate the most revenue (833 total).

## Run it
Download `Chinook_Sqlite.sql` from https://github.com/lerocha/chinook-database, then:
```
sqlite3 chinook.db < Chinook_Sqlite.sql
sqlite3 -header chinook.db < queries.sql
```
