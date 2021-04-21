#' download UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList downloadButton
mod_download_ui <- function(id) {
  ns <- NS(id)
  tagList(
    downloadButton(ns("filedownload"), label = "Download articles")
  )
}


#' download Server Function
#'
#' @noRd
#' 
#' @importFrom openxlsx createWorkbook addWorksheet writeData saveWorkbook
mod_download_server <- function(id, r) {
  moduleServer(
    id,
    function(input, output, session) {

      output$filedownload <- downloadHandler(
        filename = "search_results.xlsx",
        
        content = function(file) {
          
          # --- INSTANTIATE WORKBOOK ---
          wb <- createWorkbook()
          addWorksheet(wb, "Search parameters")
          addWorksheet(wb, "Included articles")
          addWorksheet(wb, "Excluded articles")
          
          # --- SEARCH PARAMETERS ---
          writeData(
            wb,
            "Search parameters",
            data.frame(
              searchstring = r$search_result$search_query,
              `timeint (yyyy-mm-dd)` = paste0(
                r$search_result$date_from,
                " to ",
                r$search_result$date_to
              ),
              include = as.character(r$filtered_result$include_terms),
              exclude = as.character(r$filtered_result$exclude_terms),
              types = as.character(r$filtered_result$include_type),
              language = as.character(r$filtered_result$language),
              `searchdate (yyyy-mm-dd)` = Sys.Date() %>% as.character()
            )
          )
          
          # --- ARTICLES ---
          if (r$filtered_result$is_filtered) {
            writeData(
              wb,
              "Included articles",
              r$filtered_result$result$include
            )
            writeData(
              wb,
              "Excluded articles",
              r$filtered_result$result$exclude %>% select(-exclude)
            )
            
          } else {
            writeData(wb, "Included articles", r$search_result$result)
          }
          
          saveWorkbook(wb, file)
        }
      )
    }
  )
}
