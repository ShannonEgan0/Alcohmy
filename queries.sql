-- Registering new users
INSERT INTO "brewers" ("first_name", "last_name", "email_address", "username", "password")
VALUES (
    'Harrold', 'Holt', 'harrold.holt@parliamenthouse.gov.au', 'harry_swimmer', 'out2sea4eva'),
    ('Anthony', 'Albanese', 'albo123@gmail.com', 'allyallyalbo', 'duttonlookslikevoldemort'),
    ('Frodo', 'Baggins', 'bagend@shire.com.me', 'hairyfeet420', 'myprecious123');

-- Register brewery
INSERT INTO "breweries" ("name", "address", "city", "postcode", "country")
VALUES (
    'Smuggington Brew Guys', '1 Cloud Lane', 'London', 'M12 7GH', 'United Kingdom'),
    ('Big Brew Place', '2 Large Street', 'Chicago', '432123', 'USA'),
    ('My shed', NULL, NULL, NULL, 'Australia');

-- Add user to brewery staff
INSERT INTO "staffing" ("brewer_id", "brewery_id", "start_date", "role")
VALUES (
    2, 3, '2022-05-20', 'admin'),
    (1, 3, '2023-01-15', 'user'),
    (1, 2, '2023-02-02', 'admin');

-- Register beer
INSERT INTO "beers" ("name", "style", "brewer_id")
VALUES (
    'Red Riding Hood', 'Red Ale', 1);

INSERT INTO "beers" ("name", "creation_date", "style", "brewer_id", "boil_time", "fermentation_time", "expected_og", "expected_fg")
VALUES (
    'Rapunzel', '2023-07-19', 'Hefeweisen', 1, 65, 28, 1.060, 1.021);

INSERT INTO "beers" ("name", "style", "brewer_id", "fermentation_time", "batch_vol", "pre-boil_vol", "expected_og", "expected_fg")
VALUES ('Galaxy Pale Ale', 'American Pale Ale', 2, 28, 22.71, 25.74, 1.055, 1.014);

-- Register a variety of hops
-- This is an ugly way of connecting the ingredients ids using "name" as a key through triggers.
-- The better solution will likely be through a higher level connection (eg. flask) and a RETURNING clause
INSERT INTO "hops" ("name")
VALUES ('Fuggles');
INSERT INTO "hops" ("name", "alpha-acid-lower", "alpha-acid-upper", "beta-acid-lower", "beta-acid-upper", "characteristics", "country")
VALUES ('Galaxy', 11, 16, 5, 6.9, 'Citrus, peach and passionfruit aromas', 'Australia');

-- Register a malt variety
INSERT INTO "malts" ("name")
VALUES ('Pilsner Malt'),
    ('Caramalt'),
    ('Pale 2-row'),
    ('Munich - Light 10L'),
    ('Caramel/Crystal 40L');

-- Register a yeast strain
INSERT INTO "yeasts" ("name",
    "brand",
    "species",
    "styles",
    "tolerance_lower",
    "tolerance_upper",
    "attenuation_lower",
    "attenuation_upper",
    "temperature_lower",
    "temperature_upper",
    "flocculation")
VALUES ('SafAle US-05',
    'Fermentis',
    'Saccharomyces cerevisiae',
    'Ale, Pale Ale, IPA',
    9, 11,
    72, 78,
    15, 20,
    'Medium-Low');

-- Register an adjunct
INSERT INTO "adjuncts" ("name")
VALUES ('Dextrose');

-- Add item to brewery inventory
WITH "b_id" AS (
    SELECT "id" FROM "breweries" WHERE "name" = 'Big Brew Place'),
"item_id" AS (
    SELECT "id" FROM "ingredients" WHERE "name" = 'Galaxy')
INSERT INTO "ingredient_inventories" ("brewery_id", "ingredient_id", "purchase_date", "delivery_date", "amount", "amount_units")
VALUES ((SELECT "id" FROM "b_id"), (SELECT "id" FROM "item_id"), '2023-04-04', '2023-04-09', 1000, 'g');

WITH "b_id" AS (
    SELECT "id" FROM "breweries" WHERE "name" = 'Big Brew Place')
INSERT INTO "ingredient_inventories" ("brewery_id", "ingredient_id", "purchase_date", "delivery_date", "amount", "amount_units")
VALUES
    ((SELECT "id" FROM "b_id"), (SELECT "id" FROM "ingredients" WHERE "name" = 'Pale 2-row'), '2023-04-04', '2023-04-09', 20000, 'g'),
    ((SELECT "id" FROM "b_id"), (SELECT "id" FROM "ingredients" WHERE "name" = 'Munich - Light 10L'), '2023-04-02', '2023-04-08', 1500, 'g'),
    ((SELECT "id" FROM "b_id"), (SELECT "id" FROM "ingredients" WHERE "name" = 'Caramel/Crystal 40L'), '2023-02-15', '2023-02-22', 1750, 'g'),
    ((SELECT "id" FROM "b_id"), (SELECT "id" FROM "ingredients" WHERE "name" = 'SafAle US-05'), '2023-04-04', '2023-04-09', 120, 'g');

