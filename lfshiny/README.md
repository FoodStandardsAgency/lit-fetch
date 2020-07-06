
# lfshiny

<!-- badges: start -->
<!-- badges: end -->

This is the shiny app for users to access the search, filter and cleaning functionality,
and download the resulting references as a spreadsheet

To call the Springer API you will need to create an .Renviron
file with a variable called "SPRINGER_API" taking the value of your API key.

The app is built as an R package, using the {golem} framework. Functions (including 
the main UI and server functions) are defined in the `R` directory.

Dependencies necessary to run the app are captured using {renv}.



