library(rvest)
library(dplyr)
insult.url = 'http://onlineslangdictionary.com/thesaurus/words+meaning+insults+(list+of).html'
htmlfile = read_html(insult.url)
xpath = '//li'
nds = html_nodes(htmlfile, xpath = xpath)
insult.dict = html_text(nds)[128][[1]][[1]] 
# %>% strsplit(split = '-')
insult.dict = gsub('[^a-zA-Z0-9]','&',insult_dict)
insult.dict = strsplit(insult.dict, '&&&')
insult.dict = insult.dict[[1]]
insult.dict = gsub('&', ' ', insult.dict)
insult.dict = insult.dict[9:length(insult.dict)]

insult.dict = insult.dict[nchar(insult.dict)!=1]
write.table(insult.dict, 'raw_data/insultwords.txt', 
            row.names = FALSE, col.names = FALSE)
