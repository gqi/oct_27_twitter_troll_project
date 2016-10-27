### Download the tweets about the top 100 accounts
# setwd('/users/gqi/twitter_troll_project')
controv = read.table('raw_data/controvtopics.txt',
                            stringsAsFactors = FALSE)[,1]
controv.clean = gsub('[^a-zA-Z]', '_', controv)
library('RCurl')
library('twitteR')
library('readr')
library(rvest)
library(dplyr)
library(stringr)

## Set up API authorization
source('twitter_api.R')
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

for (i in 1:length(controv)){
    user = controv[i]
    tweets = searchTwitter(user, n = 90, 
                           since = '2005-03-01', until = '2016-10-08',
                           lang = 'en')
    save(tweets, file = paste0('raw_data/oct_17_', controv.clean[i],'_tweets.RData'))
    print(paste0(i, ' ', user))
    print(length(tweets))
    Sys.sleep(180)
}