library('RCurl')
library('twitteR')
library('readr')
library(rvest)
library(dplyr)
library(stringr)

swear = readLines('raw_data/swearwords.txt')
swear = swear[swear!='']
# Now clean the curse words dictionary swear and save it i vector swear.cl
swear.cl = swear %>% sapply(strsplit, split = ' - ') %>%
    unlist %>% unique
write.table(swear.cl, 'raw_data/swearwords_clean.txt',
            row.names = FALSE, col.names = FALSE)

source('twitter_api.R')
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

tweets.swear = list()
for (sw in swear.cl){
    print(sw)
    tweets.swear[[sw]] = searchTwitter(sw, n = 5, 
                                since = '2005-03-01', until = '2016-10-08',
                                lang = 'en')
    Sys.sleep(10)
    save(tweets.swear, file = 'raw_data/oct_10_tweets_swear.RData')
}

# load('raw_data/oct_9_pitt_tweets.RData')
# load('raw_data/oct_9_aniston_tweets.RData')
# load('raw_data/oct_9_jolie_tweets.RData')
# load('raw_data/oct_9_pitt_divorce_tweets.RData')
# load('raw_data/oct_9_jolie_divorce_tweets.RData')
# load('raw_data/oct_9_pitt_jolie_tweets.RData')

# swear.num  = vector(length = legnth(tweets.pitt))
# for (tweet in tweets.pitt){
#     swear.num = sum(sapply(swear.cl, function(x) length(grep(x, tweet@.xData$text))>1))
# }


