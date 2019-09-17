real_time_prediction <- function(id, key){

  load(paste0('./data/deriveddata/station_rf/', id, '.RData'))
  predict(model$finalModel, newdata = real_time_crawling(id, 1, key))
}
