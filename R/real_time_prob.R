#' Public Bicycle Rentability
#'
#' A function that calculates the probability of public bicycle rental when visiting a specific rental office after one hour.
#'
#' @param id bicycle rental station id
#' @param key Seoul Open Data Plaza api key
#' @return Public Bicycle Rentability
#' @examples
#'   real_time_prob(358, key)
#' @export
real_time_prob <- function(id, key){

  load(paste0('./prediction_model/', id, '.RData'))
  mean(predict(model$finalModel, newdata = real_time_crawling(id, 1, key), predict.all=T)$individual <= real_time_bicycle(id, key)$parkingBikeTotCnt -1)
}
