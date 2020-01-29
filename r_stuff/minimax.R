A = matrix(
  c(
    0, 5, -1, -3, -2, 
    -1, 4, -1, 2, 4,
    4, 3, 0, 2, 4,
    1, 5, -2, -1, 1
  ),
  nrow = 4, byrow = TRUE)

B = matrix(1:16, nrow = 4, byrow = TRUE)

is.min <- function(v) {
  v == min(v)
}

is.max <- function(v) {
  v == max(v)
}

bool_to_val <- function(M, B) {
  M[!B] = NA
  M
}



minimax <-function(M) {
  colmax <- apply(M, 2, is.max)
  rowmin <- t(apply(M, 1, is.min))
  
  list(ColumnMax = colmax, RowMin = rowmin, SaddlePoint = colmax & rowmin)
}

A.mm <- minimax(A)
B.mm <- minimax(B)

bool_to_val(A, A.mm$SaddlePoint)
bool_to_val(B, B.mm$SaddlePoint)
