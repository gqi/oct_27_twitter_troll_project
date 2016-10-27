rm(list = ls())
library('RCurl')
library('twitteR')
library('readr')
library(rvest)
library(dplyr)
library(stringr)
library(e1071)

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
alltweets = do.call(c, top100tweets)

### Assemble information into data.frame
namelist = sapply(alltweets, function(x) x@.xData$screenName)
data.clean = data.frame(screenName = namelist)
for (attri in c('created', 'text', 'isRetweet', 'favoriteCount', 'retweetCount')){
    data.clean[, attri] = sapply(alltweets, function(x) x@.xData[[attri]])
}

load('raw_data/oct_19_top74_training_tweets_user_info.RData')
users = unique(users)
users.scrnames = sapply(users, function(x) x@.xData$screenName)
for (attri in c('name', 'protected', 'listedCount', 'followersCount', 'created', 'location', 'favoritesCount', 'friendsCount', 'verified', 'description')){
    data.clean[, attri] = sapply(data.clean$screenName,  function(x) ifelse(x %in% users.scrnames, 
                                                                            users[[which(users.scrnames == x)]]@.xData[[attri]], NA))
}
#######################################
######## Match negative words
# Preprocess word list
swear = tolower(read.table('raw_data/swearwords_clean_oct_17.txt',
                           stringsAsFactors = FALSE)[,1])
bad = tolower(read.table('raw_data/bad_words.txt',
                         stringsAsFactors = FALSE)[,1])
insult = tolower(read.table('raw_data/insultwords.txt',
                            stringsAsFactors = FALSE)[,1])
common = read.table('raw_data/commonwords.txt', 
                    stringsAsFactors = FALSE)[,1]
## Remove repetitions and common words
bad = setdiff(bad, swear)
insult = setdiff(insult, c(swear, bad))
# insult.phrase.ind = sapply(insult, function(x) length(grep(' ', x))>=1)
# insult = insult[!insult.phrase.ind]
## Remove common words
swear = setdiff(swear, common)
insult = setdiff(insult, common)
bad = setdiff(bad, common)
## Concatenate
negwords = c(swear, insult, bad)

## 
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

# negwordsNum = sapply(matchwords, length)
negwordsNum = matrix(nrow = length(matchwords), ncol = 3)
for (i in 1:nrow(negwordsNum)){
    if (length(matchwords[[i]])>0){
        temp = sapply(matchwords[[i]], function(x) which(negwords==x))
        negwordsNum[i,1] = sum(temp<=length(swear))
        negwordsNum[i,2] = sum(temp > length(swear) & temp <= length(c(swear,insult)))
        negwordsNum[i,3] = sum(temp > length(c(swear,insult)))
    } else{
        negwordsNum[i,] = 0
    }
}

png(file = 'figures/oct_23_distri_matchnum.png', width = 2300, height = 2100, res = 300)
par(mfrow = c(2,2), mar = c(3.5,3.5,2,1))
barplot(table(rowSums(negwordsNum)),
        main = '', xlab = '', ylab = '',
        ylim = c(0, 6000))
title(main = 'L', line = 0.5)
title(xlab = 'NWC', line = 2.5)
title(ylab = '# of tweets', line = 2.5)
for (i in 1:3){
    barplot(table(negwordsNum[,i]),
         main = '', xlab = '', ylab = '', 
         ylim = c(0, 6000))
    title(main = paste0('L', i), line = 0.5)
    title(xlab = paste0('NWC',i), line = 2.5)
    title(ylab = '# of tweets', line = 2.5)
}
dev.off()



data.clean$swearNum = negwordsNum[,1]
data.clean$insultNum = negwordsNum[,2]
data.clean$badNum = negwordsNum[,3]
data.clean$negNum = rowSums(negwordsNum)
data.modelfit = data.clean[rowSums(negwordsNum) > 0,]
data.modelfit = data.modelfit[complete.cases(data.modelfit),]
## We are generating indices wrt data.modelfit
# set.seed(765678)
# logistic.inds = sample(nrow(data.modelfit), 200, replace = FALSE)
# logistic.inds = logistic.inds[order(logistic.inds)]
# write.table(logistic.inds, 'processed_data/oct_23_logistic_inds_for_manual.txt')

