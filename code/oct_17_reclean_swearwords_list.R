swear = readLines('raw_data/swearwords.txt')
swear = swear[nchar(swear)>1]
swear = gsub(' - .+$', '', swear)
write.table(unique(tolower(swear)), 'raw_data/swearwords_clean_oct_17.txt',
            row.names = FALSE, col.names = FALSE)
