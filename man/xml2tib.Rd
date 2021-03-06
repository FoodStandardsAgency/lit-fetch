% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/xml2tib.R
\name{xml2tib}
\alias{xml2tib}
\title{Pick out nodes from xml and turn it into a tibble}
\usage{
xml2tib(xmlnodeset, nodenames, api)
}
\arguments{
\item{xmlnodeset}{an xml node containing nodes}

\item{nodenames}{the names of the nodes you wish to extract (string with nodes separated by commas)}

\item{api}{name of api and determines the indexing and the top node to index on (first element returned by rvest::xml_nodes)}
}
\value{
A tibble with node names as col names and node text as values
}
\description{
Extract xml nodes and turn xml to tibble
}
