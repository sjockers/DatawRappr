#' Set Datawrapper-API-Key to system environment
#'
#' Adds Key to Environment to be available on Startup.
#'
#' @param api_key Required. A character string, containing the API-Key.
#' @param overwrite Optional. Should an existing key be overwritten? Defaults to \emph{FALSE}.
#'
#' @return A Message in the command line.
#' @author Benedict Witzenberger
#' @note This is a very simple function that adds the API-key to the .Renviron-file in the user's home folder. If a key already exists and the user requests to, it will get replaced.
#' @examples
#'
#' \dontrun{datawrapper_auth(api_key = "1234ABC")}
#'
#' \dontrun{datawrapper_auth(api_key = "1234ABC", overwrite = TRUE)}
#'
#' @rdname datawrapper_auth
#' @export
datawrapper_auth <- function(api_key, overwrite = FALSE) {

  # Access global environment file:
  filename <- paste0(Sys.getenv("HOME"), "/.Renviron")

  if (!file.exists(filename)) { # create .Renviron, if it doesn't exist
    file.create(filename)
  }

  # check if key already exists - if yes, check for overwrite = TRUE, else: write new key
  if (Sys.getenv("DW_KEY") != "") {

    if (overwrite == TRUE) {


      # old solution:
      # delete DW_KEY from .Renviron:
      # command <- paste0("sed -i '' '/^DW_KEY/d' ", filename)
      # system(command = command)
      #
      # # write new Key to to environment file:
      # new_key <- paste0('DW_KEY = ', api_key)
      # write(new_key, file = filename, append = TRUE)

      # base R-solution:
      txt_vector <- readLines(filename, n = -1)
      lines_delete <- which(grepl("^DW_KEY.*$", txt_vector))
      output_txt <- txt_vector[-lines_delete]

      # add new key:
      new_key <- paste0('DW_KEY = ', api_key)
      output_txt <- c(output_txt, new_key)
      writeLines(output_txt, filename)

      # reload Renviron after changing it:
      readRenviron(filename)

    } else if (overwrite == FALSE) { # if key exists, but overwrite is FALSE: throw warning and end function

      warning(paste0("A Datawrapper-key ", Sys.getenv("DW_KEY"), " already exists on this system.\nSet `overwrite = TRUE` to delete it."), immediate. = TRUE)

      }


  } else {

    # write new Key to to environment file
    new_key <- paste0('DW_KEY = ', api_key)
    write(new_key, file = filename, append = TRUE)
    readRenviron(filename)
    print("New key was saved!")

  }

}
