library(rvest)
library(dplyr)
controv.url = 'https://www.questia.com/library/controversial-topics'
htmlfile = read_html(controv.url)
xpath = '//*[contains(concat( " ", @class, " " ), concat( " ", "no-bullet-list", " " ))]//a'
nds = html_nodes(htmlfile, xpath = xpath)
controv.dict = html_text(nds)
# %>% strsplit(split = '-')
controv.dict = tolower(gsub('[^a-zA-Z -]','',controv.dict))
controv.dict = controv.dict[1:160]

write.table(controv.dict, 'raw_data/controvtopics.txt', 
            row.names = FALSE, col.names = FALSE)

