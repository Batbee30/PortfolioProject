select *
From Portfolia..online_retail_IIi;

--Which year had highiest sales?
select 
Year(InvoiceDate) as SalesYear, 
Format(SUM(Quantity*Price),  'C', 'en-US') as TotalSales
From Portfolia..online_retail_IIi
Where ISNUMERIC(Price)=1 AND ISNUMERIC(Quantity)=1 
AND Year(InvoiceDate) IS NOT NULL

Group by Year(InvoiceDate)
Order by TotalSales DESC;

--Sales during Holiday
with SalesByMonth as (
select
Year(InvoiceDate) as SalesYear,
Month(InvoiceDate) as SalesMonth,
SUM(Quantity*Price) as TotalSales
From Portfolia..online_retail_IIi
where ISNUMERIC(Price)=1 AND ISNUMERIC(Quantity)=1
group by Year(InvoiceDate), Month(InvoiceDate)
),
SalesGrouped AS (
    SELECT 
        SalesYear,
        CASE 
            WHEN SalesMonth IN (11, 12) THEN 'Christmas Holiday'
			WHEN SalesMonth IN (3, 4) THEN 'Easter Holiday'
            ELSE 'NonHoliday'
        END AS Season,
        SUM(TotalSales) AS SeasonSales
    FROM 
        SalesByMonth
    GROUP BY 
        SalesYear,
        CASE 
            WHEN SalesMonth IN (11, 12) THEN 'Christmas Holiday' 
			WHEN SalesMonth IN (3, 4) THEN 'Easter Holiday'
            ELSE 'NonHoliday'
        END
)
SELECT 
    SalesYear,
    format(MAX(CASE WHEN Season = 'Christmas Holiday'  AND SeasonSales IS NOT NULL THEN SeasonSales END), 'C', 'en-US') AS ChristmasSales,
    format(MAX(CASE WHEN Season = 'Easter Holiday'  AND SeasonSales IS NOT NULL THEN SeasonSales END),'C', 'en-US') AS EasterSales,
    format(MAX(CASE WHEN Season = 'NonHoliday'  AND SeasonSales IS NOT NULL THEN SeasonSales END),'C', 'en-US') AS NonHolidaySales
FROM SalesGrouped
where SalesYear IS NOT NULL
group by SalesYear
Order By SalesYear DESC;

