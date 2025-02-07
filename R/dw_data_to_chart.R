#' Fill a Datawrapper chart with data from R
#'
#' Uploads a dataframe to Datawrapper, returns a message.
#'
#' @param x Required. A R object of class 'data.frame',to be uploaded as the Datawrapper data.
#' @param chart_id Required. A Datawrapper-chart-id as character string, usually a five character combination of digits and letters, e.g. "aBcDe". Or a \emph{dw_chart}-object.
#' @param api_key Optional. A Datawrapper-API-key as character string. Defaults to "environment" - tries to automatically retrieve the key that's stored in the .Reviron-file by \code{\link{datawrapper_auth}}.
#'
#' @return A terminal message.
#' @author Benedict Witzenberger
#' @note This function uploads a R-dataframe to Datawrapper.
#' @examples
#'
#' \dontrun{dw_data_to_chart(df, "aBcDE")} # uses the preset key in the .Renviron-file
#'
#' \dontrun{dw_data_to_chart(df, chart_id = "a1B2Cd", api_key = "1234ABCD")} # uses the specified key
#'
#' @rdname dw_data_to_chart
#' @export
dw_data_to_chart <- function(x, chart_id, api_key = "environment") {

  if (api_key == "environment") {
    api_key <- dw_get_api_key()
  }

  chart_id <- dw_check_chart_id(chart_id)

  # try conversion - to avoid problems with tibbles
  x <- as.data.frame(x)

  # test class of input dataframe
  try(if (class(x) != "data.frame") stop("Data is not of class data.frame!"))

  # collapse the data in the dataframe as a string
  df_content <- paste(t(sapply(seq(1, nrow(x), by = 1), function(i)
    paste(unlist(x[i,]), collapse = ","))), collapse = "\n")

  # test if header contains separator symbol
  try(if (TRUE %in% grepl(",", names(x))) stop("The Dataframe's header contains a comma - which is used as the column separator. Remove the comma (e.g. with names()) and try again."))

  # collapse the header of the data as a string
  df_names <- paste(names(x), collapse = ",")

  # combine header and content of dataframe into character string
  data_body <- paste(df_names, df_content, sep = "\n")

  url <- paste0("https://api.datawrapper.de/v3/charts/", chart_id, "/data")

  r <- httr::PUT(url, httr::add_headers(Authorization = paste("Bearer", api_key, sep = " ")),
                 body = data_body)

  if (httr::status_code(r) == 200) {
    print("Chart updated.")
  }

}
