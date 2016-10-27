library('RCurl')
library('twitteR')
library('readr')
library(rvest)
library(dplyr)
library(stringr)

## Read 100 most followed user list
top100followed = read.table('raw_data/oct_16_top100followed_twitter_accounts.txt',
                            stringsAsFactors = FALSE)[,1]
top100followed.clean = gsub(' ', '_', top100followed)

## Read in tweets from 100 most followed users
top100tweets = list()
for (name in top100followed.clean[1:74]){ # Since we only have data for the first 74
    load(paste0('raw_data/oct_17_', name, '_tweets.RData'))
    top100tweets[[name]] = tweets
}

## Choose approximate ly
alltweets = do.call(c, top100tweets)
set.seed(87864567)
inds = sample(length(alltweets), 400, replace = FALSE)
write.table(inds, 'processed_data/oct_19_indices_400_random_tweets_for_maual_classification.txt')
subset400tweets = alltweets[inds]
names(subset400tweets) = paste0('Tweet ', 1:400)
save(subset400tweets, file = 'processed_data/oct_19_400_random_tweets_for_maual_classification.RData')

trollind = c(19, 22, 32, 47, 66,
             68, 74, 83, 86, 100,
             102, 103, 124, 136, 153,
             160, 165, 185, 192, 194,
             211, 212, 223, 230, 258, 
             268, 281, 285, 302, 303,
             318, 343, 364, 376, 384) 

## If it is citing something that contains bad words, cannot identify.

### Download user information for all and put all useful data into data frame
### This data frame contains missing values.
namelist = sapply(alltweets, function(x) x@.xData$screenName)
## Set up API authorization
source('twitter_api.R')
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
## Search
users = lookupUsers(namelist)
save(users, file = 'raw_data/oct_19_top74_training_tweets_user_info.RData')
users = unique(users)

## Create data frame
data.clean = data.frame(screenName = namelist)
data.clean$isTroll = NA
data.clean[inds[trollind], 'isTroll'] = TRUE
data.clean[inds[setdiff(1:400, trollind)], 'isTroll'] = FALSE
for (attri in c('created', 'text', 'isRetweet', 'favoriteCount', 'retweetCount')){
    data.clean[, attri] = sapply(alltweets, function(x) x@.xData[[attri]])
}
users.scrnames = sapply(users, function(x) x@.xData$screenName)
for (attri in c('name', 'protected', 'listedCount', 'followersCount', 'created', 'location', 'favoritesCount', 'friendsCount', 'verified', 'description')){
    data.clean[, attri] = sapply(data.clean$screenName,  function(x) ifelse(x %in% users.scrnames, 
                                        users[[which(users.scrnames == x)]]@.xData[[attri]], NA))
}
write.table(data.clean, 'processed_data/oct_19_clean_training_data.txt')









