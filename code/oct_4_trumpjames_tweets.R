library('RCurl')
library('twitteR')
library('readr')
library(rvest)
library(dplyr)
library(stringr)

source('twitter_api.R')
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

tweets = searchTwitter("Donald Trump OR LeBron James", n = 200, since = '2015-01-01',until = '2016-10-04')
tweets.trumpjames = tweets
save(tweets.trumpjames, file = 'raw_data/oct_4_200_tweets_trumpjames_20150101_20161004.RData')
