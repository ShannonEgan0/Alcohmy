# Alcohmy - A Brewery/Brewing Management Tool
### Completed for CS50SQL
#### Author: Shannon Egan

#### Video Demo: TODO: Include link here to youtube demo

## Introduction
This project was completed as part of the CS50SQL online course.

The Alcohmy database was designed as a system that could provide brewing support over two scales:
- Assist homebrewers and single brewers who want to keep records of their own creations, and monitor their successes and failures
- Assist in larger scale brewery management systems, tracking inventories, production and staffing

## Scope
The scope for Alcohmy was intentionally restrained, but it was designed with the intent that new features could be conveniently added to the system. In the current state, the system contains the following general systems:
- User and brewery tracking, and the ability to assign brewers to staffing associations with brewers
- Full recipe records, including connections to databases of possible brewing ingredients
- Record keeping for brews completed, by brewers and/or breweries
- Ingredient inventories for breweries

Systems that could be added to Alcohmy in the future:
- Stored beer tracking, distributed to kegs, fermenters and bottle inventories
- Sales/use of stored beer
- Brewing measurement tracking, noting discrete temperature, density and IBU measurements
- Recipe/brewery review/rating/recommendation systems
- A system for ensuring elements of brewery specific information are kept private when intended
- Brewery specific role assignments for staffing engagements

## Entities
The Alcohmy database contains the following entities:
#### Brewers
* `id` - `INT` - Primary key representing a single brewer/user.
* `first_name` - `TEXT` - First name of the registered user.
* `last_name` - `TEXT` - Last name of the registered user.
* `email` - `TEXT` - Unique email address of the registered user.
* `username` - `TEXT` - Unique username of a particular registered user for sign in purposes, with a minimum length.
* `password` - `TEXT` - A password associated with a user for sign in purposes, with a minimum length.
#### Breweries
* `id` - `INT` - Primary key representing a single brewery.
* `name` - `TEXT` - Name of a registered brewery.
* `address` - `TEXT` - Street address of a registered brewery.
* `city` - `TEXT` - City of a registered brewery.
* `postcode` - `TEXT` - Postcode of a registered brewery.
* `country` - `TEXT` - Country of a registered brewery.
#### Beers
* `id` - `INT` - Primary key representing a single named recipe for a beer.
* `name` - `TEXT` - The name of a single registered beer.
* `creation_date` - `DATE` - The date a beer is registered in the database, defaulting to the current date.
* `style` - `TEXT` - The style of beer the registered beer belongs to. This may be a limited list, in practice this may be from styles such as "Hefeweisen", "Pilsner" and "Tripel", with a category of "other" for unusual creations.
* `brewer_id` - `INT` - A foreign key connecting to `brewers`.`id` representing the user/brewer who registered the beer.
* `boil_time` - `INT` - The boil time required for the brewing of this beer in units of minutes. This will default to 60 minutes, as is the case for most beers.
* `fermentation_time` - `INT` - The minimum recommended number of days for fermentation for a particular beer. This will default to 14 days if left blank, but this should potentially default to NULL to avoid misinforming users.
* `batch_vol` - `FLOAT` - The batch volume of a particular beer registry, in units of litres. This can be used to scale to the intended resulting volume of beer produced, and alongside `pre-boil_vol` will indicate process effects, to mimic the beer recipe intent.
* `pre-boil_vol` - `FLOAT` - The intended volume in litres of a particular beer's brew at the start of the boil. In practice this value will change in the brews table when the beer is actually made, but this field is essential for batch scaling of ingredients from the `recipes` table.
* `expected_og` - `FLOAT` - The expected original gravity after completion of brewing of the registered beer. This will vary in practice due to efficiency of a brew, but coupled with `expected_fg` will indicate expected alcohol by volume and taste of beer.
* `expected_fg` - `FLOAT` - The expected final gravity after completion of fermentation of the registered beer. This will vary in practice due to variation in the OG and attenuation of the yeast, but coupled with `expected_og` will indicate expected alcohol by volume and taste of beer. A check is in place to ensure that `expected_og` is less than `expected_og`.
#### Staffing
* `brewer_id` - `INT` - A foreign key connecting to `brewers`.`id` associating a staffing engagement to a particular brewer. Will also form part of a primary key with `brewery_id` and `start_date`.
* `brewery_id` - `INT` - A foreign key connecting to `breweries`.`id` associating a staffing engagement to a particlar brewery. Will also form part of a primary key with `brewer_id` and `start_date`.
* `start_date` - `DATE` - The date a staffing engagement started. This will default to the current date, but should refer specifically to when a brewer commences an engagement with a brewery. Will also form part of a primary key with `brewer_id` and `brewery_id`. Care needs to be taken when altering `start_date` to ensure that the uniqueness of `brewer_id`, `brewery_id` and `start_date` is not compromised.
* `end_date` - `DATE` - The date a staffing engagement ended. A check exists to ensure this is a later date than `start_date`, and will default to the current date if left unspecified.
* `role` - `TEXT` - The role of a brewer in an engagement with a brewery. This is currently limited to either "admin" or "user", but should likely be expanded, or have roles defined by a brewery.

### Entity Relationship Diagram
![Entity Relationship Diagram](Alcohmy.svg)
