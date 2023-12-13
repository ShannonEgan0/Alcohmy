-- Create a table of brewers (effectively users)
CREATE TABLE "brewers" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "email_address" TEXT UNIQUE NOT NULL,
    "username" TEXT NOT NULL UNIQUE CHECK (LENGTH("username") >= 8),
    "password" TEXT NOT NULL CHECK (LENGTH("password") >= 8),
    PRIMARY KEY ("id")
);

-- A table of breweries and their details
CREATE TABLE "breweries" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "address" TEXT,
    "city" TEXT,
    "postcode" TEXT,
    "country" TEXT,
    PRIMARY KEY ("id")
);

-- A table of beers designed
CREATE TABLE "beers" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "creation_date" DATE NOT NULL DEFAULT CURRENT_DATE,
    "style" TEXT,
    "brewer_id" INTEGER,
    "boil_time" INTEGER DEFAULT 60, -- In minutes
    "fermentation_time" INTEGER DEFAULT 14, -- Days
    "batch_vol" FLOAT,
    "pre-boil_vol" FLOAT,
    "expected_og" FLOAT,
    "expected_fg" FLOAT CHECK ("expected_fg" < "expected_og"),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("brewer_id") REFERENCES "brewers" ("id")
);

-- A staffing table, that ties brewers to breweries
CREATE TABLE "staffing" (
    "brewer_id" INTEGER,
    "brewery_id" INTEGER,
    "start_date" DATE NOT NULL DEFAULT CURRENT_DATE,
    "end_date" DATE CHECK ("end_date" >= "start_date") DEFAULT CURRENT_DATE,
    "role" TEXT NOT NULL CHECK("role" IN ('admin', 'user')),
    PRIMARY KEY ("brewer_id", "brewery_id", "start_date"),
    FOREIGN KEY ("brewery_id") REFERENCES "breweries" ("id"),
    FOREIGN KEY ("brewer_id") REFERENCES "brewers" ("id")
);

-- Table of actual brews, so occasions on which beers were made
CREATE TABLE "brews" (
    "id" INTEGER,
    "beer_id" INTEGER,
    "brewer_id" INTEGER,
    "brewery_id" INTEGER,
    "brew_date" DATE NOT NULL DEFAULT CURRENT_DATE,
    "OG" FLOAT,
    "FG" FLOAT,
    "notes" TEXT,
    PRIMARY KEY ("id")
    FOREIGN KEY ("beer_id") REFERENCES "beers" ("id"),
    FOREIGN KEY ("brewer_id") REFERENCES "brewers" ("id"),
    FOREIGN KEY ("brewery_id") REFERENCES "breweries" ("id")
);

-- Additional ingredients table that ties item details to a full list for reference in inventories
CREATE TABLE "ingredients" (
    "id" INTEGER,
    "name" TEXT UNIQUE,
    "category" TEXT CHECK ("category" IN ('hops', 'malts', 'adjuncts')),
    PRIMARY KEY ("id")
);

-- Table of hops varieties
CREATE TABLE "hops" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "alpha-acid-lower" INTEGER,
    "alpha-acid-upper" INTEGER CHECK ("alpha-acid-lower" <= "alpha-acid-upper"),
    "beta-acid-lower" INTEGER,
    "beta-acid-upper" INTEGER CHECK ("beta-acid-lower" <= "beta-acid-upper"),
    "characteristics" TEXT,
    "country" TEXT,
    "pellets" INTEGER NOT NULL DEFAULT 1 CHECK ("pellets" in (0, 1)), -- Boolean 1 or 0
    PRIMARY KEY ("id"),
    FOREIGN KEY ("name") REFERENCES "ingredients" ("name")
);

-- Table of malt varieties
CREATE TABLE "malts" (
    "id" INTEGER,
    "name" TEXT UNIQUE NOT NULL,
    "extract" INTEGER DEFAULT 0 CHECK ("extract" in (0, 1)), -- Boolean 1 or 0
    "category" TEXT,
    "characteristics" TEXT,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("name") REFERENCES "ingredients" ("name")
);

