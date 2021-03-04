using Bigsimr
using Distributions
using JLD

function fit_mom(NegativeBinomial, x)
    m = mean(x)
    s = std(x)
    size = m^2 / (s^2 - m)
    prob = m / s^2
    NegativeBinomial(size, prob)
end

brca = load("brca_matrix.jld", "brca")
brca_10k = brca[:,1:10000]
margins = [fit_mom(NegativeBinomial, x) for x in eachcol(brca_10k)]

corr = cor(brca_10k, Pearson)
adjusted_corr = pearson_match(corr, margins)
admissable_corr = cor_nearPD(adjusted_corr)

