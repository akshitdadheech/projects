USE DEMO_DATABASE;

## CREATING TABLE

CREATE TABLE ad_airbnb_amsterdam (
room_id INT,
survey_id INT,
host_id INT,
room_type VARCHAR(50),
country	VARCHAR(50),
city VARCHAR(50),
borough	VARCHAR(50),
neighborhood VARCHAR(200),
reviews	INT,
overall_satisfaction decimal(3,1),
accommodates INT,
bedrooms INT,
bathrooms VARCHAR(50),
price INT,
minstay	VARCHAR(50),
name VARCHAR(200),
last_modified VARCHAR(100),
latitude FLOAT,
longitude FLOAT,
location VARCHAR(50)
);

## LOADING DATA

load data infile
"D:/airbnb_projects/airbnb prices.csv"
into table ad_airbnb_amsterdam
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

SELECT * FROM ad_airbnb_amsterdam;
SELECT count(room_id) FROM ad_airbnb_amsterdam; 

-- // Regarding the Host \\ --
-- 1. Who are top earners

SELECT host_id, name, SUM(price) AS top_earners
FROM ad_airbnb_amsterdam
GROUP BY host_id, name
ORDER BY top_earners DESC;

-- 2. Is there any relationship between monthly earning and prices

## lets split last_modified from date (DD-MM-YYYY) combined time, to date and time column

ALTER TABLE ad_airbnb_amsterdam
ADD COLUMN date varchar(50);

ALTER TABLE ad_airbnb_amsterdam
ADD COLUMN time varchar(50);

UPDATE ad_airbnb_amsterdam					--  updating the date column
SET date = SUBSTR(last_modified,1,10);

UPDATE ad_airbnb_amsterdam					--  updating the time column
SET time = SUBSTR(last_modified,12,5);

SELECT date,time FROM ad_airbnb_amsterdam;

## Change the date format to default format of YYYY-MM-DD

UPDATE ad_airbnb_amsterdam
SET date=str_to_date(date,"%d-%m-%Y");		

ALTER TABLE ad_airbnb_amsterdam				-- Changing the date datatype
MODIFY date date;

-- finding relation between monthly earning and prices

SELECT DISTINCT date FROM ad_airbnb_amsterdam;				-- The DISTINCT dates are 22 and 23 July 2017

## The dataset asks us to find monthly earning but there are only two dates no more than that so we will only take those two dates into consideration.

SELECT date, SUM(price) AS total_price
FROM ad_airbnb_amsterdam
GROUP BY date
ORDER BY total_price;					-- total price is more on '2017-07-22' than on '2017-07-23'

SELECT date, AVG(price) AS Avg_Price
FROM ad_airbnb_amsterdam
GROUP BY date
ORDER BY Avg_Price;						-- AVG of price is almost double on '2017-07-23' than on '2017-07-22'

SELECT date, MAX(price) AS costliest_price
FROM ad_airbnb_amsterdam
GROUP BY date
ORDER BY costliest_price;				-- The costliest price on 23rd was 6000 and on 22nd was 474

SELECT date, MIN(price) AS Cheapest
FROM ad_airbnb_amsterdam
GROUP BY date
ORDER BY Cheapest;						-- The cheapest price on 23rd was 18 and on 22nd was 12

-- // Regarding the Neighbourhood \\--
-- 1. Any particular location getting maximum number of bookings

SELECT neighborhood, count(*) AS no_of_bookings
FROM ad_airbnb_amsterdam
GROUP BY neighborhood
ORDER BY no_of_bookings DESC;			-- We found that 'De Baarsjes / Oud West' is getting the maximum number of bookings and then followed by 'De Pijp / Rivierenbuurt' and others

-- Price relation with respect to location

SELECT neighborhood, SUM(price) AS total_price
FROM ad_airbnb_amsterdam
GROUP BY neighborhood 
ORDER BY total_price DESC;				-- We found that 'De Baarsjes / Oud West' is getting the most price followed by 'Centrum West' and then others.

SELECT neighborhood, SUM(price) AS total_price
FROM ad_airbnb_amsterdam
GROUP BY neighborhood
ORDER BY total_price;					-- We found that 'Westpoort' is getting the lowest price followed by 'Gaasperdam / Driemond' and then others.

-- // Regarding the reviews \\--
-- Relationship between Quality and Price

SELECT name, overall_satisfaction, reviews, AVG(price) AS avg_price
FROM ad_airbnb_amsterdam
GROUP BY name, overall_satisfaction, reviews
HAVING reviews > 0
ORDER BY avg_price DESC;				-- We found that 'AmsterdamBase' have the highest average price but only got 6 reviews.

SELECT name, overall_satisfaction, reviews, AVG(price) AS avg_price
FROM ad_airbnb_amsterdam
GROUP BY name, overall_satisfaction, reviews
HAVING reviews > 0
ORDER BY avg_price;						-- 'SORRY- NO TOURISTS ALLOWED - Kattenoppas gezocht' have 6 reviews but the lowest Average price.

-- // Regarding Price \\--
-- Price vs amenitites

SELECT room_type, accommodates, bedrooms, AVG(price) AS  avg_price
FROM ad_airbnb_amsterdam
GROUP BY room_type, accommodates, bedrooms
ORDER BY avg_price DESC;

SELECT room_type, accommodates, bedrooms, AVG(price) AS  avg_price
FROM ad_airbnb_amsterdam
GROUP BY room_type, accommodates, bedrooms
ORDER BY avg_price;								-- room_type is affecting the average price a lot 'Entire home/apt' is having the maximum Average price and 'Private room' is having the least 'accommodates' (8) also affects it but we can't say it for certain regarding 'accommodates'.

-- Price vs location

SELECT neighborhood, AVG(price) AS avg_price
FROM ad_airbnb_amsterdam
GROUP BY neighborhood
ORDER BY avg_price DESC;						-- 'Centrum West' is having the most number of avg_price followed by 'Centrum Oost' and then others

SELECT neighborhood, AVG(price) AS avg_price
FROM ad_airbnb_amsterdam
GROUP BY neighborhood
ORDER BY avg_price;						-- 'Bijlmer Centrum' is having the least number of avg_price followed by 'Bijlmer Oost' and then others

## FINISHED PROJECT ##
-- // THANK YOU \\ --