#' Public Bicycle Rentalable Density Function
#'
#' Function showing the density function that can be rented when visiting the rental office in one hour
#'
#' @param id bicycle rental station id
#' @param key Seoul Open Data Plaza api key
#' @return Rentalable Density Function
#' @examples
#'   real_time_plot(358, key)
#' @export
real_time_plot <- function(id, key){

  load(paste0('./prediction_model/', id, '.RData'))
  pred_dat <- predict(model$finalModel, newdata = real_time_crawling(id, 1, key), predict.all = T)$individual
  max_line <- real_time_bicycle(id, key)$parkingBikeTotCnt -1

  density_dat <- data.frame(density(pred_dat, adjust = 1.5)[c("x", "y")])
  ggplot(density_dat, aes(x, y)) +
    geom_vline(xintercept = max_line, color = 'red', linetype="dashed") +
    geom_area(data = subset(density_dat, x < max_line), fill = "pink2", alpha = 0.7) +
    geom_area(data = subset(density_dat, x >= max_line), fill = "grey", alpha = 0.4) +
    xlab('Prediction') +
    ylab('Density')+
    theme_bw(base_size = 11)
}
