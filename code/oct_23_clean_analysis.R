rm(list = ls())
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
inds = read.table('processed_data/oct_19_indices_400_random_tweets_for_maual_classification.txt')[,1]
subset400tweets = alltweets[inds]
names(subset400tweets) = paste0('Tweet ', 1:400)
trollind = c(19, 22, 32, 47, 66,
             68, 74, 83, 86, 100,
             102, 103, 124, 136, 153,
             160, 165, 185, 192, 194,
             211, 212, 223, 230, 258, 
             268, 281, 285, 302, 303,
             318, 343, 364, 376, 384) 

## If it is citing something that contains bad words, cannot identify.
### This data frame contains missing values.
namelist = sapply(alltweets, function(x) x@.xData$screenName)
load('raw_data/oct_19_top74_training_tweets_user_info.RData')
users = unique(users)

## Create data frame
data.clean = data.frame(screenName = namelist)
data.clean$isTroll = NA
data.clean[inds[trollind], 'isTroll'] = TRUE
data.clean[inds[setdiff(1:400, trollind)], 'isTroll'] = FALSE
for (attri in c('created', 'text', 'isRetweet', 'favoriteCount', 'retweetCount')){
    data.clean[, attri] = sapply(alltweets, function(x) x@.xData[[attri]])
}
## Add user profile information
users.scrnames = sapply(users, function(x) x@.xData$screenName)
for (attri in c('name', 'protected', 'listedCount', 'followersCount', 'created', 'location', 'favoritesCount', 'friendsCount', 'verified', 'description')){
    data.clean[, attri] = sapply(data.clean$screenName,  function(x) ifelse(x %in% users.scrnames, 
                                                                            users[[which(users.scrnames == x)]]@.xData[[attri]], NA))
}
save(data.clean, file = 'processed_data/oct_23_clean_training_data.txt')

### Match negative words with text
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
## Concatenate
negwords = c(swear, insult, bad)

## Match words
matchwords = vector('list', length = nrow(data.clean))
for (i in 1:nrow(data.clean)){
    text = data.clean[i,'text']
    if (!is.na(text)){
        text = gsub('.+: ', '', text)
        text = gsub("[^a-zA-Z0-9 ]", '', text)
        text = tolower(paste0(' ', text, ' '))
        matchwords[[i]] = negwords[sapply(1:length(negwords), function(x) length(grep(paste0(' ', tolower(negwords[x]), ' '), tolower(text)))>=1)]
    }
}
negwordsNum = sapply(matchwords, length)
data.clean$negwordsNum = negwordsNum

# Match words in description
matchwords.desc = vector('list', length = nrow(data.clean))
for (i in 1:nrow(data.clean)){
    text = data.clean[i,'description']
    if (!is.na(text)){
        text = gsub('.+: ', '', text)
        text = gsub("[^a-zA-Z0-9 ]", '', text)
        text = tolower(paste0(' ', text, ' '))
        matchwords.desc[[i]] = negwords[sapply(1:length(negwords), function(x) length(grep(paste0(' ', tolower(negwords[x]), ' '), tolower(text)))>=1)]
    }
}
negwordsNum.desc = sapply(matchwords.desc, length)
data.clean$negwordsNum.desc = negwordsNum.desc

data.modelfit = data.clean[data.clean$negwordsNum>0 , 
                           c("screenName", "isTroll", 
                             "negwordsNum", 'text', # "negwordsNum.desc",
                            "isRetweet", "favoriteCount", 
                            "retweetCount", "followersCount",
                            "favoritesCount", "friendsCount")]
## We are generating indices wrt data.modelfit
set.seed(765678)
logistic.inds = sample(nrow(data.modelfit), 200, replace = FALSE)
logistic.inds = logistic.inds[order(logistic.inds)]
write.table(logistic.inds, 'processed_data/oct_23_logistic_inds_for_manual.txt')

trolltweets = c()

for (ind in logistic.inds){
    print(paste0(ind,'   ', data.modelfit[ind, 'text']))
}









# "negwordsNum", "negwordsNum.desc" "favoriteCount"
for (varname in names(data.modelfit)[3:ncol(data.modelfit)]){
    mod = glm(data.modelfit$isTroll ~ data.modelfit[,varname], family = 'binomial')
    print(varname)
    print(summary(mod))
}

mod = glm(isTroll ~ negwordsNum + favoritesCount, data = data.modelfit, family = 'binomial')


cmplcase.ind


## Remove all the cases where there are missing values outside isTroll column



data.clean = data.clean[complete.cases(data.clean[,-2]),]
cmplcase.ind = complete.cases(data.clean)










