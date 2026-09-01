
/*************************** QUESTIONS FROM JOINS DATA **********************************/
--Q1: Display student details and the courses they are enrolled to.
select S.*,M.COURSE_ID
from TBL_STUDENT as S
inner join TBL_MAPPING as M
on S.STU_ID = M.STU_ID

--Q2: Display details of all students and the count of courses they are enrolled to.
select S.*,COUNT(M.stu_id) as Count_course
from TBL_STUDENT as S
Left join TBL_MAPPING as M
on S.STU_ID = M.STU_ID
group by S.STU_ID ,DOB,EMAIL_CUS,NAME,PHONE_CUS

--Q3: Display details of students which are not yet enrolled to any course.
select S.*
from TBL_STUDENT as S
Left join TBL_MAPPING as M
on S.STU_ID = M.STU_ID
group by S.STU_ID ,DOB,EMAIL_CUS,NAME,PHONE_CUS
Having COUNT(M.stu_id) =0

--Q4: List all courses and the count of students enrolled to each course.
select C.*,count(stu_id) as stud_count
from TBL_MAPPING as M
Right join tbl_course as C
on M.COURSE_ID =C.COURSE_ID
group by C.COURSE_ID,Name


/************************* QUESTIONS FROM MSO DATABASE **********************************/
--Q1: In order to post welcome letters and user guides to customers, dispatch team need customer name, address and contact
--details. Write SQL query to get desired info.
select CONCAT(FNAME_CUS,' ',LNAME_CUS) AS CUST_NAME,
CONCAT(HOUSE_ID_HSE,' ',ADDRESS_HSE,' ',CITY_HSE,' ',COUNTRY_HSE) AS [ADDRESS],PHONE_CUS,EMAIL_CUS
from TBL_CUSTOMER as C
inner join TBL_HOUSE as H
on CUST_ID_CUS = CUST_ID_HSE


--Q2: Get the details of customers who are RESIDING in more than one location.
Select  CUST_ID_CUS, CONCAT(FNAME_CUS,' ',LNAME_CUS) AS CUST_NAME,PHONE_CUS,EMAIL_CUS,
COUNT(HOUSE_ID_HSE) AS LOC_COUNT
from TBL_CUSTOMER as C
inner join TBL_HOUSE as H
on CUST_ID_CUS = CUST_ID_HSE
GROUP BY CUST_ID_CUS, CONCAT(FNAME_CUS,' ',LNAME_CUS) ,PHONE_CUS,EMAIL_CUS
HAVING COUNT(HOUSE_ID_HSE) >1
----------------------------lEFT JOIN-----------
SELECT CUST_ID_CUS, CONCAT(FNAME_CUS,' ',LNAME_CUS) AS CUST_NAME,PHONE_CUS,EMAIL_CUS,
COUNT(HOUSE_ID_HSE) AS LOC_COUNT
FROM TBL_CUSTOMER AS C
LEFT JOIN TBL_HOUSE AS H
ON CUST_ID_CUS = CUST_ID_HSE
GROUP BY CUST_ID_CUS, CONCAT(FNAME_CUS,' ',LNAME_CUS) ,PHONE_CUS,EMAIL_CUS
HAVING COUNT(HOUSE_ID_HSE) >1

--Q3: Which are the customers that have not given their house details.
SELECT CUST_ID_CUS, CONCAT(FNAME_CUS,' ',LNAME_CUS) AS CUST_NAME,PHONE_CUS,EMAIL_CUS,
COUNT(HOUSE_ID_HSE) AS LOC_COUNT
FROM TBL_CUSTOMER AS C
LEFT JOIN TBL_HOUSE AS H
ON CUST_ID_CUS = CUST_ID_HSE
GROUP BY CUST_ID_CUS, CONCAT(FNAME_CUS,' ',LNAME_CUS) ,PHONE_CUS,EMAIL_CUS
HAVING COUNT(HOUSE_ID_HSE) =0

--Q4. Get the install dates corresponding to all customers in different locations
select CUST_ID_WO,HOUSE_ID_WO,COMPL_DTE_WO as INSATLL_DATES
from TBL_WORK_ORDER
where TYPE_WO = 'INSTALL'

