library(dplyr)
library(stringr)

files <- list.files(path = "D:/online class/Math 297 - Predictive Analytics/Analytics Activity/Term Paper/", pattern = "*.csv", full.names = TRUE)

df <- do.call(rbind, lapply(files, read.csv))

write.csv(df, paste(getwd(), "/data_compiled.csv", sep = ""), row.names = FALSE)


#####################################################################

df <- read.csv(paste(getwd(), "/data_compiled.csv", sep = ""))

pos_title <- unlist(lapply(gregexpr(pattern ='\n',df$x), `[[`, 1))

#extract title
title <- substr(df$x, 1, pos_title) %>% gsub("\n", "", .)

nowsdf <- df$x %>% gsub("\\s+", "", .)

pos_yr <- unlist(lapply(gregexpr(pattern ='[(]\\d{4}[)]',nowsdf), `[[`, 1))

#extract year
year <- str_match(nowsdf, "[(]\\d{4}[)]") %>% gsub("[()]", "", .) %>% as.numeric()

#extract rating
rating <- str_match(nowsdf, "[+][0-9.]+[+]") %>% gsub("[+]", "", .) %>% as.numeric()

#extract genre
genre1 <- str_match(nowsdf, "[+][0-9.]+[+].*?[+]") %>% gsub("[+0-9.]+", "", .)

#extract budget
budget <- str_match(nowsdf, "Budget[$0-9.,-?]+") %>% gsub("[Budget$,]|[.]00", "", .) %>% gsub("[-]", "0", .) %>% as.numeric()

#extract revenue
revenue <- str_match(nowsdf, "Revenue[$0-9.,-?]+") %>% gsub("[Revenue$,]|[.]00", "", .) %>% gsub("[-]", "0", .) %>% as.numeric()

#extract runtime
runtime <- str_match(nowsdf, "[+][0-9][0-9]?[a-z]\\w*") %>% gsub("[+]", "", .)

################################################################################

#function to convert runtime to numeric and minutes format
convertruntime <- function(x){
  pos_h <- unlist(str_locate_all(x, "h"))[1]
  pos_m <- unlist(str_locate_all(x, "m"))[1]
    
  if (is.na(pos_h) == FALSE){
    
    h <- substr(x, 1, pos_h-1) %>% as.numeric()
      
      if (is.na(pos_m) == FALSE){
        
        m <- substr(x, pos_h+1, pos_m-1) %>% as.numeric()
        time <- h * 60 + m
        
      } else {
        
        time <- h * 60
        
      }
  } else {
    
    if (is.na(pos_m) == FALSE){
      m <- substr(x, 1, pos_m-1) %>% as.numeric()
      time <- m
    } else {
      time <- NA
    }
    
  }
  return(time)
}

#new runtime
runtime <- sapply(runtime, FUN = convertruntime, USE.NAMES = FALSE) %>% as.numeric()

#create dummy vars with genre
df.genre <- data.frame(genre = genre1)
list.genre <- read.csv(paste(getwd(), "/genre.csv", sep = ""))

for (i in list.genre$genre){
  df.genre <- df.genre %>%
    mutate(!!sym(i) := str_detect(genre1, i)*1)
}

finaldf <- df.genre %>%
  mutate(
    title = title,
    year = year,
    rating = rating,
    budget = budget,
    revenue = revenue,
    runtime = runtime
  )

finaldf <- finaldf[ , -1]

write.csv(finaldf, paste(getwd(), "/final data.csv", sep = ""), row.names = FALSE)
