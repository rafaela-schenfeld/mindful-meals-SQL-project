-- Different queries for Mindful Meals Database

-- 1. Calculate expiration dates for current user ingredients
SELECT ui.user_ingredient_id, i.name, ui.quantity, ui.added_date,
       DATE_ADD(ui.added_date, INTERVAL i.expiration_approx DAY) as estimated_expiration,
       DATEDIFF(DATE_ADD(ui.added_date, INTERVAL i.expiration_approx DAY), CURDATE()) as days_until_expiration
FROM user_ingredients ui
JOIN ingredients i ON ui.ingredient_id = i.ingredient_id
WHERE ui.user_id = 1 -- Replace with the user you want to check
  AND ui.remaining_quantity > 0
  AND DATEDIFF(DATE_ADD(ui.added_date, INTERVAL i.expiration_approx DAY), CURDATE()) >= 0
ORDER BY days_until_expiration ASC;


