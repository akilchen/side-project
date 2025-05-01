--1.�d�ߨC��Ȥ᪺customer_id�B��a�B�H�Τ��ơB�b��l�B�B�O�_�y��
select cu.customer_id,co.country_name,cd.credit_score,po.balance,mb.churn
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join credit_data cd on cu.customer_id = cd.customer_id
inner join products po on cu.customer_id = po.customer_id
inner join membership mb on cu.customer_id = mb.customer_id


--2.�d�߲��~�ƶq�j��2�B�����H�Υd�����D�|���W��
----��ܡGcustomer_id�B�~�֡B�w���~��B�O�_�y��
select cu.customer_id,cu.age,cu.estimated_salary,mb.churn
from customers cu
inner join membership mb on cu.customer_id = mb.customer_id
inner join products po on cu.customer_id = po.customer_id
where po.products_number > 2 and po.credit_card = 1 and mb.active_member=1

--3.�p��C�Ӱ�a���������p�~�~�B�H�Τ��ƻP�����b��l�B�C
select co.country_name,
        ROUND(CONVERT(DECIMAL(12,2),AVG(cu.estimated_salary)),2) AS '�����H�Τ���',
		ROUND(CONVERT(DECIMAL(12,2),AVG(cd.credit_score)),2) AS '�����H�Τ���', --��decimal�~�|�X�{�p���I
	    ROUND(CONVERT(DECIMAL(12,2),AVG(po.balance)),2)      AS '�����b��l�B'  --��decimal�~�|�����p���I�ĤG��
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join credit_data cd on cu.customer_id = cd.customer_id
inner join products po on cu.customer_id = po.customer_id
GROUP BY co.country_name

--4.���X�C�Ӱ�a���H�Τ��ƱƦW�e3���Ȥ�C
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

--5.���R�C�@�Ӱ�a���������H�Τ���(���W�٬�avg_score_by_country)�C
select co.country_name,
		CONVERT(DECIMAL(10,2),AVG(cd.credit_score)) AS avg_score_by_country
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join credit_data cd on cu.customer_id = cd.customer_id
GROUP BY co.country_name

--6.�p��C��Ȥ᪺�H�Τ��ƱƦW�A�üаO�O�_���̫�10�W�������I�Ȥ�
----������Gcustomer_id�Bcredit_score�Brank�B�����I�аO�]�H*��ܡ^
WITH CTE AS (
select 	cu.customer_id,
		cd.credit_score,
		RANK() OVER(ORDER BY cd.credit_score ASC) AS rank
from customers cu
inner join credit_data cd on cu.customer_id = cd.customer_id
)
select *,IIF(rank<=10,'*','') AS '�����I�аO'
from CTE

--7.�ھڱ���аOchurn risk���šC
----����:701~1000�קC���I, 500~700�פ����I�A<500�װ����I
select cu.customer_id,cd.credit_score,
		CASE 
			WHEN cd.credit_score < 500 THEN 'High Risk'
			WHEN cd.credit_score BETWEEN 500 AND 700 THEN 'Medium Risk'
			WHEN cd.credit_score > 700 THEN 'Low Risk'
			ELSE '�H�Τ��Ƹ�Ʀ��~!'
		END AS 'churn risk'
from customers cu
inner join credit_data cd on cu.customer_id = cd.customer_id

--8.��X���~�����y�����ڸs�A���~�w�q��estimated_salary�W�L150000�����~�C
select cu.customer_id
from customers cu
inner join membership mb ON cu.customer_id = mb.customer_id
where cu.estimated_salary > 150000 AND mb.churn = 1

--9.���R�����H�Υd�B�������D�B�y�����Ȥ��ҡC
select CONVERT (FLOAT,(
		select COUNT(*) 
		from customers cu
		inner join membership mb ON cu.customer_id = mb.customer_id
		inner join products po on cu.customer_id = po.customer_id
		where po.credit_card = 1 AND mb.active_member = 0 AND mb.churn = 1
		))/CONVERT(FLOAT,COUNT(*))*100 '�����H�Υd�B�������D�B�y�����Ȥ���(%)'
from customers cu
inner join membership mb ON cu.customer_id = mb.customer_id
inner join products po on cu.customer_id = po.customer_id

--10.���R�C�Ӱ�a�����D�|���y���v�ë��y���v�Ѱ���C�ƧǡC
select co.country_name, 
	   ROUND(CONVERT(float,SUM(CASE WHEN mb.churn = 1 THEN 1 ELSE 0 END))/CONVERT(float,COUNT(mb.churn))*100,2) AS avg_churn
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join membership mb on cu.customer_id = mb.customer_id
where mb.active_member = 1
group by co.country_name
order by avg_churn DESC