-- Table of yeast strains
CREATE TABLE "yeasts" (
    "id" INTEGER,
    "name" TEXT UNIQUE NOT NULL,
    "brand" TEXT,
    "species" TEXT,
    "packet" INTEGER DEFAULT 0 CHECK ("packet" in (0, 1)), -- Boolean 1 or 0 for wet or dry yeast
    "styles" TEXT,
    "tolerance_lower" FLOAT,
    "tolerance_upper" FLOAT CHECK ("tolerance_lower" <= "tolerance_upper"),
    "attenuation_lower" FLOAT,
    "attenuation_upper" FLOAT CHECK ("attenuation_lower" <= "attenuation_upper"),
    "temperature_lower" FLOAT,
    "temperature_upper" FLOAT CHECK ("temperature_lower" <= "temperature_upper"),
    "flocculation" TEXT,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("name") REFERENCES "ingredients" ("name")
);

-- All brew additions that are not malts or hops, additional tables could be added for non grain malts etc.
CREATE TABLE "adjuncts" (
    "id" INTEGER,
    "name" TEXT UNIQUE NOT NULL,
    "description" TEXT CHECK (LENGTH("description") <= 32),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("name") REFERENCES "ingredients" ("name")
);

-- Create table of all recipe steps, all steps can be found by SELECTING by beer ID
CREATE TABLE "recipes" (
    "id" INTEGER, -- This is the ID of the brewing "step"
    "beer_id" INTEGER NOT NULL,
    "step" INTEGER, -- The ascending order for steps taken, 1 will occur first, 2nd after etc.
    "ingredient_id" INTEGER, -- Can this be left NULL to allow for steps where nothing is added?
    "instruction" TEXT CHECK (LENGTH("instruction") <= 32), -- Short description of the step taken eg. Hop addition, or dry hop, or malt addition
    "time" INTEGER, -- Time of addition to boil, can be null for additions outside of boil
    "amount" FLOAT CHECK ("amount" >= 0),
    "amount_units" TEXT CHECK (LENGTH("amount_units") <= 16),
    "notes" TEXT,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("beer_id") REFERENCES "beers" ("id"),
    FOREIGN KEY ("ingredient_id") REFERENCES "ingredients" ("id")
);

-- Table of brewery ingredient inventories, each new addition of an ingredient is logged separately, for aging and variable quality purposes
CREATE TABLE "ingredient_inventories" (
    "id" INTEGER,
    "brewery_id" INTEGER NOT NULL,
    "ingredient_id" INTEGER NOT NULL,
    "purchase_date" DATE,
    "delivery_date" DATE, -- Will be NULL if undelivered
    "amount" FLOAT CHECK ("amount" >= 0),
    "amount_units" TEXT CHECK (LENGTH("amount_units") <= 16),
    "package_age" DATE, -- Date produced/packaged or recorded. This can be null as not always relevant, and needs to be added manually by brewer/staff
    PRIMARY KEY ("id"),
    FOREIGN KEY ("brewery_id") REFERENCES "breweries" ("id"),
    FOREIGN KEY ("ingredient_id") REFERENCES "ingredients" ("id")
);

-- This creates a view of brewers without passwords. It's possible another version of this is needed without first and last names for social use, rather than admin use
CREATE VIEW "brewers_clean" AS
SELECT
    "id",
    "first_name",
    "last_name",
    "username"
FROM "brewers";

-- Create trigger to add ingredient when adding a hop, including the ingredient ID
CREATE TRIGGER "add_hop"
AFTER INSERT ON "hops"
FOR EACH ROW
BEGIN
    INSERT INTO "ingredients" ("name", "category")
    VALUES (NEW."name", 'hops');
END;

-- Create trigger to add ingredient when adding a malt, including the ingredient ID
CREATE TRIGGER "add_malt"
AFTER INSERT ON "malts"
FOR EACH ROW
BEGIN
    INSERT INTO "ingredients" ("name", "category")
    VALUES (NEW."name", 'malts');
END;

-- Create trigger to add ingredient when adding a yeast, including the ingredient ID
CREATE TRIGGER "add_yeast"
AFTER INSERT ON "yeasts"
FOR EACH ROW
BEGIN
    INSERT INTO "ingredients" ("name", "category")
    VALUES (NEW."name", 'adjuncts');
END;


-- Create trigger to add ingredient when adding an adjunct, including the ingredient ID
CREATE TRIGGER "add_adjunct"
AFTER INSERT ON "adjuncts"
FOR EACH ROW
BEGIN
    INSERT INTO "ingredients" ("name", "category")
    VALUES (NEW."name", 'adjuncts');
END;
