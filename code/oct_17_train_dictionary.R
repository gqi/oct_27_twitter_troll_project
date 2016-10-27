rm(list = ls())
library(RCurl)
library(twitteR)
library(readr)
library(rvest)
library(dplyr)
library(stringr)
library(wordcloud)

swear = tolower(read.table('raw_data/swearwords_clean_oct_17.txt',
                           stringsAsFactors = FALSE)[,1])
insult = tolower(read.table('raw_data/insultwords.txt',
                            stringsAsFactors = FALSE)[,1])
bad = tolower(read.table('raw_data/bad_words.txt',
                         stringsAsFactors = FALSE)[,1])
common = read.table('raw_data/commonwords.txt', 
                    stringsAsFactors = FALSE)[,1]
## Remove repetitions and common words
insult = setdiff(insult, swear)
bad = setdiff(bad, c(swear, insult))
## Remove common words
swear = setdiff(swear, common)
insult = setdiff(insult, common)
bad = setdiff(bad, common)
# ## Remove the words of < 3 letters
# swear = swear[nchar(swear)>=3]
# insult = insult[nchar(insult)>=3]
# bad = bad[nchar(bad)>=3]


## Concatenate
negwords = c(swear, insult, bad)

## Read 100 most followed user list
top100followed = read.table('raw_data/oct_16_top100followed_twitter_accounts.txt',
                            stringsAsFactors = FALSE)[,1]
top100followed.clean = gsub(' ', '_', top100followed)

## Read in tweets from 100 most followed users
top100tweets = list()
for (name in top100followed.clean[1:74]){
    load(paste0('raw_data/oct_17_', name, '_tweets.RData'))
    top100tweets[[name]] = tweets
}

#### Match the negative words
matchwords = list()
top100trolls = list()
for (keyword in names(top100tweets)){
    tweetslist = top100tweets[[keyword]]
    matchwords[[keyword]] = vector('list', length = length(tweetslist))
    ## Initialize troll list
    top100trolls[[keyword]] = vector()
    
    swear.num  = vector(length = length(tweetslist))
    for (i in 1:length(tweetslist)){
        tweet = tweetslist[[i]]
        text = gsub('.+: ', '', tweet@.xData$text)
        text = gsub("[^a-zA-Z0-9 ]", '', text)
        text = paste0(' ', text, ' ')
        
        
        matchwords[[keyword]][[i]] = negwords[sapply(1:length(negwords), function(x) length(grep(paste0(' ', tolower(negwords[x]), ' '), tolower(text)))>=1)]
        
        swear.num[i] = length(matchwords[[keyword]][[i]])
        
    }
    thr = 2 #  140/6.1*0.15: 15% words are negative words

    print(paste0('TWEETS ABOUT ', keyword))
    for (i in 1:length(tweetslist)){
        if (swear.num[i] >= thr){
            top100trolls[[keyword]] = c(top100trolls[[keyword]], tweetslist[[i]])
            print(i)
            print(tweetslist[[i]])
        }
    }
}
troll.num = sapply(top100trolls, length)
print(sum(troll.num))

## View distribution of number of matches
matchnum = vector()
for (keyword in names(matchwords)){
    matchnum = c(matchnum, sapply(matchwords[[keyword]], length))
}
hist(matchnum, breaks = 0:5)

## View matched word frequency
negwords.freq = vector()
for (keyword in names(matchwords)){
    negwords.freq = c(negwords.freq, do.call(c, matchwords[[keyword]]))
}
tab = table(negwords.freq)
par(mfrow = c(1,1))
wordcloud(names(tab), as.vector(tab), random.order = FALSE)


## Retrieve potential troll user list
trollusers = vector()
for (keyword in names(top100trolls)){
    if (length(top100trolls[[keyword]])>0){
        for (i in 1:length(top100trolls[[keyword]])){
            temp = top100trolls[[keyword]][[i]]@.xData$screenName
            trollusers = c(trollusers, temp)
        }
    }
}
trollusers.tab = table(trollusers)
trollusers.highfreq = names(trollusers.tab)[as.vector(trollusers.tab)>=2]
trollusers.uniq = unique(trollusers)

# # Search troll user information
# source('twitter_api.R')
# setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
# trolluserinfo = lookupUsers(trollusers.uniq)
# save(trolluserinfo, file = 'raw_data/oct_18_troll_user_info.RData')

load('raw_data/oct_18_troll_user_info.RData')
followernum = vector()
for (name in names(trolluserinfo)){
    followernum = c(followernum, trolluserinfo[[name]]@.xData$followersCount)
}
favornum = vector()
for (name in names(trolluserinfo)){
    favornum = c(favornum, trolluserinfo[[name]]@.xData$favoritesCount)
}
friendnum = vector()
for (name in names(trolluserinfo)){
    friendnum = c(friendnum, trolluserinfo[[name]]@.xData$friendsCount)
}

par(mfrow = c(1,3))
hist(followernum, breaks = 30, main = '', xlab = 'Number of followers')
hist(favornum, breaks = 30, main = '', xlab = 'Number of favorites')
hist(friendnum, breaks = 30, main = '', xlab = 'Number of friends')








## Match negwords list to top100tweets
# par(mfrow = c(2,3))
# for (keyword in names(top100tweets)[1:6]){
#     tweetslist = top100tweets[[keyword]]
#     swear.num  = vector(length = length(tweetslist))
#     for (i in 1:length(tweetslist)){
#         tweet = tweetslist[[i]]
#         text = gsub("[^a-zA-Z0-9 ]", '', tweet@.xData$text)
#         swear.num[i] = sum(sapply(1:length(negwords), function(x) length(grep(tolower(negwords[x]), tolower(text)))>=1))
#     }
#     thr = 4
#     hist(swear.num, xlab = 'Number of matched words', main = keyword)
#     abline(v = thr, col = 2)
#     
#     print(paste0('TWEETS ABOUT ', keyword))
#     for (i in 1:length(tweetslist)){
#         if (swear.num[i] >= thr){
#             print(i)
#             print(tweetslist[[i]])
#         }
#     }
# }

