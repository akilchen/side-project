--查詢每位客戶的所有資料
select cu.country_id,cu.gender,cu.age,co.country_name,cu.estimated_salary,cu.tenure,
	   cd.credit_score,po.products_number,po.credit_card,po.balance,mb.active_member,mb.churn
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join credit_data cd on cu.customer_id = cd.customer_id
inner join products po on cu.customer_id = po.customer_id
inner join membership mb on cu.customer_id = mb.customer_id

--全體客戶的流失人數與比例
select IIF(churn=1,'流失','未流失') AS 是否流失,
	   COUNT(customer_id) AS 客戶數,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(customer_id)* 100.0/SUM(COUNT(customer_id)) OVER ()))+'%' AS 佔比
from membership
GROUP BY churn;


--客戶的性別佔全體流失人數與比例
select cu.gender,
	   IIF(mb.churn=1,'流失','未流失') AS 是否流失,
	   COUNT(cu.customer_id) AS 客戶數,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(cu.customer_id)* 100.0/SUM(COUNT(cu.customer_id)) OVER ()))+'%' AS 全體佔比,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(cu.customer_id)* 100.0/SUM(COUNT(cu.customer_id)) OVER (PARTITION BY cu.gender)))+'%' AS 性別佔比
from customers cu
left join membership mb on cu.customer_id = mb.customer_id
GROUP BY cu.gender,mb.churn
ORDER BY cu.gender DESC,mb.churn DESC;

--各國家流失客戶比例
select co.country_name,
	   IIF(mb.churn=1,'流失','未流失') AS 是否流失,
	   COUNT(cu.customer_id) AS 客戶數,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(cu.customer_id)* 100.0/SUM(COUNT(cu.customer_id)) OVER ()))+'%' AS 全體佔比,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(cu.customer_id)* 100.0/SUM(COUNT(cu.customer_id)) OVER (PARTITION BY co.country_name)))+'%' AS 國家內佔比
from customers cu
left join membership mb on cu.customer_id = mb.customer_id
left join countries co on co.country_id = cu.country_id
GROUP BY mb.churn,co.country_name
order by co.country_name,是否流失 DESC;

--擁有產品數流失客戶比例
select CONVERT(varchar,po.products_number)+'種' AS 擁有產品數,
	   IIF(mb.churn=1,'流失','未流失') AS 是否流失,
	   COUNT(cu.customer_id) AS 客戶數,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(cu.customer_id)* 100.0/SUM(COUNT(cu.customer_id)) OVER ()))+'%' AS 全體佔比,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(cu.customer_id)* 100.0/SUM(COUNT(cu.customer_id)) OVER (PARTITION BY po.products_number)))+'%' AS 產品數內佔比
from customers cu
left join membership mb on mb.customer_id = cu.customer_id
left join products po on po.customer_id = cu.customer_id
GROUP BY mb.churn,po.products_number
order by 擁有產品數 DESC,是否流失 DESC;

--擁有本行信用卡流失客戶比例
select IIF(po.credit_card = 1,'持有','未持有') AS 是否有信用卡,
	   IIF(mb.churn = 1,'流失','未流失') AS 是否流失,
	   COUNT(cu.customer_id) AS 客戶數,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(cu.customer_id)* 100.0/SUM(COUNT(cu.customer_id)) OVER ()))+'%' AS 全體佔比,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(cu.customer_id)* 100.0/SUM(COUNT(cu.customer_id)) OVER (PARTITION BY po.credit_card)))+'%' AS 信用卡內佔比
from customers cu
left join membership mb on mb.customer_id = cu.customer_id
left join products po on po.customer_id = cu.customer_id
GROUP BY mb.churn,po.credit_card
order by 是否有信用卡 DESC,是否流失 DESC;


--是否活躍與流失客戶比例
select IIF(active_member =1,'活躍','非活躍') AS 是否活躍,
	   IIF(churn=1,'流失','未流失') AS 是否流失,
	   COUNT(customer_id) AS 客戶數,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(customer_id)* 100.0/SUM(COUNT(customer_id)) OVER ()))+'%' AS 全體佔比,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(customer_id)* 100.0/SUM(COUNT(customer_id)) OVER (PARTITION BY active_member)))+'%' AS 是否活耀內佔比
