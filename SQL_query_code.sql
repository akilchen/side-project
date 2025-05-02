--�d�ߨC��Ȥ᪺�Ҧ����
select cu.country_id,cu.gender,cu.age,co.country_name,cu.estimated_salary,cu.tenure,
	   cd.credit_score,po.products_number,po.credit_card,po.balance,mb.active_member,mb.churn
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join credit_data cd on cu.customer_id = cd.customer_id
inner join products po on cu.customer_id = po.customer_id
inner join membership mb on cu.customer_id = mb.customer_id

--����Ȥ᪺�y���H�ƻP���
select IIF(churn=1,'�y��','���y��') AS �O�_�y��,
	   COUNT(customer_id) AS �Ȥ��,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(customer_id)* 100.0/SUM(COUNT(customer_id)) OVER ()))+'%' AS ����
from membership
GROUP BY churn;


--�Ȥ᪺�ʧO������y���H�ƻP���
select cu.gender,
	   IIF(mb.churn=1,'�y��','���y��') AS �O�_�y��,
	   COUNT(cu.customer_id) AS �Ȥ��,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(cu.customer_id)* 100.0/SUM(COUNT(cu.customer_id)) OVER ()))+'%' AS �������,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(cu.customer_id)* 100.0/SUM(COUNT(cu.customer_id)) OVER (PARTITION BY cu.gender)))+'%' AS �ʧO����
from customers cu
left join membership mb on cu.customer_id = mb.customer_id
GROUP BY cu.gender,mb.churn
ORDER BY cu.gender DESC,mb.churn DESC;

--�U��a�y���Ȥ���
select co.country_name,
	   IIF(mb.churn=1,'�y��','���y��') AS �O�_�y��,
	   COUNT(cu.customer_id) AS �Ȥ��,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(cu.customer_id)* 100.0/SUM(COUNT(cu.customer_id)) OVER ()))+'%' AS �������,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(cu.customer_id)* 100.0/SUM(COUNT(cu.customer_id)) OVER (PARTITION BY co.country_name)))+'%' AS ��a������
from customers cu
left join membership mb on cu.customer_id = mb.customer_id
left join countries co on co.country_id = cu.country_id
GROUP BY mb.churn,co.country_name
order by co.country_name,�O�_�y�� DESC;

--�֦����~�Ƭy���Ȥ���
select CONVERT(varchar,po.products_number)+'��' AS �֦����~��,
	   IIF(mb.churn=1,'�y��','���y��') AS �O�_�y��,
	   COUNT(cu.customer_id) AS �Ȥ��,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(cu.customer_id)* 100.0/SUM(COUNT(cu.customer_id)) OVER ()))+'%' AS �������,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(cu.customer_id)* 100.0/SUM(COUNT(cu.customer_id)) OVER (PARTITION BY po.products_number)))+'%' AS ���~�Ƥ�����
from customers cu
left join membership mb on mb.customer_id = cu.customer_id
left join products po on po.customer_id = cu.customer_id
GROUP BY mb.churn,po.products_number
order by �֦����~�� DESC,�O�_�y�� DESC;

--�֦�����H�Υd�y���Ȥ���
select IIF(po.credit_card = 1,'����','������') AS �O�_���H�Υd,
	   IIF(mb.churn = 1,'�y��','���y��') AS �O�_�y��,
	   COUNT(cu.customer_id) AS �Ȥ��,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(cu.customer_id)* 100.0/SUM(COUNT(cu.customer_id)) OVER ()))+'%' AS �������,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(cu.customer_id)* 100.0/SUM(COUNT(cu.customer_id)) OVER (PARTITION BY po.credit_card)))+'%' AS �H�Υd������
from customers cu
left join membership mb on mb.customer_id = cu.customer_id
left join products po on po.customer_id = cu.customer_id
GROUP BY mb.churn,po.credit_card
order by �O�_���H�Υd DESC,�O�_�y�� DESC;


--�O�_���D�P�y���Ȥ���
select IIF(active_member =1,'���D','�D���D') AS �O�_���D,
	   IIF(churn=1,'�y��','���y��') AS �O�_�y��,
	   COUNT(customer_id) AS �Ȥ��,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(customer_id)* 100.0/SUM(COUNT(customer_id)) OVER ()))+'%' AS �������,
	   CONVERT(varchar,
			   CONVERT(DECIMAL(5,2),
						COUNT(customer_id)* 100.0/SUM(COUNT(customer_id)) OVER (PARTITION BY active_member)))+'%' AS �O�_��ģ������
from  membership
GROUP BY churn,active_member
order by �O�_���D DESC,�O�_�y�� DESC;


