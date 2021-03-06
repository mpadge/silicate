#' TRI model, triangulations
#'
#' @param x object understood by silicate (sf, sp, a silicate model, etc.)
#' @param ... current unused
#' @param add logical create  new plot (default), or add to existing
#' @return TRI model
#' @export
TRI <- function(x, ...) {
  UseMethod("TRI")
}
#' @export
TRI.default <- function(x, ...) {
  ## TRI is earcut, so must be PATH based
  TRI(PATH(x), ...)
}
#' @export
TRI.TRI <- function(x, ...) {
  x
}
TRI.SC <- function(x, ...) {
  stop("constrained triangulation not supported, use anglr::DEL or reconstruct as PATH")
}
#' @export
TRI.PATH0 <- function(x, ...) {
  TRI(PATH(x), ...)
}
#' @export
TRI.PATH <- function(x, ...) {
  vertex <- sc_vertex(x)
  if (nrow(vertex) < 3) stop("need at least 3 coordinates")
  if (anyNA(vertex$x_)) stop("missing values in x_")
  if (anyNA(vertex$y_)) stop("missing values in y_")
  if (all(x$path$ncoords_ < 2)) stop("TRI for PATH cannot include degenerate paths, see '.$path$ncoords_'")
  if (any(x$path$ncoords_ < 3)) {
    warning("filtering out paths with fewer than 3 coordinates before attempting triangulation by ear clipping")
    x$path <- x$path %>% dplyr::filter(.data$ncoords_ > 2)
  }
  ## pretty sure I'll live to regret this ...
  ## (but the right alternative is a smart DEL visibility classifier )
  ## if we get lines, just pretend they all independently POLYGON
  if (!"subobject" %in% names(x$path)) {
    warning("assuming that all paths are independent (i.e. all islands, no holes)")
    ##x$path$subobject <- 1
    x$path <- x$path %>% dplyr::group_by(.data$object_) %>%
      dplyr::mutate(subobject = row_number(),
                    #subobject = .data$subobject_,
                    object = .data$object_) %>%
      dplyr::ungroup()
  }
  tri <- triangulate_0(x)
  tri$visible <- TRUE
  tri$path_ <- NULL

  obj <- sc_object(x)
  #obj <- obj[obj$object_ %in% tri$object_, ]
  meta <- tibble(proj = get_projection(x), ctime = Sys.time())

  structure(list(object = obj, #object_link_triangle = oXt,
                 triangle = tri,
                 vertex = sc_vertex(x),
                 meta = meta), class = c("TRI", "sc"))
}
#' @name sc_object
#' @export
sc_object.TRI <- function(x, ...) {
  x[["object"]]
}