logistic.inds = read.table('processed_data/oct_23_logistic_inds_for_manual.txt')[,1]

# for (i in 1:length(logistic.inds)){
#     ind = logistic.inds[i]
#     print(paste0(i,'    ', ind,'   ', data.modelfit[ind, 'text']))
# }

# Indices wrt logistic.inds
trollinds.temp = c(1, 2, 5, 8, 16, 18, 24, 29, 31, 37, 38, 40, 43, 45, 46,
              47, 48, 49, 50, 51,53, 56, 57, 65, 76, 87, 88, 89, 90, 92:97,
              103, 105, 106, 107, 117,118, 119, 120, 124, 128, 129, 132, 138, 156, 157, 
              161, 168:170, 171, 172, 173, 175, 192, 199, 200)

data.logit = data.modelfit[logistic.inds,]
data.logit$isTroll = FALSE
data.logit[trollinds.temp, 'isTroll'] = TRUE

# svm.mod = svm(as.factor(isTroll) ~ swearNum + insultNum + badNum + favoritesCount + 
#                   followersCount + friendsCount, data = data.logit)
# set.seed(18416)
# svm.mod.cv = tune.svm(as.factor(isTroll) ~ swearNum + insultNum + badNum,
#                       data = data.logit, gamma = 2^(-1:1), cost = 2^(1:4))
# plot(svm.mod.cv)
# summary(svm.mod.cv)

# pred = predict(svm.mod.cv$best.model, data.modelfit[-logistic.inds[trollinds.temp],])
# table(pred)

# test = data.modelfit[-logistic.inds[trollinds.temp],]
# test[pred,'text']

# mod = glm(isTroll ~ swearNum + badNum + insultNum + followersCount + 
#               friendsCount + favoritesCount, data = data.logit, family = binomial)
mod = glm(isTroll ~ swearNum + insultNum + badNum + friendsCount, 
          data = data.logit, family = binomial)
summary(mod)
# 
pred.data = data.modelfit[-logistic.inds,]
pred = predict.glm(mod, pred.data, type = 'response')
table(pred)
pred.data[pred > quantile(pred, 0.7), 'text']

# library(MASS)
# library(boot)
# library(caret)
# set.seed(2467)
# test = cv.glm(data.logit, mod, cost = function(u,v) mean(sapply(1:length(u), function(x) ifelse(u[x],4*abs(u[x]-v[x]),abs(u[x]-v[x])))), K=10)
# test$delta











###############################################
### Test performance
load('raw_data/oct_9_pitt_jolie_tweets.RData')
# Randomly choose 100 as test set
set.seed(65465)
testinds = sample(length(tweets.pitt.jolie), 100, replace = FALSE)
testinds = testinds[order(testinds)]
tweets.pitt.jolie.test = tweets.pitt.jolie[testinds]


namelist.pitt = sapply(tweets.pitt.jolie.test, function(x) x@.xData$screenName)
data.clean.pitt = data.frame(screenName = namelist.pitt)
for (attri in c('created', 'text', 'isRetweet', 'favoriteCount', 'retweetCount')){
    data.clean.pitt[, attri] = sapply(tweets.pitt.jolie.test, function(x) x@.xData[[attri]])
}

load('raw_data/oct_24_pitt_jolie_tweets_user_info.RData')
users.pitt.jolie = unique(users.pitt.jolie)
users.scrnames.pitt.jolie = sapply(users.pitt.jolie, function(x) x@.xData$screenName)
for (attri in c('name', 'protected', 'listedCount', 'followersCount', 'created', 'location', 'favoritesCount', 'friendsCount', 'verified', 'description')){
    data.clean.pitt[, attri] = sapply(data.clean.pitt$screenName,  function(x) ifelse(x %in% users.scrnames.pitt.jolie, 
                                                                            users.pitt.jolie[[which(users.scrnames.pitt.jolie == x)]]@.xData[[attri]], NA))
}

## Indices of tweets.pitt.jolie.test
trollinds.pitt.jolie = c(1, 6, 8, 26, 27,
                         29, 31, 40, 46, 52, 
                         56, 64, 65, 66, 68, 
                         69, 70, 89)
