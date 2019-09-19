real_time_bicycle <- function(id = 0){

  real_bicycle_url <- 'http://openapi.seoul.go.kr:8088/595a4551767667643630426b5a664b/json/bikeList/1/1000/'
  real_bicycle_json <- getURL(real_bicycle_url)
  bicycle_processed_json <- fromJSON(real_bicycle_json)

  real_bicycle_url_2 <- 'http://openapi.seoul.go.kr:8088/595a4551767667643630426b5a664b/json/bikeList/1001/2000/'
  real_bicycle_json_2 <- getURL(real_bicycle_url_2)
  bicycle_processed_json_2 <- fromJSON(real_bicycle_json_2)

  real_bicycle <- rbind(bicycle_processed_json$rentBikeStatus$row, bicycle_processed_json_2$rentBikeStatus$row)
  station_name <- data.frame(do.call('rbind', strsplit(real_bicycle$stationName, split = '.', fixed = T)))
  real_bicycle_2 <- cbind(real_bicycle, station_name$X1)

  real_bicycle_2$`station_name$X1` <- as.character(real_bicycle_2$`station_name$X1`)
  real_bicycle_2$rackTotCnt <- as.numeric(real_bicycle_2$rackTotCnt)
  real_bicycle_2$parkingBikeTotCnt <- as.numeric(real_bicycle_2$parkingBikeTotCnt)
  real_bicycle_2$shared <- as.numeric(real_bicycle_2$shared)

  real_bicycle_3 <- real_bicycle_2 %>%
    mutate(scaled_cnt = parkingBikeTotCnt / rackTotCnt) %>%
    dplyr::select(rackTotCnt, stationName, parkingBikeTotCnt, scaled_cnt, id = `station_name$X1`)

  if(id == 0){
    cbind(real_bicycle_3, Sys.time())
  }
  else if(!id %in% cycle_info$`대여소번호`){
    stop('학습데이터에 없는 대여소 입니다.')
  }
  else{
    cbind(real_bicycle_3[real_bicycle_3$id == id,], Sys.time())
  }
}
