-- MISSION 2 

-- Nous souhaitons observer l'évolution du chiffre d'affaires au fil des mois
SELECT loo.Year, loo.month, sum(amount) AS total_sales
FROM list_of_orders220502103055 AS loo
INNER JOIN order_details220502103055 as od
	on loo.Order_ID = od.Order_ID
GROUP BY loo.year, loo.month
ORDER BY loo.year, loo.month


-- Afficher le chiffre d'affaire par catégories de produits en mettant en avant la catégorie qui se vend le plus
SELECT category, sum(amount) as total_sales
FROM order_details220502103055
GROUP BY category
ORDER BY total_sales DESC



-- MISSION 3

-- Afficher le meilleur client en terme de chiffre d'affaire
SELECT 
	customername,
    COUNT(DISTINCT loo.order_id) as nb_orders,
    SUM(amount) as total_sales,
    SUM(profit) as total_profit
FROM list_of_orders220502103055 as loo
INNER JOIN order_details220502103055 as od
	on loo.Order_ID = od.order_id
GROUP BY customername
ORDER BY total_sales DESC
LIMIT 1

-- Afficher l'état générant le meilleur chiffre d'affaire
SELECT 
	state,
    SUM(amount) as total_sales,
    COUNT(DISTINCT loo.order_id) as nb_orders,
    SUM(profit) as total_profit
FROM list_of_orders220502103055 as loo
INNER JOIN order_details220502103055 as od
	on loo.Order_ID = od.order_id
GROUP BY state
ORDER BY total_sales DESC
LIMIT 1

-- Afficher le montant total par commande
SELECT od.Order_ID, customername, month, year, SUM(amount) AS total_amount
FROM list_of_orders220502103055 AS loo
INNER JOIN order_details220502103055 AS od
	on loo.Order_ID = od.Order_ID
GROUP BY od.Order_ID

-- Afficher le panier moyen
WITH average_basket AS
(
	SELECT od.Order_ID, customername, month, year, SUM(amount) AS total_amount
    FROM list_of_orders220502103055 AS loo
    INNER JOIN order_details220502103055 AS od
        on loo.Order_ID = od.Order_ID
    GROUP BY od.Order_ID
)
SELECT year, month, round(avg(total_amount), 2) AS avg_basket
FROM average_basket
GROUP BY year, month
ORDER BY year, month


-- MISSION 4 

-- Afficher l'évolution mensuelle des profits de la marketplace

SELECT loo.YEAR
        , loo.month
        , sum(profit) AS total_profit
FROM list_of_orders220502103055 AS loo
INNER JOIN order_details220502103055 AS od 
	ON loo.order_id = od.order_id
GROUP BY loo.year, loo.month

-- Afficher les sous-catégories de produits ayant généré une perte sur la période

SELECT "sub-category",
		COUNT(DISTINCT loo.Order_ID) AS nb_orders,
        SUM(amount) AS total_sales,
        SUM(profit) AS total_profit
FROM list_of_orders220502103055 AS loo
INNER JOIN order_details220502103055 AS od
	ON loo.Order_ID = od.Order_ID
GROUP BY "sub-category"
HAVING total_profit < 0

-- Afficher l'évolution mensuelle des profits de chaque sous catégorie

SELECT "sub-category",
		loo.year,
        loo.month,
        SUM(profit) AS total_profit
FROM list_of_orders220502103055 AS loo
INNER JOIN order_details220502103055 AS od
	ON loo.Order_ID = od.Order_ID
GROUP BY "sub-category", loo.year, loo.month


-- MISSION 5

-- A l'aide d'une CTE, on vérifie l'écart entre le chiffre d'affaires effectif et les obectifs pour chaque mois de la période. On affiche enfin le nombre de mois au-dessus des objectifs, égaux aux obectifs et en-dessous des objectifs

WITH table_sales_target AS 
      (
      SELECT od.category
              , loo.YEAR
              , loo.month
              , target
              , sum(amount) as total_sales
      from list_of_orders220502103055 AS loo
      INNER join order_details220502103055 AS od 
          on loo.order_id = od.order_id
      inner join sales_target220502103055 AS st
          on od.category = st.category
          and loo.month = st.month
          AND loo.year = st.year 
      group by 1, 2, 3
      ), 
    table_diff_target AS 
    (
      select *
            , case 
                  when total_sales between target*0.97 and target*1.03 then 'on_target'
                  when total_sales > target*1.03 THEN 'above_target'
                  ELSE 'below_target'
                END AS diff_w_target
      from table_sales_target
      )
select category
		, diff_w_target
        , count(*) as nb_months
from table_diff_target
group by 1, 2