data.clean.pitt$isTroll = FALSE
data.clean.pitt[trollinds.pitt.jolie, 'isTroll'] = TRUE

matchwords.pitt.jolie = vector('list', length = length(tweets.pitt.jolie.test))
for (i in 1:length(tweets.pitt.jolie.test)){
    text = tweets.pitt.jolie.test[[i]]@.xData$text
    if (!is.na(text)){
        text = gsub('.+: ', '', text)
        text = gsub("[^a-zA-Z0-9 ]", '', text)
        text = tolower(paste0(' ', text, ' '))
        matchwords.pitt.jolie[[i]] = negwords[sapply(1:length(negwords), function(x) length(grep(paste0(' ', tolower(negwords[x]), ' '), tolower(text)))>=1)]
    }
}

negwordsNum.pitt.jolie = matrix(nrow = length(matchwords.pitt.jolie), ncol = 3)
for (i in 1:nrow(negwordsNum.pitt.jolie)){
    if (length(matchwords.pitt.jolie[[i]])>0){
        temp = sapply(matchwords.pitt.jolie[[i]], function(x) which(negwords==x))
        negwordsNum.pitt.jolie[i,1] = sum(temp<=length(swear))
        negwordsNum.pitt.jolie[i,2] = sum(temp > length(swear) & temp <= length(c(swear,insult)))
        negwordsNum.pitt.jolie[i,3] = sum(temp > length(c(swear,insult)))
    } else{
        negwordsNum.pitt.jolie[i,] = 0
    }
}

data.clean.pitt$swearNum = negwordsNum.pitt.jolie[,1]
data.clean.pitt$insultNum = negwordsNum.pitt.jolie[,2]
data.clean.pitt$badNum = negwordsNum.pitt.jolie[,3]
data.clean.pitt$negNum = rowSums(negwordsNum.pitt.jolie)

indices = which(rowSums(negwordsNum.pitt.jolie)>0)
data.clean.pitt.logit = data.clean.pitt[indices,]
# pred.svm.pitt = predict(svm.mod.cv$best.model, data.clean.pitt.logit)



# negwordsNum.pitt.jolie.logit = negwordsNum.pitt.jolie[rowSums(negwordsNum.pitt.jolie)>0,]
# tweets.pitt.jolie.test.logit = tweets.pitt.jolie.test[rowSums(negwordsNum.pitt.jolie)>0]
# pred.pitt.jolie = predict(mod, data.frame(swearNum = negwordsNum.pitt.jolie.logit[,1],
#                                           insultNum = negwordsNum.pitt.jolie.logit[,2],
#                                           badNum = negwordsNum.pitt.jolie.logit[,3]),
#                                           type = 'response')

pred.pitt.jolie = predict(mod, data.clean.pitt.logit, type = 'response')
data.clean.pitt.logit[pred.pitt.jolie > quantile(pred.pitt.jolie,0.7),'text']
## Search for 11 years, end up getting yesterday
test = sapply(alltweets, function(x) as.character(x@.xData$created))
test = gsub(' .+', '', test)
print(unique(test))

test = sapply(tweets.pitt.jolie, function(x) as.character(x@.xData$created))
test = gsub(' .+', '', test)
print(unique(test))



load('raw_data/oct_19_top74_training_tweets_user_info.RData')






# Sensitivity and specifity plot
probthr = seq(0,1,0.05)
sens.spec.mat = matrix(nrow = length(probthr), ncol = 3)
colnames(sens.spec.mat) = c('prob_threshold', 'sensitivity', 'specificity')
for (i in 1:length(probthr)){
    trollinds.pred.pitt = pred.pitt.jolie > probthr[i]
    originds = indices[trollinds.pred.pitt] 
    sensitivity = mean(trollinds.pitt.jolie %in% originds)
    specificity = 1 - mean(setdiff(1:nrow(data.clean.pitt), trollinds.pitt.jolie) %in% originds)
    
    sens.spec.mat[i,1] = probthr[i]
    sens.spec.mat[i,2] = sensitivity
    sens.spec.mat[i,3] = specificity
}
par(mfrow = c(1,1))
plot(1 - sens.spec.mat[,3], sens.spec.mat[,2], type = 'l')
