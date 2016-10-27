library('RCurl')
library('twitteR')
library('readr')
library(rvest)
library(dplyr)
library(stringr)

## Set up API authorization
source('twitter_api.R')
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
ref.tweets = searchTwitter('america', n = 450, 
                       since = '2005-03-01', until = '2016-10-08',
                       lang = 'en')
save(ref.tweets, file = paste0('raw_data/oct_18_neutral_reference_tweets.RData'))
