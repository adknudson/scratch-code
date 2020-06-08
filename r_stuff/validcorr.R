eye <- function(d) {
  A <- matrix(0, d, d)
  diag(A) <- 1.0
  A
}

Ps <- function(A) {
  eig <- eigen(A)
  Q <- eig$vectors
  D <- eig$values
  D <- diag(ifelse(D < 0, 0, D))
  Q %*% D %*% t(Q)
}

Pu <- function(X) {
  X - diag(diag(X)) + eye(ncol(X))
}

validcorr <- function(A) {
  d <- dim(A)
  stopifnot(length(d) == 2, d[1] == d[2])

  S <- matrix(0, d[1], d[2])
  Y <- A

  for (k in 1:(ncol(A)*100)) {
    R <- Y - S
    X <- Ps(R)
    S <- X - R
    Y <- Pu(X)
  }

  Pu(X)
}


pr <- matrix(c(1,     0.477, 0.644, 0.478, 0.651, 0.826,
               0.477, 1,     0.516, 0.233, 0.682, 0.75,
               0.644, 0.516, 1,     0.599, 0.581, 0.742,
               0.478, 0.233, 0.599, 1,     0.741, 0.8,
               0.651, 0.682, 0.581, 0.741, 1,     0.798,
               0.826, 0.75,  0.742, 0.8,   0.798, 1),
             nrow = 6, ncol = 6)
pr
system.time(round(Matrix::nearPD(pr)$mat, 3))
system.time(round(validcorr(pr), 3))