--Q5:Get the location details along with count of services installed in the location.
select HOUSE_ID_HSE,CONCAT(ADDRESS_HSE,' ',CITY_HSE,' ',COUNTRY_HSE) AS [LOCATION],
COUNT(ORD_ID_WO) AS WORK_COUNT
from TBL_WORK_ORDER as W
Inner join TBL_HOUSE as H
on W.CUST_ID_WO  = H.CUST_ID_HSE
	and
W.HOUSE_ID_WO = H.HOUSE_ID_HSE
where TYPE_WO ='INSTALL'
GROUP BY HOUSE_ID_HSE,CONCAT(ADDRESS_HSE,' ',CITY_HSE,' ',COUNTRY_HSE)

--Q6: Get the Location details where install orders are in open state.
select CONCAT(ADDRESS_HSE,' ',CITY_HSE,' ',COUNTRY_HSE) AS [LOCATION]
from TBL_HOUSE as H
inner join TBL_WORK_ORDER as W
on HOUSE_ID_HSE = HOUSE_ID_WO
AND
 CUST_ID_HSE= CUST_ID_WO
WHERE TYPE_WO = 'INSTALL'
AND
STATUS_WO = 'OPEN'

--Q7: Are their any customers who have made a complaint more than once?
SELECT COUNT(*)
FROM(
		SELECT CUST_ID_CO, COUNT(CUST_ID_CO) AS COMP_COUNT
		FROM TBL_COMPLAINT_ORDER
		GROUP BY CUST_ID_CO
		HAVING COUNT(CUST_ID_CO) >1
	) AS X

--Mehtod 2 : using CTE:-----
WITH Cust_compl_count
AS (
	select CUST_ID_CO,COUNT(ORD_ID_CO) AS COMP_COUNT
	FROM TBL_COMPLAINT_ORDER
	GROUP BY CUST_ID_CO
	)
	SELECT* FROM Cust_compl_count
	WHERE COMP_COUNT >1
		
--Q8: Find the Count of total open orders in the available data.
SELECT*FROM TBL_COMPLAINT_ORDER
WHERE STATUS_CO = 'OPEN'
UNION
SELECT*FROM TBL_WORK_ORDER
WHERE STATUS_WO = 'OPEN'

--Q9: Are there any location ids where we have open service orders for disconnection and open complaint orders?
SELECT COUNT(*) AS lOC_COUNT
FROM  (
		SELECT HOUSE_ID_CO FROM TBL_COMPLAINT_ORDER
		WHERE STATUS_CO = 'OPEN'
		INTERSECT
		SELECT HOUSE_ID_WO FROM TBL_WORK_ORDER
		WHERE STATUS_WO = 'OPEN'
		AND TYPE_WO LIKE 'DISC%'
	) AS X

--Q10: Locations where customers have never given any complaints but discontinued the services.
SELECT HOUSE_ID_CO FROM TBL_COMPLAINT_ORDER
WHERE STATUS_CO = 'CLOSE'
EXCEPT
SELECT HOUSE_ID_WO FROM TBL_WORK_ORDER
WHERE TYPE_WO LIKE 'DISC%'

--Q11: List down the customers and no of total (WO + Complaints) orders placed by them also display the location details of 
--such customer.
SELECT CUST_ID_CO,HOUSE_ID_HSE, CONCAT(ADDRESS_HSE,' ',CITY_HSE,' ',COUNTRY_HSE) AS LOCATION,TOT_ORDER
FROM TBL_HOUSE AS H
INNER JOIN (
			SELECT CUST_ID_CO,HOUSE_ID_CO,COUNT(ORD_ID_CO) AS TOT_ORDER
			FROM(
			SELECT* FROM TBL_COMPLAINT_ORDER
			UNION
			SELECT*FROM TBL_WORK_ORDER
			)AS x
		GROUP BY CUST_ID_CO,HOUSE_ID_CO
	)AS RESULT
	ON  CUST_ID_HSE = CUST_ID_CO
	AND
	HOUSE_ID_HSE =HOUSE_ID_CO

