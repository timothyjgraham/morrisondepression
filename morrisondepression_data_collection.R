# #MorrisonDepression hashtag analysis 
# 07/10/2020 4:30pm
# We collect 18000 latest tweets and run a state-of-the-art bot detection model:
# https://github.com/mkearney/tweetbotornot2

# libraries required 
require(tweetbotornot2)
require(glue)
require(dplyr)
require(rtweet)

# sociology TASA keys 
api_key <- "G3MQONk4InSpaEbLEEii83NeR"
api_secret_key <- "sjhQId8edr4nSkccyDiwJwogA6vqHoGDkqGSnTXNCnlQ8kpvkM"
access_token <- "875178186383835137-iVunpJKrBqGdP9o59zICU20wzU4mwyD"
access_token_secret <- "ypOqFVOYtuwbXQZ9875iKUAZ7ijtRATFPbnZ6GgnC7MhL"

token <- create_token(
  app = "TimRTestingApp",
  consumer_key = api_key,
  consumer_secret = api_secret_key,
  access_token = access_token,
  access_secret = access_token_secret)

######################################################
#### COLLECTION - tweets containing #morrisondepression
tweet_search_morrisondepression <- search_tweets('#morrisondepression', n = 18000, include_rts = TRUE, retryonratelimit = TRUE)
saveRDS(tweet_search_morrisondepression, paste0(Sys.time()," tweet_search_morrisondepression.rds"))
# length(unique(tweet_search_morrisondepression$screen_name))

# run sentiment analysis 
library(vader)

tweet_search_morrisondepression_SENTIMENT_SCORES_VADER <- vader_df(tweet_search_morrisondepression$text)
colnames(tweet_search_morrisondepression_SENTIMENT_SCORES_VADER)
# copy status ID across to sentiment dataframe, so we can join the datasets in Tableau 
tweet_search_morrisondepression_SENTIMENT_SCORES_VADER$status_id <- tweet_search_morrisondepression$status_id
# write to disk
library(openxlsx)
write.xlsx(tweet_search_morrisondepression_SENTIMENT_SCORES_VADER,paste0(Sys.time(),"_tweet_search_morrisondepression_SENTIMENT_SCORES_VADER.xlsx"))

# SAVE TO DISK
library(dplyr)
df_combined_morrisondepression <- tweet_search_morrisondepression %>% distinct(status_id, .keep_all = TRUE)
dim(df_combined_morrisondepression)
# subset only the columns we want to save to disk, and append sentiment scores 
df_combined_morrisondepression_TO_DISK <- cbind(df_combined_morrisondepression[,c(1:6,14:16,48:62,63:66,82:83)],tweet_search_morrisondepression_SENTIMENT_SCORES_VADER)
write.csv(df_combined_morrisondepression_TO_DISK,paste0(Sys.time()," tweet_search_morrisondepression.csv"),row.names = F)
# write tweet IDs to disk
write.table(df_combined_morrisondepression$status_id,paste0(Sys.time(),"_morrisondepression_tweet_ids.csv"), row.names = F, col.names = F, sep=",")


