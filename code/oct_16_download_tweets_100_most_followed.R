# ### Scrape 100 most followed Twitter users from the web
library(rvest)
top100_followed_url = "http://twittercounter.com/pages/100?vt=1&utm_expid=102679131-111.l9w6V73qSUykZciySuTZuA.1&utm_referrer=https%3A%2F%2Fwww.google.com%2F"
htmlfile = read_html(top100_followed_url)

xpath = '//*[(@id = "leaderboard")]//*[contains(concat( " ", @class, " " ), concat( " ", "name", " " ))] | //*[contains(concat( " ", @class, " " ), concat( " ", "name", " " ))]//span'
nds = html_nodes(htmlfile, xpath = xpath)
top100followed = html_text(nds)
# Clean the top 100 user list
top100followed = gsub('[^a-zA-Z ]', '', top100followed)
top100followed = gsub('^ +', '', top100followed)
top100followed = gsub(' +$', '', top100followed)
top100followed = unique(tolower(top100followed))
# write.table(top100followed, file = 'raw_data/oct_16_top100followed_twitter_accounts.txt')


### Download the tweets about the top 100 accounts
setwd('/users/gqi/twitter_troll_project')
top100followed = read.table('raw_data/oct_16_top100followed_twitter_accounts.txt',
                            stringsAsFactors = FALSE)[,1]
top100followed.clean = gsub(' ', '_', top100followed)
library('RCurl')
library('twitteR')
library('readr')
library(rvest)
library(dplyr)
library(stringr)

## Set up API authorization
source('twitter_api.R')
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

for (i in 1:length(top100followed)){
    user = top100followed[i]
    tweets = searchTwitter(user, n = 450, 
                           since = '2005-03-01', until = '2016-10-08',
                           lang = 'en')
    save(tweets, file = paste0('raw_data/oct_16_', top100followed.clean[i],'_tweets.RData'))
    print(paste0(i, ' ', user))
    print(length(tweets))
    Sys.sleep(900)
    
}