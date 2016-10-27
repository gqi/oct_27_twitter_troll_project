library('RCurl')
library('twitteR')
library('readr')
library(rvest)
library(dplyr)
library(stringr)

source('twitter_api.R')
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

tweets.pitt.divorce = searchTwitter("Brad Pitt AND divorce", n = 450, 
                            since = '2005-03-01', until = '2016-10-08',
                            lang = 'en')
save(tweets.pitt.divorce, file = 'raw_data/oct_9_pitt_divorce_tweets.RData')
print('1 done')
Sys.sleep(900)

tweets.jolie.divorce = searchTwitter("Angelina Jolie AND divorce", n = 450, 
                             since = '2005-03-01', until = '2016-10-08',
                             lang = 'en')
save(tweets.jolie.divorce, file = 'raw_data/oct_9_jolie_divorce_tweets.RData')
print('2 done')
Sys.sleep(900)

tweets.pitt.jolie = searchTwitter("Pitt AND Jolie", n = 450, 
                               since = '2005-03-01', until = '2016-10-08',
                               lang = 'en')
save(tweets.pitt.jolie, file = 'raw_data/oct_9_pitt_jolie_tweets.RData')

#### Search for retweets ####




