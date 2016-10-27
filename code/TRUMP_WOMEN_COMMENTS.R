library('RCurl')
library('twitteR')
library('readr')
library(rvest)
library(dplyr)
library(stringr)

source('twitter_api.R')
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

tweets.trump.women = searchTwitter("trump AND women", n = 450, 
                                    since = '2010-01-01', until = '2016-10-09',
                                    lang = 'en')
save(tweets.pitt.divorce, file = 'raw_data/oct_10_trump_women.RData')
print('1 done')