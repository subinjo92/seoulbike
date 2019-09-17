real_time_prediction <- function(id, key){

  load(paste0('./prediction_model/', id, '.RData'))
  predict(model$finalModel, newdata = real_time_crawling(id, 1, key))
}
