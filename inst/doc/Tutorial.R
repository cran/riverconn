## ----setup, echo = FALSE------------------------------------------------------
knitr::opts_chunk$set(crop = FALSE)


## ----graph example, message = FALSE, collapse = TRUE, width = 60, warning = FALSE, echo = FALSE----
library(igraph)
g <- graph_from_literal(1-+2, 2-+4, 3-+2, 4-+6, 6-+7, 5-+6, 7-+8, 9-+5, 10-+5 )
oldpar <- par(mfrow = c(1,1))
par(mfrow=c(1,2))
plot(g, layout = layout_as_tree(as.undirected(g), root = 8, flip.y = FALSE))
plot(as.undirected(g), layout = layout_as_tree(as.undirected(g), root = 8, flip.y = FALSE))
par(oldpar)

## ----libraries, message = FALSE, collapse = TRUE, width = 60, warning = FALSE----
library(igraph)
library(dplyr)
library(tidyr)
library(viridis)
library(riverconn)
library(doParallel)

## ----g definition, message = FALSE, collapse = TRUE, width = 60, warning = FALSE----
g <- graph_from_literal(1-+2, 2-+5, 3-+4, 4-+5, 6-+7, 7-+10, 8-+9, 9-+10, 
                        5-+11, 11-+12, 10-+13, 13-+12, 12-+14, 14-+15, 15-+16)
g

## ----g inspection, message = FALSE, collapse = TRUE, width = 60, warning = FALSE----
# Edges
E(g)

# vertices
V(g)


## ----g as sf, message = FALSE, collapse = TRUE, width = 60, warning = FALSE----
igraph::as_data_frame(g, what = "edges")

igraph::as_data_frame(g, what = "vertices")


## ----g as adj, message = FALSE, collapse = TRUE, width = 60, warning = FALSE----
igraph::as_adjacency_matrix(g)

## ----g decorate, message = FALSE, collapse = TRUE, width = 60, warning = FALSE----
# Decorate edges 
E(g)$id_dam <- c("1", NA, "2", "3", NA, "4", NA, "5", "6", NA,  NA, NA, NA, "7", NA)
E(g)$type <- ifelse(is.na(E(g)$id_dam), "joint", "dam")
E(g)

# Decorate vertices
V(g)$length <- c(1, 1, 2, 3, 4, 1, 5, 1, 7, 7, 3, 2, 4, 5, 6, 9)
V(g)$HSI <- c(0.2, 0.1, 0.3, 0.4, 0.5, 0.5, 0.5, 0.6, 0.7, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8)
V(g)$Id <- V(g)$name
V(g)


## ----direction, message = FALSE, collapse = TRUE, width = 60, warning = FALSE----
oldpar <- par(mfrow = c(1,1))
par(mfrow=c(1,3))
g1 <- set_graph_directionality(g, field_name = "Id", outlet_name = "16")
g2 <- set_graph_directionality(g, field_name = "Id", outlet_name = "5")
plot(as.undirected(g), layout = layout_as_tree(as.undirected(g), root = 8, flip.y = FALSE))
plot(g1, layout = layout_as_tree(as.undirected(g1), root = 16, flip.y = FALSE))
plot(g2, layout = layout_as_tree(as.undirected(g2), root = 5, flip.y = FALSE))
par(oldpar)

## ----pass def, message = FALSE, collapse = TRUE, width = 60, warning = FALSE----
# Check edged and nodes attributes, add pass_u and pass_d fields
g_v_df <- igraph::as_data_frame(g, what = "vertices")
g_v_df
g_e_df <- igraph::as_data_frame(g, what = "edges") %>%
  mutate(pass_u = ifelse(!is.na(id_dam),0.1,NA),
         pass_d = ifelse(!is.na(id_dam),0.7,NA))
g_e_df

# Recreate graph
g <- igraph::graph_from_data_frame(d = g_e_df, vertices = g_v_df)
g 

## ----index 1, message = FALSE, collapse = TRUE, width = 60, warning = FALSE----
index_calculation(g, param = 0.9)


## ----index 2, message = FALSE, collapse = TRUE, width = 60, warning = FALSE----
index_calculation(g, B_ij_flag = FALSE)
index_calculation(g, param = 0.9, c_ij_flag = FALSE)


## ----index 3, message = FALSE, collapse = TRUE, width = 60, warning = FALSE----
index_calculation(g, c_ij_flag = FALSE,
                  dir_distance_type = "asymmetric", 
                  disp_type = "threshold", param_u = 0, param_d = 5)
index_calculation(g, c_ij_flag = FALSE,
                  dir_distance_type = "asymmetric", 
                  disp_type = "threshold", param_u = 5, param_d = 10)
index_calculation(g, c_ij_flag = FALSE,
                  dir_distance_type = "symmetric", 
                  disp_type = "threshold", param = 10)


## ----index 4, message = FALSE, collapse = TRUE, width = 60, warning = FALSE----
index_calculation(g, c_ij_flag = FALSE,
                  index_type = "reach", index_mode = "to",
                  dir_distance_type = "asymmetric", 
                  disp_type = "threshold", param_u = 0, param_d = 5)
index_calculation(g, c_ij_flag = FALSE,
                  dir_distance_type = "asymmetric",
                  index_type = "reach", index_mode = "to",
                  disp_type = "threshold", param_u = 5, param_d = 10)
index_calculation(g, c_ij_flag = FALSE,
                  index_type = "reach", index_mode = "to",
                  dir_distance_type = "symmetric", 
                  disp_type = "threshold", param = 10)


## ----idams metadata, message = FALSE, collapse = TRUE, width = 60, warning = FALSE----
dams_metadata <- data.frame("id_dam" =  c("1", "2", "3", "4", "5", "6", "7"),
                            "pass_u_updated" = c(1, 1, 1, 1, 1, 1, 1),
                            "pass_d_updated" = c(1, 1, 1, 1, 1, 1, 1))
dams_metadata

d_index_calculation(g,
                    barriers_metadata = dams_metadata,
                    id_barrier = "id_dam",
                    parallel = FALSE, ncores = 3,
                    param_u = 10,  param_d = 10, param = 0.5,
                    index_type = "full",
                    dir_distance_type = "asymmetric",
                    disp_type = "threshold")



