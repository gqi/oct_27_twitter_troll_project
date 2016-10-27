library(RCurl)
library(twitteR)
library(readr)
library(rvest)
library(dplyr)
library(stringr)

swear = tolower(read.table('raw_data/swearwords_clean.txt',
                   stringsAsFactors = FALSE)[,1])
insult = tolower(read.table('raw_data/insultwords.txt',
                    stringsAsFactors = FALSE)[,1])
bad = tolower(read.table('raw_data/bad_words.txt',
                 stringsAsFactors = FALSE)[,1])

## Remove repetitions
insult = setdiff(insult, swear)
bad = setdiff(bad, c(swear, insult))
## Concatenate
negwords = c(swear, insult, bad)

## Read 100 most followed user list
top100followed = read.table('raw_data/oct_16_top100followed_twitter_accounts.txt',
                            stringsAsFactors = FALSE)[,1]
top100followed.clean = gsub(' ', '_', top100followed)

## Read in tweets from 100 most followed users
top100tweets = list()
for (name in top100followed.clean[1:3]){
    load(paste0('raw_data/oct_16_', name, '_tweets.RData'))
    top100tweets[[name]] = tweets
}

## Match negwords list to top100tweets
par(mfrow = c(1,3))
for (keyword in names(top100tweets)){
    tweetslist = top100tweets[[keyword]]
    swear.num  = vector(length = length(tweetslist))
    for (i in 1:length(tweetslist)){
        tweet = tweetslist[[i]]
        text = gsub("[^a-zA-Z0-9 ]", '', tweet@.xData$text)
        swear.num[i] = sum(sapply(1:length(negwords), function(x) length(grep(tolower(negwords[x]), tolower(text)))>=1))
    }
    thr = 5
    hist(swear.num, xlab = 'Number of matched words', main = keyword)
    abline(v = thr, col = 2)
    
    print(paste0('TWEETS ABOUT ', keyword))
    for (i in 1:length(tweetslist)){
        if (swear.num[i] >= thr){
            print(i)
            print(tweetslist[[i]])
        }
    }
}

