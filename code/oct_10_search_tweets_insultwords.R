setwd('/users/gqi/twitter_troll_project')
library('RCurl')
library('twitteR')
library('readr')
library(rvest)
library(dplyr)
library(stringr)

insult = read.table('raw_data/insultwords.txt', stringsAsFactors = FALSE)[,1]

source('twitter_api.R')
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

tweets.insult = list()
for (i in 1:length(insult)){
	sw = insult[i]
	print(i)
    print(sw)
 
    tweets.insult[[sw]] = searchTwitter(sw, n = 5, 
                                since = '2005-03-01', until = '2016-10-08',
                                lang = 'en')
    Sys.sleep(10)
    save(tweets.insult, file = 'raw_data/oct_10_tweets_insult.RData')
}

