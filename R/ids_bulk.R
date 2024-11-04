ids_bulk <- function(file_url, file_path = tempfile(fileext = ".xlsx")) {

  rlang::check_installed(
    "readxl", reason = "to download bulk files."
  )

  cli::cli_inform("Downloading file to: {file_path}")
  utils::download.file(file_url, destfile = file_path, quiet = TRUE)

  cli::cli_inform("Reading in file.")
  bulk <- readxl::read_excel(file_path)

  cli::cli_inform("Deleting file.")
  unlink(file_path)

  bulk
}

