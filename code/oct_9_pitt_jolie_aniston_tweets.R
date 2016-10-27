library('RCurl')
library('twitteR')
library('readr')
library(rvest)
library(dplyr)
library(stringr)

source('twitter_api.R')
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

tweets.pitt = searchTwitter("Brad Pitt", n = 450, 
                       since = '2005-03-01', until = '2016-10-08',
                       lang = 'en')
save(tweets.pitt, file = 'raw_data/oct_9_pitt_tweets.RData')
Sys.sleep(900)

tweets.jolie = searchTwitter("Angelina Jolie", n = 450, 
                        since = '2005-03-01', until = '2016-10-08',
                        lang = 'en')
save(tweets.jolie, file = 'raw_data/oct_9_jolie_tweets.RData')
Sys.sleep(900)

tweets.aniston = searchTwitter("Jennifer Aniston", n = 450, 
                        since = '2005-03-01', until = '2016-10-08',
                        lang = 'en')
save(tweets.aniston, file = 'raw_data/oct_9_aniston_tweets.RData')

#### Search for retweets ####




