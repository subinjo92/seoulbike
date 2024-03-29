#' real-time information crawling
#'
#' A function that collects the required explanatory variables for the public bicycle demand prediction model in real time.
#'
#' @param id bicycle rental station id
#' @param weather_time Specify how many hours ago weather data should be collected
#' @param key Seoul Open Data Plaza api key
#' @return explanatory variables for the public bicycle demand prediction model in real time
#' @examples
#'   real_time_crawling(358, 1, key)
#' @export
real_time_crawling <- function(id, weather_time, key){
  if(!id %in% cycle_info$station_id){
    stop('Station is not in the training data.')
  }
  rent_info <- cycle_info[cycle_info$station_id == id,]
  rent_time <- Sys.time()
  rent_info <- rent_info %>%
    dplyr::select(station_id, sigungu, lat, lon, rent_name, holding_count, emd, school,
                  subway, culture, travel, han_river, population, id_si)

  #date, time
  date <- strsplit(as.character(Sys.time()), split = ' ', fixed = TRUE)[[1]][1]
  real_time <- strsplit(as.character(Sys.time()), split = ' ', fixed = TRUE)[[1]][2]

  month <- strsplit(date, split = '-', fixed = TRUE)[[1]][2]
  int_day <- strsplit(date, split = '-', fixed = TRUE)[[1]][3]

  time <- strsplit(real_time, split = ':', fixed = TRUE)[[1]][1]

  day <- as.character(lubridate::wday(Sys.Date(), label = T, locale = "English_United States"))

  int_day <- str_remove(int_day, '^0{1}')
  month <- str_remove(month, '^0{1}')
  time <- str_remove(time, '^0{1}')


  #air crawling
  real_air_url <- URLencode(iconv(paste0('http://openapi.seoul.go.kr:8088/', key, '/json/RealtimeCityAir/1/30'),
                                  localeToCharset()[1], to = 'UTF-8'))

  real_air_json <- getURL(real_air_url)
  air_processed_json <- fromJSON(real_air_json)
  air_processed <- air_processed_json$RealtimeCityAir$row

  air <- air_processed[air_processed$MSRSTE_NM == rent_info$sigungu, c('PM10', 'PM25', 'O3', 'NO2',  'CO', 'SO2')]

  #weather crawling
  time_weather <- str_replace_all(str_replace_all(str_replace_all(Sys.time() - hours(weather_time), ' ', ''), '-', ''), ':', '')
  time_weather_2 <- paste0(str_sub(time_weather, 1, 12), '00')

  real_weather_url <- paste0('http://openapi.seoul.go.kr:8088/', key, '/json/realTimeWeatherObserveInfo/1/100/', time_weather_2)
  real_weather_json <- getURL(real_weather_url)
  weather_processed_json <- fromJSON(real_weather_json)


  weather <- weather_processed_json$realTimeWeatherObserveInfo$row[weather_processed_json$realTimeWeatherObserveInfo$row$ID == rent_info$id_si,
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
