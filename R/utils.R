#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL


#' Not in operator
#'
#' @name %notin%
#' @rdname notin
#' @keywords internal
#' @export
#' @usage lhs \%notin\% rhs
`%notin%` <- Negate(`%in%`)