----Method 2: Using CTE:---
WITH TOT_ORDERS -->CTE-1
AS (
	 SELECT*FROM TBL_COMPLAINT_ORDER
	 UNION 
	 SELECT*FROM TBL_WORK_ORDER
),
CUST_TOT_ORDERS --->CTE2 : CUSTOMER WISE ORDER
AS (
	SELECT CUST_ID_CO,HOUSE_ID_CO,COUNT(ORD_ID_CO) AS TOT_ORDERS
	FROM TOT_ORDERS
	GROUP BY CUST_ID_CO,HOUSE_ID_CO
)
SELECT CUST_TOT_ORDERS.*,CONCAT(ADDRESS_HSE,' ',CITY_HSE,' ',COUNTRY_HSE) AS [LOCATIONS]
FROM CUST_TOT_ORDERS
INNER JOIN TBL_HOUSE
ON CUST_ID_CO =CUST_ID_HSE
AND HOUSE_ID_CO =HOUSE_ID_HSE


--Q.12 Multiple customers have filled a req form to arrange some sort of construction work in their houses. Mangement is looking
 --for the details of such coustomers where the installation work is still going and they need the customer details along with
--their address 

SELECT CUST_ID_CUS,CONCAT(FNAME_CUS,' ',LNAME_CUS) AS CUST_NAME,PHONE_CUS,EMAIL_CUS,LOCATIONS
FROM TBL_CUSTOMER AS C
INNER JOIN (
			SELECT CUST_ID_WO, HOUSE_ID_HSE,CONCAT(ADDRESS_HSE,' ',CITY_HSE,' ',COUNTRY_HSE) [LOCATIONS]
			FROM TBL_WORK_ORDER AS W
			INNER JOIN TBL_HOUSE AS H
			ON HOUSE_ID_HSE = HOUSE_ID_WO
			AND
			CUST_ID_HSE =CUST_ID_WO
			WHERE STATUS_WO ='OPEN'
			AND
			TYPE_WO ='INSTALL'
) AS RESULT
ON CUST_ID_CUS =CUST_ID_WO

--FIND THE TOTAL SALES DONE IN EACH CATEGORY
SELECT CATEGORY,SUM(SALES) AS TOT_SALES
FROM TBL_ORDER
GROUP BY CATEGORY


---- FIND THE TOTAL SALES DONE IN EACH CATEGORY
SELECT CATEGORY,SUM(SALES) AS TOT_SALES
FROM TBL_ORDER
GROUP BY CATEGORY


SELECT*, SUM(SALES) OVER(PARTITION BY CATEGORY)  AS CAT_SALES
FROM TBL_ORDER

-- FIND THE MAX SALES GENRATED FROM EACH CATEGORY ALSO FIND THE DIFEERENCE IN THE SALES AS WELL FROM THE MAX SALES.
SELECT* , MAX(SALES) OVER(PARTITION BY CATEGORY) AS MAX_SALES ,
MAX(SALES) OVER(PARTITION BY CATEGORY)-SALES AS DIFF_SALES
FROM TBL_ORDER
--OR
SELECT*, MAX_SALES-SALES AS SALES_DIFF
FROM (
	SELECT* , MAX(SALES) OVER(PARTITION BY CATEGORY) AS MAX_SALES
	FROM TBL_ORDER
	)AS X
--WINDOW RANK FUNCTION:
--FIND THE PRODUCT WITH MAX SALES.
SELECT TOP 1 prod_name
FROM product_info
ORDER BY AMOUNT DESC

--FIND THE PRODUCT WITH 2 ND HIHEST SALES AMOUNT

SELECT TOP 1*
FROM(
	SELECT TOP 2 prod_name,AMOUNT
	FROM product_info
	ORDER BY AMOUNT DESC
	) AS x
	ORDER BY AMOUNT ASC

--
SELECT 
RANK()OVER(ORDER BY AMOUNT DESC ) AS RANKS,
DENSE_RANK() OVER(ORDER BY AMOUNT DESC) AS RANK2,
ROW_NUMBER() OVER(ORDER BY AMOUNT DESC) AS RANK3,*
FROM product_info

SELECT*
FROM(
		SELECT*,DENSE_RANK() OVER(ORDER BY AMOUNT DESC) AS RANK
		FROM product_info
		) AS x
		WHERE RANK=2

--Find the 2nd highest sales done bye the products from each category.
SELECT*
FROM (
		select*,
		DENSE_RANK() over(partition by category order by amount desc) as rank
		from product_info
	) AS X
	WHERE RANK =2

