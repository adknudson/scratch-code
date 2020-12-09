G <- function(x, c, s) exp(-log(2) * ((x-c) / s)^2)
L <- function(x, c, s) 1 / (1 + ((x-c)/s)^2)


N <- 200
Al <- 50
Cl <- 55
Sl <- 1.6

Ag <- 20
Cg <- 35
Sg <- 1.8

m <- 0.6

x <- seq(00, 100, length.out = N)
y <- rnorm(N, m*Al*L(x, Cl, Sl) + (1-m)*Ag*G(x, Cg, Sg), 0.1)
df <- data.frame(x=x, y=y)

plot(y ~ x, df)

write.csv(df, "data.csv")
