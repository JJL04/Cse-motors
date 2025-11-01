-- Database rebuild script for Assignment 2
-- This file creates a small schema for the assignment and inserts a few
-- sample rows so the Task 1 statements in `assignment2.sql` have data to operate on.

-- Wrap in a transaction so the run is atomic during testing.
BEGIN;

-- Create enum-like type for account roles. Ignore if already present.
DO $$
BEGIN
    CREATE TYPE account_type AS ENUM ('Customer', 'Admin', 'Employee');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- classification table
CREATE TABLE IF NOT EXISTS classification (
  classification_id SERIAL PRIMARY KEY,
  classification_name VARCHAR(50) UNIQUE NOT NULL
);

-- inventory table
CREATE TABLE IF NOT EXISTS inventory (
  inv_id SERIAL PRIMARY KEY,
  inv_make VARCHAR(100) NOT NULL,
  inv_model VARCHAR(100) NOT NULL,
  inv_year INTEGER,
  inv_description TEXT,
  inv_image VARCHAR(255),
  inv_thumbnail VARCHAR(255),
  classification_id INTEGER REFERENCES classification(classification_id)
);

-- account table
CREATE TABLE IF NOT EXISTS account (
  account_id SERIAL PRIMARY KEY,
  account_firstname VARCHAR(100) NOT NULL,
  account_lastname VARCHAR(100) NOT NULL,
  account_email VARCHAR(255) UNIQUE NOT NULL,
  account_password VARCHAR(255) NOT NULL,
  account_type account_type DEFAULT 'Customer'
);

-- Seed some classifications
INSERT INTO classification (classification_name)
VALUES ('Sport'), ('SUV'), ('Sedan')
ON CONFLICT (classification_name) DO NOTHING;

-- Seed the inventory table with sample rows
INSERT INTO inventory (inv_make, inv_model, inv_year, inv_description, inv_image, inv_thumbnail, classification_id)
VALUES
  ('Ford', 'Mustang', 2019, 'A fast sports car with aggressive styling', '/images/ford-mustang.jpg', '/images/ford-mustang-thumb.jpg', (SELECT classification_id FROM classification WHERE classification_name='Sport')),
  ('Dodge', 'Viper', 2018, 'High performance sport vehicle', '/images/dodge-viper.jpg', '/images/dodge-viper-thumb.jpg', (SELECT classification_id FROM classification WHERE classification_name='Sport')),
  ('GM', 'Hummer', 2005, 'Large off-road vehicle with small interiors and rugged build', '/images/gm-hummer.jpg', '/images/gm-hummer-thumb.jpg', (SELECT classification_id FROM classification WHERE classification_name='SUV'))
ON CONFLICT DO NOTHING;

-- Pre-apply the two Task 1 updates so assignment2.sql can demonstrate them.
-- (A) Replace 'small interiors' with 'a huge interior' for the GM Hummer description
UPDATE inventory
SET inv_description = replace(inv_description, 'small interiors', 'a huge interior')
WHERE inv_make = 'GM' AND inv_model = 'Hummer' AND inv_description LIKE '%small interiors%';

-- (B) Update image paths to include '/vehicles' subfolder
UPDATE inventory
SET inv_image = replace(inv_image, '/images/', '/images/vehicles/'),
    inv_thumbnail = replace(inv_thumbnail, '/images/', '/images/vehicles/');

COMMIT;
-- Database rebuild script for Assignment 2
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- 2) Create classification table
CREATE TABLE IF NOT EXISTS classification (
  classification_id SERIAL PRIMARY KEY,
  classification_name VARCHAR(50) UNIQUE NOT NULL
);

-- 3) Create inventory table
CREATE TABLE IF NOT EXISTS inventory (
  inv_id SERIAL PRIMARY KEY,
  inv_make VARCHAR(100) NOT NULL,
  inv_model VARCHAR(100) NOT NULL,
  inv_year INTEGER,
  inv_description TEXT,
  inv_image VARCHAR(255),
  inv_thumbnail VARCHAR(255),
  classification_id INTEGER REFERENCES classification(classification_id)
);

-- 4) Create account table
CREATE TABLE IF NOT EXISTS account (
  account_id SERIAL PRIMARY KEY,
  account_firstname VARCHAR(100) NOT NULL,
  account_lastname VARCHAR(100) NOT NULL,
  account_email VARCHAR(255) UNIQUE NOT NULL,
  account_password VARCHAR(255) NOT NULL,
  account_type account_type DEFAULT 'Customer'
);

-- 5) Populate classification (sample data)
INSERT INTO classification (classification_name) VALUES
  ('Sport'), ('SUV'), ('Sedan')
ON CONFLICT (classification_name) DO NOTHING;

-- 6) Populate inventory with sample rows (two sport items so Task 1 query returns rows)
-- Note: inv_image and inv_thumbnail use /images/ path which Task 1.6 will update
INSERT INTO inventory (inv_make, inv_model, inv_year, inv_description, inv_image, inv_thumbnail, classification_id) VALUES
  ('Ford', 'Mustang', 2019, 'A fast sports car with aggressive styling', '/images/ford-mustang.jpg', '/images/ford-mustang-thumb.jpg', (SELECT classification_id FROM classification WHERE classification_name='Sport')),
  ('Dodge', 'Viper', 2018, 'High performance sport vehicle', '/images/dodge-viper.jpg', '/images/dodge-viper-thumb.jpg', (SELECT classification_id FROM classification WHERE classification_name='Sport')),
  ('GM', 'Hummer', 2005, 'Large off-road vehicle with small interiors and rugged build', '/images/gm-hummer.jpg', '/images/gm-hummer-thumb.jpg', (SELECT classification_id FROM classification WHERE classification_name='SUV'));

-- 7) Add the two Task 1 queries (4 and 6) at the end of the rebuild file
-- (4) Replace 'small interiors' in GM Hummer description
UPDATE inventory
SET inv_description = replace(inv_description, 'small interiors', 'a huge interior')
WHERE inv_make = 'GM' AND inv_model = 'Hummer' AND inv_description LIKE '%small interiors%';

UPDATE inventory
SET inv_image = replace(inv_image, '/images/', '/images/vehicles/'),
    inv_thumbnail = replace(inv_thumbnail, '/images/', '/images/vehicles/');
-- End of file