--�d�߲��~�ƶq�j��2�B�����H�Υd�����D�|���W��
----��ܡGcustomer_id�B�~�֡B�w���~��B�O�_�y��
select cu.customer_id,cu.age,cu.estimated_salary,mb.churn
from customers cu
inner join membership mb on cu.customer_id = mb.customer_id
inner join products po on cu.customer_id = po.customer_id
where po.products_number > 2 and po.credit_card = 1 and mb.active_member=1

--�p��C�Ӱ�a���������p�~�~�B�H�Τ��ƻP�����b��l�B�C
select co.country_name,
        ROUND(CONVERT(DECIMAL(12,2),AVG(cu.estimated_salary)),2) AS '�����w���~�~',
		ROUND(CONVERT(DECIMAL(12,2),AVG(cd.credit_score)),2) AS '�����H�Τ���', --��decimal�~�|�X�{�p���I
	    ROUND(CONVERT(DECIMAL(12,2),AVG(po.balance)),2)      AS '�����b��l�B'  --��decimal�~�|�����p���I�ĤG��
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join credit_data cd on cu.customer_id = cd.customer_id
inner join products po on cu.customer_id = po.customer_id
GROUP BY co.country_name

--���X�C�Ӱ�a���H�Τ��ƱƦW�e3���Ȥ�C
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

--���R�C�@�Ӱ�a���������H�Τ���(���W�٬�avg_score_by_country)�C
select co.country_name,
		CONVERT(DECIMAL(10,2),AVG(cd.credit_score)) AS avg_score_by_country
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join credit_data cd on cu.customer_id = cd.customer_id
GROUP BY co.country_name

--�p��C��Ȥ᪺�H�Τ��ƱƦW�A�üаO�O�_���̫�10�W�������I�Ȥ�
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

--�ھڱ���аOchurn risk���šC
----����:701~1000�קC���I, 500~700�פ����I�A<500�װ����I
WITH CTE AS (
			 select cu.customer_id,cd.credit_score,
			 CASE 
			      WHEN cd.credit_score < 500 THEN 'High Risk'
			      WHEN cd.credit_score BETWEEN 500 AND 700 THEN 'Medium Risk'
			      WHEN cd.credit_score > 700 THEN 'Low Risk'
			      ELSE '�H�Τ��Ƹ�Ʀ��~!'
		     END AS 'churn_risk'
             from customers cu
             inner join credit_data cd on cu.customer_id = cd.customer_id)
select churn_risk,
		ROUND(AVG(CONVERT(float,credit_score)),2) AS �����H�Τ���,
		FORMAT(
				COUNT(churn_risk)*100.0/SUM(COUNT(churn_risk)) OVER(),'N2')+'%' AS ����
from CTE
Group BY churn_risk;

--��X���~�����y�����ڸs�A���~�w�q��estimated_salary�W�L150000�����~�C
select cu.customer_id
from customers cu
inner join membership mb ON cu.customer_id = mb.customer_id
where cu.estimated_salary > 150000 AND mb.churn = 1

--�Q�q�ɦV�Ȥ��ҡC(�����H�Υd�B�������D�B�y�����Ȥ���)
select CONVERT (FLOAT,(
		select COUNT(*) 
		from customers cu
		inner join membership mb ON cu.customer_id = mb.customer_id
		inner join products po on cu.customer_id = po.customer_id
		where po.credit_card = 1 AND mb.active_member = 0 AND mb.churn = 1
		)) '�H��',
		CONVERT (FLOAT,(
						select COUNT(*) 
						from customers cu
						inner join membership mb ON cu.customer_id = mb.customer_id
						inner join products po on cu.customer_id = po.customer_id
						where po.credit_card = 1 AND mb.active_member = 0 AND mb.churn = 1
						))/CONVERT(FLOAT,COUNT(*))*100 '���(%)'
from customers cu
inner join membership mb ON cu.customer_id = mb.customer_id
inner join products po on cu.customer_id = po.customer_id

--���R�C�Ӱ�a�����D�|���y���v�ë��y���v�Ѱ���C�ƧǡC
select co.country_name, 
	   SUM(CASE WHEN mb.churn = 1 THEN 1 ELSE 0 END) AS �y���H��,
	   FORMAT(
				SUM(CASE WHEN mb.churn = 1 THEN 1 ELSE 0 END)*100.00/
				COUNT(mb.churn),'N2')+'%' AS �����y���v
from customers cu
inner join countries co on cu.country_id = co.country_id
inner join membership mb on cu.customer_id = mb.customer_id
where mb.active_member = 1
group by co.country_name
order by �����y���v DESC