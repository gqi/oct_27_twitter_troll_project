library(rvest)
library(dplyr)
common.url = 'https://en.wikipedia.org/wiki/Most_common_words_in_English'
htmlfile = read_html(common.url)
xpath = '//td | //th'
nds = html_nodes(htmlfile, xpath = xpath)
common.dict = html_text(nds)
# %>% strsplit(split = '-')
common.dict = gsub('[^a-zA-Z]','',common.dict)
common.dict = common.dict[nchar(common.dict)>=1 & nchar(common.dict)<20]
common.dict = tolower(setdiff(unique(common.dict), c('Rank','Word')))

write.table(common.dict, 'raw_data/commonwords.txt', 
            row.names = FALSE, col.names = FALSE)