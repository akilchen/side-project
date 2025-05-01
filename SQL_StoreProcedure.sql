--預存程序1(各國活躍會員流失率KPI)
CREATE PROCEDURE SP_CRandACbyCountry
AS
BEGIN
select co.country_name, 
	   ROUND(CONVERT(float,SUM(CASE WHEN mb.churn = 1 THEN 1 ELSE 0 END))/CONVERT(float,COUNT(mb.churn))*100,2) AS avg_churn
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join membership mb on cu.customer_id = mb.customer_id
where mb.active_member = 1
group by co.country_name
order by avg_churn DESC
END

--執行預存程序1(各國活躍會員流失率KPI)
EXEC SP_CRandACbyCountry

--預存程序2(客戶風險狀態排名標記)
CREATE PROCEDURE SP_CRRiskRangeandLabel
AS
BEGIN
WITH CTE AS (
select 	cu.customer_id,
		cd.credit_score,
		RANK() OVER(ORDER BY cd.credit_score ASC) AS rank
from customers cu
inner join credit_data cd on cu.customer_id = cd.customer_id
)
select *,IIF(rank<=10,'*','') AS '高風險標記'
from CTE
END

--執行預存程序2(客戶風險狀態排名標記)
EXEC SP_CRRiskRangeandLabel

--預存程序3:各國平均估計年薪、信用分數與平均帳戶餘額
CREATE PROCEDURE SP_CountryAverages
AS
BEGIN
select co.country_name,
        ROUND(CONVERT(DECIMAL(12,2),AVG(cu.estimated_salary)),2) AS '平均預估年薪',
		ROUND(CONVERT(DECIMAL(12,2),AVG(cd.credit_score)),2) AS '平均信用分數', --用decimal才會出現小數點
	    ROUND(CONVERT(DECIMAL(12,2),AVG(po.balance)),2)      AS '平均帳戶餘額'  --用decimal才會控制到小數點第二位
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join credit_data cd on cu.customer_id = cd.customer_id
inner join products po on cu.customer_id = po.customer_id
GROUP BY co.country_name
END

--執行預存程序3(各國平均估計年薪、信用分數與平均帳戶餘額)
EXEC SP_CountryAverages