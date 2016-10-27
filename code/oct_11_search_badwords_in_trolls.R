library(RCurl)
library(twitteR)
library(readr)
library(rvest)
library(dplyr)
library(stringr)

load('raw_data/oct_10_tweets_swear.RData')
swear = read.table('raw_data/swearwords_clean.txt',
                   stringsAsFactors = FALSE)[,1]
insult = read.table('raw_data/insultwords.txt',
                    stringsAsFactors = FALSE)[,1]
bad = read.table('raw_data/bad_words.txt',
                 stringsAsFactors = FALSE)[,1]
negwords = c(swear, insult, bad)
negwords = unique(tolower(negwords))


load('raw_data/oct_9_pitt_tweets.RData')
load('raw_data/oct_9_aniston_tweets.RData')
load('raw_data/oct_9_jolie_tweets.RData')
load('raw_data/oct_9_pitt_divorce_tweets.RData')
load('raw_data/oct_9_jolie_divorce_tweets.RData')
load('raw_data/oct_9_pitt_jolie_tweets.RData')

all.tweets = list(Pitt = tweets.pitt, 
                  Jolie = tweets.jolie, 
                  Aniston = tweets.aniston,
                  Pitt_divorce = tweets.pitt.divorce,
                  Jolie_divorce = tweets.jolie.divorce,
                  Pitt_Jolie = tweets.pitt.jolie)
par(mfrow = c(2,3))
for (keyword in names(all.tweets)){
    tweetslist = all.tweets[[keyword]]
    swear.num  = vector(length = length(tweetslist))
    for (i in 1:length(tweetslist)){
        tweet = tweetslist[[i]]
        text = gsub("[^a-zA-Z0-9 ]", '', tweet@.xData$text)
        swear.num[i] = sum(sapply(1:length(negwords), function(x) length(grep(tolower(negwords[x]), tolower(text)))>=1))
    }
    thr = quantile(swear.num, 0.98)
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
