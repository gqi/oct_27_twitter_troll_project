library('RCurl')
library('twitteR')
load('raw_data/oct_9_pitt_jolie_tweets.RData')
namelist = sapply(tweets.pitt.jolie, function(x) x@.xData$screenName)
## Set up API authorization
source('twitter_api.R')
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
## Search
users.pitt.jolie = lookupUsers(namelist)
save(users.pitt.jolie, file = 'raw_data/oct_24_pitt_jolie_tweets_user_info.RData')
