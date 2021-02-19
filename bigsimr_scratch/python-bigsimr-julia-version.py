from julia.api import Julia
jl = Julia(compiled_modules=False)
import julia
julia.install()

from julia import Bigsimr as bs
from julia import Distributions as dist
from julia.Bigsimr import Pearson, Spearman, Kendall
from julia.Bigsimr import rvec, cor, cor_randPD, cor_nearPD, cor_convert
from julia.Bigsimr import pearson_match, pearson_bounds

import numpy as np
import pandas as pd
from pydataset import data

df = data("airquality") # requires R installation
df = df[["Ozone", "Temp"]].dropna
df.shape

p = cor(np.asmatrix(df))

mu_temp = np.mean(df.Temp)
sd_temp = np.std(df.Temp)

mu_ozone = np.mean(np.log(df.Ozone))
sd_ozone = sqrt(mean((log(df$Ozone) - mean(log(df$Ozone)))^2))
