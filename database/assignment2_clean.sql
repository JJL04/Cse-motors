-- Assignment 2 — Task 1: six SQL statements (clean copy)

-- 1) Insert a test account (Tony Stark). Defaults generate account_id and account_type.
INSERT INTO account (account_firstname, account_lastname, account_email, account_password)
VALUES ('Tony', 'Stark', 'tony@starkent.com', 'Iam1ronM@n');

-- 2) Promote Tony Stark to Admin
UPDATE account
SET account_type = 'Admin'
WHERE account_email = 'tony@starkent.com';

-- 3) Remove the Tony Stark test account
DELETE FROM account
WHERE account_email = 'tony@starkent.com';

-- 4) Update the GM Hummer description (replace a phrase)
UPDATE inventory
SET inv_description = replace(inv_description, 'small interiors', 'a huge interior')
WHERE inv_make = 'GM' AND inv_model = 'Hummer' AND inv_description LIKE '%small interiors%';

-- 5) Show sport-classification vehicles (inner join)
SELECT i.inv_make,
       i.inv_model,
       c.classification_name
FROM inventory i
JOIN classification c ON i.classification_id = c.classification_id
WHERE c.classification_name = 'Sport';

-- 6) Fix image paths by inserting the '/vehicles' folder into image URLs
UPDATE inventory
SET inv_image = replace(inv_image, '/images/', '/images/vehicles/'),
    inv_thumbnail = replace(inv_thumbnail, '/images/', '/images/vehicles/');