from  membership
GROUP BY churn,active_member
order by 是否活躍 DESC,是否流失 DESC;


--查詢產品數量大於2且持有信用卡的活躍會員名單
----顯示：customer_id、年齡、預估薪資、是否流失
select cu.customer_id,cu.age,cu.estimated_salary,mb.churn
from customers cu
inner join membership mb on cu.customer_id = mb.customer_id
inner join products po on cu.customer_id = po.customer_id
where po.products_number > 2 and po.credit_card = 1 and mb.active_member=1

--計算每個國家的平均估計年薪、信用分數與平均帳戶餘額。
select co.country_name,
        ROUND(CONVERT(DECIMAL(12,2),AVG(cu.estimated_salary)),2) AS '平均預估年薪',
		ROUND(CONVERT(DECIMAL(12,2),AVG(cd.credit_score)),2) AS '平均信用分數', --用decimal才會出現小數點
	    ROUND(CONVERT(DECIMAL(12,2),AVG(po.balance)),2)      AS '平均帳戶餘額'  --用decimal才會控制到小數點第二位
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join credit_data cd on cu.customer_id = cd.customer_id
inner join products po on cu.customer_id = po.customer_id
GROUP BY co.country_name

--撈出每個國家內信用分數排名前3的客戶。
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

--分析每一個國家內的平均信用分數(欄位名稱為avg_score_by_country)。
select co.country_name,
		CONVERT(DECIMAL(10,2),AVG(cd.credit_score)) AS avg_score_by_country
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join credit_data cd on cu.customer_id = cd.customer_id
GROUP BY co.country_name

--計算每位客戶的信用分數排名，並標記是否為最後10名為高風險客戶
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

--根據條件標記churn risk等級。
----等級:701~1000＝低風險, 500~700＝中風險，<500＝高風險
WITH CTE AS (
			 select cu.customer_id,cd.credit_score,
			 CASE 
			      WHEN cd.credit_score < 500 THEN 'High Risk'
			      WHEN cd.credit_score BETWEEN 500 AND 700 THEN 'Medium Risk'
			      WHEN cd.credit_score > 700 THEN 'Low Risk'
			      ELSE '信用分數資料有誤!'
		     END AS 'churn_risk'
             from customers cu
             inner join credit_data cd on cu.customer_id = cd.customer_id)
select churn_risk,
		ROUND(AVG(CONVERT(float,credit_score)),2) AS 平均信用分數,
		FORMAT(
				COUNT(churn_risk)*100.0/SUM(COUNT(churn_risk)) OVER(),'N2')+'%' AS 佔比
from CTE
Group BY churn_risk;

--找出高薪但仍流失的族群，高薪定義為estimated_salary超過150000為高薪。
select cu.customer_id
from customers cu
inner join membership mb ON cu.customer_id = mb.customer_id
where cu.estimated_salary > 150000 AND mb.churn = 1

--利益導向客戶比例。(持有信用卡、仍不活躍且流失的客戶比例)
select CONVERT (FLOAT,(
		select COUNT(*) 
		from customers cu
		inner join membership mb ON cu.customer_id = mb.customer_id
		inner join products po on cu.customer_id = po.customer_id
		where po.credit_card = 1 AND mb.active_member = 0 AND mb.churn = 1
		)) '人數',
		CONVERT (FLOAT,(
						select COUNT(*) 
						from customers cu
						inner join membership mb ON cu.customer_id = mb.customer_id
						inner join products po on cu.customer_id = po.customer_id
						where po.credit_card = 1 AND mb.active_member = 0 AND mb.churn = 1
						))/CONVERT(FLOAT,COUNT(*))*100 '比例(%)'
from customers cu
inner join membership mb ON cu.customer_id = mb.customer_id
inner join products po on cu.customer_id = po.customer_id

--分析每個國家的活躍會員流失率並按流失率由高到低排序。
select co.country_name, 
	   SUM(CASE WHEN mb.churn = 1 THEN 1 ELSE 0 END) AS 流失人數,
	   FORMAT(
				SUM(CASE WHEN mb.churn = 1 THEN 1 ELSE 0 END)*100.00/
				COUNT(mb.churn),'N2')+'%' AS 平均流失率
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join membership mb on cu.customer_id = mb.customer_id
where mb.active_member = 1
group by co.country_name
order by 平均流失率 DESC