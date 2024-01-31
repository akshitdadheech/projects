CREATE DATABASE twitter;

USE twitter;

CREATE TABLE IF NOT EXISTS twitter (
user_id			VARCHAR(30),
gender			VARCHAR(30),
location_id		VARCHAR(30),
city			VARCHAR(50),
state			VARCHAR(70),
statecode		VARCHAR(30),
country			VARCHAR(70),
tweet_id		VARCHAR(50),
hour_of_tweet	VARCHAR(5),
day_of_tweet	VARCHAR(5),
day_of_week		VARCHAR(30),
is_reshare		VARCHAR(6),
reach			INT,
retweet_count	INT,
likes			INT,
klout			INT,
sentiment		FLOAT,
lang			VARCHAR(10),
text_of_tweet	VARCHAR(10000)
);

-- 1-Retrieve the total number of tweets in the dataset.

SELECT COUNT(text_of_tweet) AS total_tweets  
FROM twitter;

-- 2-Find the number of distinct users (UserID) in the dataset.

SELECT COUNT(DISTINCT user_id) 
FROM twitter;

-- 3-Calculate the average number of likes per tweet.

SELECT AVG(likes) AS average_likes			
FROM twitter;

-- 4-Identify tweets where the sentiment is 'Positive.' Display the TweetID and sentiment.

SELECT tweet_id, sentiment
FROM twitter
WHERE sentiment > 0;

-- 5-Count the number of tweets where IsReshare is true (1).

SELECT COUNT(*) AS tweeets_with_reshare		
FROM twitter
WHERE is_reshare = "TRUE";

-- 6-List the top 5 users with the highest Reach. Display their UserID and Reach.

SELECT user_id, MAX(reach) AS highest_reach
FROM twitter
GROUP BY user_id
ORDER BY highest_reach DESC
LIMIT 5;

-- 7-Find the most common language (Lang) used in tweets.

WITH CTE AS (								
SELECT lang, COUNT(lang) AS most_common_lang
FROM twitter
GROUP BY lang
ORDER BY most_common_lang DESC
)
SELECT CTE.lang
FROM CTE
LIMIT 1;

-- 8-Determine the average Klout score for male (Gender = 'Male') users.

SELECT AVG(klout) AS average_klout			
FROM twitter
WHERE gender = "Male";

-- 9-Retrieve tweets posted on weekdays (Monday to Friday).

SELECT tweet_id, text_of_tweet
FROM twitter
WHERE day_of_tweet <> "Saturday" AND day_of_tweet <> "Sunday";

-- 10-Identify tweets with a Klout score greater than 50. Display the TweetID and Klout.

SELECT tweet_id, text_of_tweet
FROM twitter
WHERE klout > 50;

-- 11-Count the number of tweets posted from the United States (Country = 'United States').

SELECT COUNT(*) AS tweets_from_US
FROM twitter
WHERE country = 'United States';

-- 12-List tweets with the highest number of retweets. Display the TweetID and RetweetCount.

SELECT tweet_id, MAX(retweet_count) AS most_retweets
FROM twitter
GROUP BY tweet_id
ORDER BY most_retweets DESC
LIMIT 5;

-- 13-Find tweets with sentiment 'Negative' and Klout score less than 40.

SELECT tweet_id, text_of_tweet
FROM twitter
WHERE sentiment < 0 AND klout < 40;

-- 14-Calculate the average Likes for tweets posted on weekends (Saturday and Sunday).

SELECT AVG(likes) AS avg_likes
FROM twitter
WHERE day_of_week = "Saturday" OR day_of_week = "Sunday";

-- 15-Retrieve tweets posted in the city of 'New York.'

SELECT tweet_id, text_of_tweet
FROM twitter
WHERE city = "New York City";

-- 16-Identify tweets where Reach is greater than 1000. Display the TweetID and Reach.

SELECT tweet_id, text_of_tweet
FROM twitter
WHERE reach > 1000;

-- 17-Find the user (UserID) with the highest total engagement (sum of RetweetCount and Likes).

WITH CTE AS (
SELECT user_id, SUM(retweet_count) AS retweet_sum, SUM(likes) AS likes_sum
FROM twitter
GROUP  BY user_id
)

SELECT user_id, (retweet_sum + likes_sum) AS highest_engagement
FROM CTE
GROUP BY user_id
ORDER BY highest_engagement DESC
LIMIT 5;

-- 18-List tweets with sentiment 'Neutral' and Lang as 'English.'

SELECT tweet_id, text_of_tweet
FROM twitter
WHERE sentiment = 0 AND lang = "en";

-- 19-Calculate the total engagement (sum of RetweetCount and Likes) for each tweet.

WITH CTE AS (
SELECT user_id, tweet_id, text_of_tweet, SUM(retweet_count) AS retweet_sum, SUM(likes) AS likes_sum
FROM twitter
GROUP BY user_id, tweet_id, text_of_tweet
)

SELECT user_id, tweet_id, text_of_tweet, (retweet_sum + likes_sum) AS total_engagement
FROM CTE
GROUP BY user_id, tweet_id, text_of_tweet
ORDER BY total_engagement DESC;

-- 20-Retrieve tweets with sentiment 'Positive' or 'Neutral' and Lang as 'English' or 'Spanish.'

SELECT user_id, tweet_id, text_of_tweet
FROM twitter
WHERE sentiment >= 0 AND lang = "en" OR lang = "es";


														-- // PROJECT COMPLETED \\ --
															-- // THANK YOU \\ --