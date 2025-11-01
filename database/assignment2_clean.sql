-- Assignment 2 — Task 1: Six SQL Statements
-- Demonstrates basic CRUD operations and a JOIN query.

---------------------------------------------------------------
-- 1) Insert a test account (Tony Stark)
--    Defaults will automatically generate account_id and account_type ('Customer')
---------------------------------------------------------------
INSERT INTO account (account_firstname, account_lastname, account_email, account_password)
VALUES ('Tony', 'Stark', 'tony@starkent.com', 'Iam1ronM@n');

---------------------------------------------------------------
-- 2) Promote Tony Stark to Admin
---------------------------------------------------------------
UPDATE account
SET account_type = 'Admin'
WHERE account_email = 'tony@starkent.com';

---------------------------------------------------------------
-- 3) Remove the Tony Stark test account
---------------------------------------------------------------
DELETE FROM account
WHERE account_email = 'tony@starkent.com';

---------------------------------------------------------------
-- 4) Update the GM Hummer description
--    Replace the phrase "small interiors" with "a huge interior"
---------------------------------------------------------------
UPDATE inventory
SET inv_description = REPLACE(inv_description, 'small interiors', 'a huge interior')
WHERE inv_make = 'GM'
  AND inv_model = 'Hummer'
  AND inv_description LIKE '%small interiors%';

---------------------------------------------------------------
-- 5) Show vehicles in the "Sport" classification (INNER JOIN)
---------------------------------------------------------------
SELECT i.inv_make,
       i.inv_model,
       c.classification_name
FROM inventory AS i
INNER JOIN classification AS c
        ON i.classification_id = c.classification_id
WHERE c.classification_name = 'Sport';

---------------------------------------------------------------
-- 6) Fix image paths by inserting the "/vehicles" folder
--    Example: "/images/ford.jpg" → "/images/vehicles/ford.jpg"
---------------------------------------------------------------
UPDATE inventory
SET inv_image     = REPLACE(inv_image, '/images/', '/images/vehicles/'),
    inv_thumbnail = REPLACE(inv_thumbnail, '/images/', '/images/vehicles/');
