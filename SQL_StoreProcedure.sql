--�w�s�{��1(�U�ꬡ�D�|���y���vKPI)
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

--����w�s�{��1(�U�ꬡ�D�|���y���vKPI)
EXEC SP_CRandACbyCountry

--�w�s�{��2(�Ȥ᭷�I���A�ƦW�аO)
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
select *,IIF(rank<=10,'*','') AS '�����I�аO'
from CTE
END

--����w�s�{��2(�Ȥ᭷�I���A�ƦW�аO)
EXEC SP_CRRiskRangeandLabel

--�w�s�{��3:�U�ꥭ�����p�~�~�B�H�Τ��ƻP�����b��l�B
CREATE PROCEDURE SP_CountryAverages
AS
BEGIN
select co.country_name,
        ROUND(CONVERT(DECIMAL(12,2),AVG(cu.estimated_salary)),2) AS '�����w���~�~',
		ROUND(CONVERT(DECIMAL(12,2),AVG(cd.credit_score)),2) AS '�����H�Τ���', --��decimal�~�|�X�{�p���I
	    ROUND(CONVERT(DECIMAL(12,2),AVG(po.balance)),2)      AS '�����b��l�B'  --��decimal�~�|�����p���I�ĤG��
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join credit_data cd on cu.customer_id = cd.customer_id
inner join products po on cu.customer_id = po.customer_id
GROUP BY co.country_name
END

--����w�s�{��3(�U�ꥭ�����p�~�~�B�H�Τ��ƻP�����b��l�B)
EXEC SP_CountryAverages