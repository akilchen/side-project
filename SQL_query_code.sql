--1.查詢每位客戶的customer_id、國家、信用分數、帳戶餘額、是否流失
select cu.customer_id,co.country_name,cd.credit_score,po.balance,mb.churn
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join credit_data cd on cu.customer_id = cd.customer_id
inner join products po on cu.customer_id = po.customer_id
inner join membership mb on cu.customer_id = mb.customer_id


--2.查詢產品數量大於2且持有信用卡的活躍會員名單
----顯示：customer_id、年齡、預估薪資、是否流失
select cu.customer_id,cu.age,cu.estimated_salary,mb.churn
from customers cu
inner join membership mb on cu.customer_id = mb.customer_id
inner join products po on cu.customer_id = po.customer_id
where po.products_number > 2 and po.credit_card = 1 and mb.active_member=1

--3.計算每個國家的平均估計年薪、信用分數與平均帳戶餘額。
select co.country_name,
        ROUND(CONVERT(DECIMAL(12,2),AVG(cu.estimated_salary)),2) AS '平均信用分數',
		ROUND(CONVERT(DECIMAL(12,2),AVG(cd.credit_score)),2) AS '平均信用分數', --用decimal才會出現小數點
	    ROUND(CONVERT(DECIMAL(12,2),AVG(po.balance)),2)      AS '平均帳戶餘額'  --用decimal才會控制到小數點第二位
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join credit_data cd on cu.customer_id = cd.customer_id
inner join products po on cu.customer_id = po.customer_id
GROUP BY co.country_name

--4.撈出每個國家內信用分數排名前3的客戶。
WITH CTE AS (
select co.country_name,
		cu.customer_id,
		cd.credit_score,
		RANK() OVER(PARTITION BY co.country_name ORDER BY cd.credit_score DESC) AS country_rank
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join credit_data cd on cu.customer_id = cd.customer_id
)
select *
from CTE
where country_rank <=3

--5.分析每一個國家內的平均信用分數(欄位名稱為avg_score_by_country)。
select co.country_name,
		CONVERT(DECIMAL(10,2),AVG(cd.credit_score)) AS avg_score_by_country
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join credit_data cd on cu.customer_id = cd.customer_id
GROUP BY co.country_name

--6.計算每位客戶的信用分數排名，並標記是否為最後10名為高風險客戶
----顯示欄位：customer_id、credit_score、rank、高風險標記（以*表示）
WITH CTE AS (
select 	cu.customer_id,
		cd.credit_score,
		RANK() OVER(ORDER BY cd.credit_score ASC) AS rank
from customers cu
inner join credit_data cd on cu.customer_id = cd.customer_id
)
select *,IIF(rank<=10,'*','') AS '高風險標記'
from CTE

--7.根據條件標記churn risk等級。
----等級:701~1000＝低風險, 500~700＝中風險，<500＝高風險
select cu.customer_id,cd.credit_score,
		CASE 
			WHEN cd.credit_score < 500 THEN 'High Risk'
			WHEN cd.credit_score BETWEEN 500 AND 700 THEN 'Medium Risk'
			WHEN cd.credit_score > 700 THEN 'Low Risk'
			ELSE '信用分數資料有誤!'
		END AS 'churn risk'
from customers cu
inner join credit_data cd on cu.customer_id = cd.customer_id

--8.找出高薪但仍流失的族群，高薪定義為estimated_salary超過150000為高薪。
select cu.customer_id
from customers cu
inner join membership mb ON cu.customer_id = mb.customer_id
where cu.estimated_salary > 150000 AND mb.churn = 1

--9.分析持有信用卡、仍不活躍且流失的客戶比例。
select CONVERT (FLOAT,(
		select COUNT(*) 
		from customers cu
		inner join membership mb ON cu.customer_id = mb.customer_id
		inner join products po on cu.customer_id = po.customer_id
		where po.credit_card = 1 AND mb.active_member = 0 AND mb.churn = 1
		))/CONVERT(FLOAT,COUNT(*))*100 '持有信用卡、仍不活躍且流失的客戶比例(%)'
from customers cu
inner join membership mb ON cu.customer_id = mb.customer_id
inner join products po on cu.customer_id = po.customer_id

--10.分析每個國家的活躍會員流失率並按流失率由高到低排序。
select co.country_name, 
	   ROUND(CONVERT(float,SUM(CASE WHEN mb.churn = 1 THEN 1 ELSE 0 END))/CONVERT(float,COUNT(mb.churn))*100,2) AS avg_churn
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join membership mb on cu.customer_id = mb.customer_id
where mb.active_member = 1
group by co.country_name
order by avg_churn DESC