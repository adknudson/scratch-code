using DataFrames
using CSV
using RCall
using JLD

R"""
options(timeout = 240)
brca0 <- TCGA2STAT::getTCGA(disease = 'BRCA', data.type = 'RNASeq')
brca1 <- as.data.frame(t(brca0$dat))
gene_median <- apply(brca1, 2, median)
gene_median_order <- order(gene_median, decreasing = TRUE)
example_brca <- brca1[, gene_median_order]
"""

@rget example_brca
CSV.write("brca_df.csv", example_brca)

R"rm(list = ls())"

brca = Matrix{Float64}(example_brca)
save("brca_matrix.jld", "brca", brca)