-- Check the ingredient inventory of a brewery
SELECT
    "ingredient_inventories"."id",
    "ingredients"."name",
    "ingredients"."category",
    "ingredient_inventories"."purchase_date",
    "ingredient_inventories"."delivery_date",
    "ingredient_inventories"."amount",
    "ingredient_inventories"."amount_units"
FROM "ingredient_inventories"
JOIN "ingredients" ON "ingredient_inventories"."ingredient_id" = "ingredients"."id"
WHERE "brewery_id" = (SELECT "id" FROM "breweries" WHERE "name" = 'Big Brew Place');

-- Consume an amount of an item in inventory
UPDATE "ingredient_inventories"
SET "amount" = "amount" - 500
WHERE "ingredient_id" = (SELECT "id" FROM "ingredients" WHERE "name" = 'Galaxy')
AND "brewery_id" = (SELECT "id" FROM "breweries" WHERE "name" = 'Big Brew Place');

-- Register recipe steps for a beer
With "beer" AS (
    SELECT "id" FROM "beers" WHERE "name" = 'Galaxy Pale Ale')

INSERT INTO "recipes" (
    "beer_id",
    "step",
    "ingredient_id",
    "instruction",
    "time",
    "amount",
    "amount_units")
VALUES
    ((SELECT * FROM "beer"), 0, (SELECT "id" FROM "ingredients" WHERE "name" = 'Pale 2-row'), 'Grain bill', NULL, 5000, 'g'),
    ((SELECT * FROM "beer"), 0, (SELECT "id" FROM "ingredients" WHERE "name" = 'Munich - Light 10L'), 'Grain bill', NULL, 500, 'g'),
    ((SELECT * FROM "beer"), 0, (SELECT "id" FROM "ingredients" WHERE "name" = 'Caramel/Crystal 40L'), 'Grain bill', NULL, 170, 'g'),
    ((SELECT * FROM "beer"), 1, (SELECT "id" FROM "ingredients" WHERE "name" = 'Galaxy'), 'Hop addition', 60, 5.7, 'g'),
    ((SELECT * FROM "beer"), 2, (SELECT "id" FROM "ingredients" WHERE "name" = 'Galaxy'), 'Hop addition', 20, 5.7, 'g'),
    ((SELECT * FROM "beer"), 3, (SELECT "id" FROM "ingredients" WHERE "name" = 'Galaxy'), 'Hop addition', 10, 15, 'g'),
    ((SELECT * FROM "beer"), 4, (SELECT "id" FROM "ingredients" WHERE "name" = 'Galaxy'), 'Hop addition', 0, 37, 'g'),
    ((SELECT * FROM "beer"), 0, (SELECT "id" FROM "ingredients" WHERE "name" = 'SafAle US-05'), 'Yeast', NULL, 11.5, 'g')
    ;

-- Add item to brewery inventory
WITH "b_id" AS (
    SELECT "id" FROM "breweries" WHERE "name" = 'Big Brew Place'),
"item_id" AS (
    SELECT "id" FROM "ingredients" WHERE "name" = 'Galaxy')
INSERT INTO "ingredient_inventories" ("brewery_id", "ingredient_id", "purchase_date", "delivery_date", "amount", "amount_units")
VALUES ((SELECT "id" FROM "b_id"), (SELECT "id" FROM "item_id"), '2023-04-06', '2023-04-10', 300, 'g');

-- Query the ingredients required for a recipe and the inventory held of each
-- Note these are total ingredients. So if there were Galaxy Hops from 10 weeks prior, and Galaxy Hops from yesterday, they would still be summed
SELECT
    "recipes"."ingredient_id",
    SUM("recipes"."amount") AS "Amount Required",
    "Amount in Inventory"
FROM
    "recipes"
JOIN
    (SELECT "ingredient_id" AS "a", SUM("amount") AS "Amount in Inventory" FROM "ingredient_inventories" GROUP BY "ingredient_id")
    ON a = "recipes"."ingredient_id"
WHERE
    "beer_id" = (SELECT "id" FROM "beers" WHERE "name" = 'Galaxy Pale Ale')
GROUP BY
    "recipes"."ingredient_id";

-- Select steps of a recipe
SELECT
    *
FROM
    "recipes"
WHERE
    "beer_id" = (SELECT "id" FROM "beers" WHERE "name" = 'Galaxy Pale Ale');

-- Log brew
INSERT INTO "brews" ("beer_id", "brewer_id", "brewery_id", "OG", "FG", "notes")
VALUES ((SELECT "id" FROM "beers" WHERE "name" = 'Galaxy Pale Ale'),
    (SELECT "id" FROM "brewers" WHERE "first_name" = 'Frodo' AND "last_name" = 'Baggins'),
    (SELECT "id" FROM "brewers" WHERE "name" = 'Big Brew Place'),
    1.052, NULL,
    'OG came out lower than expected, might have stopped the boil too early.');

