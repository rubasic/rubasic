% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_songs_clusters.R
\name{plot_songs_clusters}
\alias{plot_songs_clusters}
\title{Plot Songs Clusters}
\usage{
plot_songs_clusters(songs, year_taken)
}
\arguments{
\item{songs}{a dataframe containing the new songs pulled from an API formated with format_new_songs}

\item{year_taken}{an integer containting the year to be compared with}
}
\value{
the dataframe with additional column for cluster
}
\description{
Return a plot element for a song and a year, in comparison to other billboard tracks in that year
}
\examples{
 \dontrun{
plot_songs_clusters(songs,1991)
}
}
