USE neh_grants;

CREATE VIEW vw_award_dollars_by_state
AS
SELECT p.state
 ,CONCAT('$',FORMAT(SUM(t.total_amount),2)) as total_awarded_amount
FROM (SELECT p.id
  ,i.state AS state
FROM projects p
JOIN institutions i
ON p.institution_id = i.id
WHERE i.country = 'USA'
UNION 
SELECT p.id
  ,l.state as state
FROM projects p
JOIN unaffiliated_project_locations l
ON p.id = l.project_id
WHERE l.country = 'USA') p 
JOIN (SELECT project_id
  ,SUM(amount) as total_amount
FROM (SELECT project_id
  ,supplement_amount as amount
FROM supplements
UNION
SELECT project_id
  ,original_amount as amount
FROM awards) all_ammounts
GROUP BY project_id) t
ON p.id = t.project_id
GROUP BY p.state 
ORDER BY p.state ASC;

CREATE VIEW vw_average_products_by_grant_size 
AS
SELECT grant_size
  ,COUNT(DISTINCT(s.project_id)) AS project_count
  ,SUM(p.product_count) AS product_count
  ,SUM(p.product_count)/COUNT(DISTINCT(s.project_id)) AS average_products
FROM
(SELECT a.project_id
,CASE 
  WHEN a.original_amount > 300001 THEN 'Large Grant - more than $300,000'
  WHEN a.original_amount BETWEEN 50001 AND 300000 THEN 'Medium Grant - $50,001 to $300,000'
  WHEN a.original_amount <= 50000 THEN 'Small Grant - $50,000 or less'
  ELSE 'N/A' 
 END AS grant_size 
FROM awards a) s
LEFT JOIN (SELECT bp.project_id
  ,COUNT(*) AS product_count
FROM book_products bp
GROUP BY bp.project_id
UNION
SELECT cp.project_id
  ,COUNT(*) AS product_count
FROM conference_presentation_products cp
GROUP BY cp.project_id) p
ON s.project_id = p.project_id
GROUP BY grant_size;

CREATE VIEW vw_federal_state_partnership_primary_disciplines
AS
SELECT DISTINCT discipline_name
FROM project_disciplines pd
JOIN projects p
ON pd.project_id = p.id
JOIN disciplines d
ON pd.discipline_id	= d.id
JOIN programs pr
ON p.program_id = pr.id
JOIN divisions di
ON pr.division_id = di.id
WHERE di.id = 6 AND pd.discipline_category = 1
ORDER BY discipline_name ASC;

CREATE VIEW vw_projects_by_award_year
AS
SELECT p.id
 ,p.project_title
 ,"Book" AS product_type
 ,b.title AS product_title
 ,b.publication_year AS product_date
FROM book_products b
JOIN projects p
ON b.project_id = p.id
JOIN awards a
ON p.id = a.project_id
WHERE a.year_awarded = '2015'
UNION
SELECT p.id
 ,p.project_title
 ,"Conference Presentation" AS product_type
 ,cp.title AS product_title
 ,cp.presentation_date AS product_date
FROM conference_presentation_products cp
JOIN projects p
ON cp.project_id = p.id
JOIN awards a
ON p.id = a.project_id
WHERE a.year_awarded = '2015'
ORDER BY id, product_date ASC;

CREATE VIEW vw_projects_by_institution
AS
SELECT p.id
 ,p.project_title
 ,"Book" AS product_type
 ,b.title AS product_title
 ,b.publication_year AS product_date
FROM book_products b
JOIN projects p
ON b.project_id = p.id
JOIN awards a
ON p.id = a.project_id
WHERE a.year_awarded = '2015'
UNION
SELECT p.id
 ,p.project_title
 ,"Conference Presentation" AS product_type
 ,cp.title AS product_title
 ,cp.presentation_date AS product_date
FROM conference_presentation_products cp
JOIN projects p
ON cp.project_id = p.id
JOIN awards a
ON p.id = a.project_id
WHERE a.year_awarded = '2015'
ORDER BY id, product_date ASC;

CREATE VIEW vw_reviews_by_reader
AS
SELECT d.division_name
  ,CONCAT(r.last_name,', ',r.first_name) as reader_name
  ,r.id AS reader_id
  ,IF(r.end_date IS NULL, 'Yes', 'No') AS current_employee
  ,CASE
	WHEN r.end_date IS NOT NULL THEN FORMAT(DATEDIFF(r.end_date,r.start_date)/365,1) 
    ELSE FORMAT(DATEDIFF(now(),r.start_date)/365,1)
    END AS years_worked
  ,pr.review_count 
  ,pr.avg_rating
FROM readers r
LEFT JOIN (SELECT reader_id
  ,COUNT(id) AS review_count
  ,FORMAT(SUM(review_rating)/COUNT(id),1) AS avg_rating
FROM project_reviews
GROUP BY reader_id) pr
ON pr.reader_id = r.id
JOIN divisions d
ON r.division_id = d.id
ORDER BY d.division_name, r.last_name