-- VALUE WINDOW FUNCTION
SELECT*
FROM TBL_ORDER

--Q: FIND THE MONTHLY SALES
SELECT MONTH(ORD_DTE) AS MONTHS,SUM(SALES) AS TOT_SALES
FROM TBL_ORDER
GROUP BY MONTH(ORD_DTE) 

--Q;2 Find the MoM change in sales.

SELECT*, CUR_SALES-PREV_SALES AS MoM_CHANGE
FROM (
	SELECT MONTH(ORD_DTE) AS MONTHS,SUM(SALES) AS CUR_SALES,
	LAG(SUM(SALES),1)OVER(ORDER BY MONTH(ORD_DTE)) AS PREV_SALES
	FROM TBL_ORDER
	GROUP BY MONTH(ORD_DTE)
	) AS X

--Find the %age sales change from each month.
select*, (curr_Sales-prev_sales)/prev_sales*100 as[%sales change]
from(

		select MONTH(ord_dte) as Months, Sum(sales) as curr_Sales,
		lag(sum(sales),1) over(order by month(ord_dte)) as prev_sales
		from tbl_order
		group by MONTH(ord_dte)
		) as X

--find the %age sales change for each product in every month.
select*
from tbl_order

select* into [new_product_info] from product_info

-- combine the house and customer table and assign permanent alloction as well.

create view customer_house_data
as 
		select C.*,H.HOUSE_ID_HSE,ADDRESS_HSE,CITY_HSE
		from TBL_CUSTOMER as C
		inner join TBL_HOUSE as H
		on CUST_ID_CUS=CUST_ID_HSE

-- show the data of all those locations where work order is in open state.[Note: dont use join and subquery if nedded ]

select HOUSE_ID_HSE,CONCAT(address_hse,' ',CITY_HSE) as location
into house_work_info
from TBL_HOUSE,TBL_WORK_ORDER
where CUST_ID_HSE = CUST_ID_WO
and HOUSE_ID_HSE=HOUSE_ID_WO
and STATUS_WO = 'Open'



--Find the top 'n' sales.
select*from TBL_ORDER
 
--create sp:

CREATE PROCEDURE TOP_N_SALES @N INT
AS 
	SELECT TOP (@N)*
	FROM TBL_ORDER
	ORDER BY SALES DESC

--EXC SP:
EXEC top_n_sales @N=5

--fIND THE TOTAL SALES GENRATED BY A MONTH FOR A CATEGORY

CREATE PROCEDURE MONTH_CATE_DATA @CAT VARCHAR(30),@MONTH INT
AS
	SELECT SUM(SALES) AS TOT_SALES
	FROM TBL_ORDER
	WHERE CATEGORY = @CAT AND MONTH(ORD_DTE) = @MONTH

EXEC MONTH_CATE_DATA @CAT = 'TECHNOLOGY',@MONTH =1

------------------------------COURSORS-------------------
DECLARE Cusr_data cursor
for
SELECT REF_NO,CUST_NAME,SALES,PROFIT,ORD_DTE
FROM TBL_ORDER

open cusr_data
fetch next from cusr_data

close cusr_data
DEALLOCATE CUSR_DATA

--CREATE TWO VARIABLES : CUST_NAMES &SALES.CREATE A CURSOR THAT HOLDS THE RESULT OF CUSTOMER RANGE AND SALES AMOUNT &ALSO
--STORES TEHM IN THE 2 VARIABLES.

DECLARE 
		@CUST VARCHAR(20),@SALES NUMERIC(18,5)

	DECLARE CUST_SALES CURSOR
	FOR
		SELECT CUST_NAME,SALES
		FROM TBL_ORDER

OPEN CUST_SALES

FETCH NEXT FROM CUST_SALES
WHILE @@FETCH_STATUS = 0

		PRINT 'CUST_NAME: ' + ' ' +'sales: ' +cast(sales as varchar)
		FETCH NEXT FROM CUST_SALES

select*from TBL_STUDENT

create index ind3
on student(Name)

select*from sys.indexes
where OBJECT_ID = OBJECT_ID('dbo.TBL_STUDENT')
