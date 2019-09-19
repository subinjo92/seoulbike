real_time_crawling <- function(id, weather_time, key){
  if(!id %in% cycle_info$station_id){
    stop('학습데이터에 없는 대여소 입니다.')
  }
  rent_info <- cycle_info[cycle_info$station_id == id,]
  rent_time <- Sys.time()
  rent_info <- rent_info %>%
    dplyr::select(id = 'station_id', sigungu = '구분', lat, lon, rent_name = '대여소명', holding_count = '거치대수', emd, school,
                  subway, culture, travel, han_river, population)

  #date, time
  date <- strsplit(as.character(Sys.time()), split = ' ', fixed = TRUE)[[1]][1]
  real_time <- strsplit(as.character(Sys.time()), split = ' ', fixed = TRUE)[[1]][2]

  month <- strsplit(date, split = '-', fixed = TRUE)[[1]][2]
  int_day <- strsplit(date, split = '-', fixed = TRUE)[[1]][3]

  time <- strsplit(real_time, split = ':', fixed = TRUE)[[1]][1]

  day <- as.character(wday(Sys.Date(), label = T, locale = "English_United States"))

  int_day <- str_remove(int_day, '^0{1}')
  month <- str_remove(month, '^0{1}')
  time <- str_remove(time, '^0{1}')


  #air crawling
  real_air_url <- URLencode(iconv(paste0('http://openapi.seoul.go.kr:8088/', key, '/json/RealtimeCityAir/1/30/도심권'),
                                  localeToCharset()[1], to = 'UTF-8'))

  real_air_json <- getURL(real_air_url)
  air_processed_json <- fromJSON(real_air_json)

  real_air_url_2 <- URLencode(iconv(paste0('http://openapi.seoul.go.kr:8088/', key, '/json/RealtimeCityAir/1/30/동북권'),
                                    localeToCharset()[1], to = 'UTF-8'))

  real_air_json_2 <- getURL(real_air_url_2)
  air_processed_json_2 <- fromJSON(real_air_json_2)

  real_air_url_3 <- URLencode(iconv(paste0('http://openapi.seoul.go.kr:8088/', key, '/json/RealtimeCityAir/1/30/동남권'),
                                    localeToCharset()[1], to = 'UTF-8'))

  real_air_json_3 <- getURL(real_air_url_3)
  air_processed_json_3 <- fromJSON(real_air_json_3)

  real_air_url_4 <- URLencode(iconv(paste0('http://openapi.seoul.go.kr:8088/', key, '/json/RealtimeCityAir/1/30/서북권'),
                                    localeToCharset()[1], to = 'UTF-8'))

  real_air_json_4 <- getURL(real_air_url_4)
  air_processed_json_4 <- fromJSON(real_air_json_4)

  real_air_url_5 <- URLencode(iconv(paste0('http://openapi.seoul.go.kr:8088/', key, '/json/RealtimeCityAir/1/30/서남권'),
                                    localeToCharset()[1], to = 'UTF-8'))

  real_air_json_5 <- getURL(real_air_url_5)
  air_processed_json_5 <- fromJSON(real_air_json_5)

  air_processed <- rbind(air_processed_json$RealtimeCityAir$row, air_processed_json_2$RealtimeCityAir$row, air_processed_json_3$RealtimeCityAir$row,
                         air_processed_json_4$RealtimeCityAir$row, air_processed_json_5$RealtimeCityAir$row)

  air <- air_processed[air_processed$MSRSTE_NM == rent_info$sigungu, c('PM10', 'PM25', 'O3', 'NO2',  'CO', 'SO2')]

  #weather crawling
  time_weather <- str_replace_all(str_replace_all(str_replace_all(Sys.time() - hours(weather_time), ' ', ''), '-', ''), ':', '')
  time_weather_2 <- paste0(str_sub(time_weather, 1, 12), '00')

  real_weather_url <- paste0('http://openapi.seoul.go.kr:8088/', key, '/json/realTimeWeatherObserveInfo/1/100/', time_weather_2)
  real_weather_json <- getURL(real_weather_url)
  weather_processed_json <- fromJSON(real_weather_json)

  id_si <- c(400, 402, 424, 404, 509, 413, 423, 417, 407, 406, 408, 410, 411, 412, 401, 421, 414, 403, 405, 510, 415, 416, 422, 419, 409)

  sigungu <- c('강남구', '강동구', '강북구', '강서구', '관악구', '광진구', '구로구', '금천구', '노원구', '도봉구', '동대문구',
               '동작구', '마포구', '서대문구', '서초구', '성동구', '성북구', '송파구', '양천구', '영등포구', '용산구', '은평구',
               '종로구', '중구', '중랑구')
  id_sigungu <- cbind(id_si, sigungu)

  temp_id <- ifelse(rent_info$sigungu == '종로구', '419', id_sigungu[rent_info$sigungu == id_sigungu[, 2], 1])

  weather <- weather_processed_json$realTimeWeatherObserveInfo$row[weather_processed_json$realTimeWeatherObserveInfo$row$ID == temp_id,
                                                                   c('S01A', 'S02A', 'S03M', 'S05A')]

  #interest
  interest <- ifelse(rent_info$rent_name %in% interest_area[,1], 1, 0)

  result <- cbind(rent_info, date, month, int_day, time, day, air, weather, interest)

  result$date <- as.character(result$date)
  result$month <- as.character(result$month)
  result$int_day <- as.character(result$int_day)
  result$time <- as.character(result$time)
  result$day <- as.character(result$day)
  result$interest <- as.character(result$interest)

  result$S01A <- as.numeric(result$S01A)
  result$S02A <- as.numeric(result$S02A)
  result$S03M <- as.numeric(result$S03M)
  result$S05A <- as.numeric(result$S05A)
  result$population <- as.numeric(result$population)

  result <- result %>%
    mutate(weekend = ifelse(day %in% c("Mon", "Tue", "Wed", "Thu"), 'weekday', ifelse(day == "Fri", "Fri", "weekend")))

  result$time <- factor(result$time, levels = levels(cycle_log_c_14_fac$time))
  result$day <- factor(result$day, levels = levels(cycle_log_c_14_fac$day))
  result$month <- factor(result$month, levels = levels(cycle_log_c_14_fac$month))
  result$weekend <- factor(result$weekend, levels = levels(cycle_log_c_14_fac$weekend))
  result$int_day <- factor(result$int_day, levels = levels(cycle_log_c_14_fac$int_day))

  result$PM10 <- as.integer(result$PM10)
  result$PM25 <- as.integer(result$PM25)

  if (is.na(result$S05A)){
    result$S05A <- cycle_log_c_14_fac[cycle_log_c_14_fac$month == result$month, 'humid_2'] %>% mean
  }

  result %>%
    rename(wind = 'S01A', temperature_2 = 'S02A', rain_2 = 'S03M', humid_2 = 'S05A')
}
