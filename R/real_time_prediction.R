#' Predicting the Demand of Public Bicycles for an hour
#'
#' A function to predict the demand that will occur over an hour at a particular rental office.
#'
#' @param id bicycle rental station id
#' @param key Seoul Open Data Plaza api key
#' @return Predictive demand that will occur over an hour
#' @examples
#'   real_time_prediction(358, key)
#' @export

real_time_prediction <- function(id, key){

  load(paste0('./prediction_model/', id, '.RData'))
  predict(model$finalModel, newdata = real_time_crawling(id, 1, key))
}
