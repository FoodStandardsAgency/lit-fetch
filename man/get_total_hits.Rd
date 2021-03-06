% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_total_hits.R
\name{get_total_hits}
\alias{get_total_hits}
\title{Search counter}
\usage{
get_total_hits(
  searchterm,
  datefrom = Sys.Date() - 365,
  dateto = Sys.Date() - 1,
  across
)
}
\arguments{
\item{searchterm}{string of search term}

\item{datefrom}{search articles published from (default one year ago)}

\item{dateto}{search articles published until (default today)}

\item{across}{list of APIs sources to be used}
}
\description{
gets a total search count across all sources
}
