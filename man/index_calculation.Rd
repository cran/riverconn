% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/index_calculation.R
\name{index_calculation}
\alias{index_calculation}
\title{Reach- and Catchment-scale indices of connectivity}
\usage{
index_calculation(
  graph,
  weight = "length",
  nodes_id = "name",
  index_type = "full",
  index_mode = "to",
  c_ij_flag = TRUE,
  B_ij_flag = TRUE,
  dir_fragmentation_type = "symmetric",
  pass_confluence = 1,
  pass_u = "pass_u",
  pass_d = "pass_d",
  field_B = "length",
  dir_distance_type = "symmetric",
  disp_type = "exponential",
  param_u,
  param_d,
  param,
  param_l
)
}
\arguments{
\item{graph}{an object of class igraph. Can be both directed or undirected.}

\item{weight}{graph vertex attribute used to assign weights to the reaches (nodes/vertices). Should not be also an edge attribute.
Default is \code{"length"}.}

\item{nodes_id}{graph vertex attribute used to univoquely label reaches (nodes/vertices). Should not be also an edge attribute.
Default is \code{"name"}. The graph attribute must be a character vector.
Used to label the results when \code{index_type = "reach"}}

\item{index_type}{indicates if the index should be calculated for the whole catchment (\code{index_type = "full"}),
for each reach (\code{index_type = "reach"}), or for each barrier (\code{index_type = "sum"})}

\item{index_mode}{indicates if reach index should be calculated based on inbound links ("to") or outbound links ("from").
Only active when \code{index_type = "reach"}.}

\item{c_ij_flag}{include the presence of barriers in the calculations (c_ij term).}

\item{B_ij_flag}{include dispersal/movement among reaches in the calculations (B_ij term).}

\item{dir_fragmentation_type}{how directionality in c_ij calculations is dealt with:
\code{"symmetric"} (i.e. undirected graph) or \code{"asymmetric"} (i.e. directed graph). See details below.}

\item{pass_confluence}{a value in the range [0,1] that defines the passability of confluences (default is 1).}

\item{pass_u}{the 'graph' edge attribute to be used as upstream passability. Default is "pass_u".}

\item{pass_d}{the 'graph' edge attribute to be used as downstream passability. Default is "pass_d".}

\item{field_B}{the 'graph' vertex attribute to be used to calculate the distance. Should not be also an edge attribute.
Default is \code{"length"}.}

\item{dir_distance_type}{how directionality in B_ij calculations is dealt with:
\code{"symmetric"} (i.e. undirected graph) or \code{"asymmetric"} (i.e. directed graph). See details.}

\item{disp_type}{the formula used to calculate the probabilities in the B_ij matrix.
Use \code{"exponential"} for exponential decay, \code{"threshold"} for setting a distance threshold,
or \code{"leptokurtic"} for leptokurtic dispersal.}

\item{param_u}{upstream dispersal parameter. Must be a numeric value.
Only used if \code{dir_distance_type = "asymmetric"}. See details below.}

\item{param_d}{downstream dispersal parameter.
Must be a numeric value. Only used if \code{dir_distance_type = "asymmetric"}. See below for details.}

\item{param}{dispersal parameter. Must be a numeric value.
Only used if \code{dir_distance_type = "symmetric"}. See details below.}

\item{param_l}{the parameters for the leptokurtic dispersal mode. Must be a numeric vector of the
type \code{c(sigma_stat, sigma_mob, p)}. See details below.}
}
\value{
If \code{index_type = "full"}, returns a numeric value with the index value (column 'index').
if \code{index_type = c("reach", "sum")}, returns a data frame with the index value (column 'index') for each reach
(the field specified in 'nodes_id' is used for reach identification in the data frame).
In both cases, both numerator and denominator used in the index calculations are reported in the columns 'num' and 'den'.
}
\description{
Reach- and Catchment-scale indices of connectivity
}
\details{
Setting \code{c_ij_flag = FALSE} removes from the calculations the effect of barriers, i.e. the c_ij contribution
is not used in the calculation of the index.
Setting \code{B_ij_flag = FALSE} removes from the calculations the effect of movement/dispersal,
i.e. the B_ij contribution is not used in the calculation of the index.
Note that it is not possible to set both \code{c_ij_flag = FALSE} and \code{B_ij_flag = FALSE}.

The setting \code{dir_distance_type = "symmetric"} is to be used when the directionality of the river network is not relevant.
The distance between reaches midpoints is calculated for each couple of reaches.
The setting \code{dir_distance_type = "asymmetric"} is to be used when the directionality is relevant.
The distance between reaches midpoints is calculated for each couple of reaches and splitted
between 'upstream travelled' distance and 'downstream travelled' distance.
When \code{disp_type ="leptokurtic"} is selected, symmetric dispersal is assumed.

The 'param_u', 'param_d', and 'param' values are interpreted differently based on the formula used to relate distance (d_ij) and probability (B_ij).
When \code{disp_type ="exponential"}, those values are used as the base of the exponential dispersal kernel: B_ij = param^d_ij.
When \code{disp_type ="threshold"}, those values are used to define the maximum dispersal length: B_ij = ifelse(d_ij < param, 1, 0).

When \code{disp_type ="leptokurtic"} is selected, a leptokurtic dispersal kernel is used to calculate B_ij.
A leptokurtic dispersal kernel is a mixture of two zero-centered gaussian distributions with standard deviations
\code{sigma_stat} (static part of the population), and \code{sigma_mob} (mobile part of the population).
The probability of dispersal is calculated as: B_ij = p F(0, sigma_stat, d_ij) + (1-p) F(0, sigma_mob, d_ij)
where F is the upper tail of the gaussian cumulative density function.
}
\examples{
library(igraph)
g <- igraph::graph_from_literal(1-+2, 2-+5, 3-+4, 4-+5, 6-+7,
7-+10, 8-+9, 9-+10, 5-+11, 11-+12, 10-+13, 13-+12, 12-+14, 14-+15, 15-+16)
E(g)$id_dam <- c("1", NA, "2", "3", NA, "4", NA, "5", "6", NA,  NA, NA, NA, "7", NA)
E(g)$type <- ifelse(is.na(E(g)$id_dam), "joint", "dam")
V(g)$length <- c(1, 1, 2, 3, 4, 1, 5, 1, 7, 7, 3, 2, 4, 5, 6, 9)
V(g)$HSI <- c(0.2, 0.1, 0.3, 0.4, 0.5, 0.5, 0.5, 0.6, 0.7, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8)
V(g)$Id <- V(g)$name
E(g)$pass_u <- E(g)$pass_d <- ifelse(!is.na(E(g)$id_dam),0.1,NA)
index <- index_calculation(g, param = 0.9)


}
\references{
Baldan, D., Cunillera-Montcusí, D., Funk, A., & Hein, T. (2022). Introducing ‘riverconn’: an R package to assess river connectivity indices. Environmental Modelling & Software, 156, 105470.

Jumani, S., Deitch, M. J., Kaplan, D., Anderson, E. P., Krishnaswamy, J., Lecours, V., & Whiles, M. R. (2020). River fragmentation and flow alteration metrics: a review of methods and directions for future research. Environmental Research Letters, 15(12), 123009.

Radinger, J., & Wolter, C. (2014). Patterns and predictors of fish dispersal in rivers. Fish and fisheries, 15(3), 456-473.
}
