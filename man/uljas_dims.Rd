% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/uljas_user_functions.R
\name{uljas_dims}
\alias{uljas_dims}
\title{Get dimensions from Uljas api}
\usage{
uljas_dims(ifile, lang = "en")
}
\arguments{
\item{ifile}{a name of the statistics file with relative data directory path.
Get from \code{\link{uljas_stats}}}

\item{lang}{a language code. Available en, fi, se.}
}
\value{
a list.
}
\description{
\code{uljas_dims} return dimensions that are available for a certain statistics.
Use ifile from \code{\link{uljas_stats}}.
}
\examples{
  sitc_dims <- uljas_dims(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC")

}
