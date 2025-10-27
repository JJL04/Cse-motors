-- Task 1: Six SQL statements for Assignment 2
-- 1) Insert Tony Stark (account_id and account_type handled by defaults)
INSERT INTO account (account_firstname, account_lastname, account_email, account_password)
VALUES ('Tony', 'Stark', 'tony@starkent.com', 'Iam1ronM@n');

-- 2) Modify Tony Stark to change account_type to 'Admin'
UPDATE account
SET account_type = 'Admin'
WHERE account_email = 'tony@starkent.com';

-- 3) Delete the Tony Stark record
DELETE FROM account
WHERE account_email = 'tony@starkent.com';

-- 4) Modify the "GM Hummer" description replacing 'small interiors' with 'a huge interior'
-- Use PostgreSQL replace() so we don't retype the whole description
UPDATE inventory
SET inv_description = replace(inv_description, 'small interiors', 'a huge interior')
WHERE inv_make = 'GM' AND inv_model = 'Hummer' AND inv_description LIKE '%small interiors%';

-- 5) Inner join: select make and model from inventory and classification name for 'Sport' category
SELECT i.inv_make, i.inv_model, c.classification_name
FROM inventory i
INNER JOIN classification c
  ON i.classification_id = c.classification_id
WHERE c.classification_name = 'Sport';

-- 6) Update all inventory records to insert '/vehicles' into image paths: /images/ -> /images/vehicles/
UPDATE inventory
SET inv_image = replace(inv_image, '/images/', '/images/vehicles/'),
    inv_thumbnail = replace(inv_thumbnail, '/images/', '/images/vehicles/');
