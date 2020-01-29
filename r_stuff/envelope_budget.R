income <- 1726.17
rent <- 625.00
rent.admin <- 5.95
rent.fee <- 1.95
utility <- 35
savings <- 100
gas <- 70
cc1 <- 70
cc2 <- 300

remaining <- income - rent - rent.admin - rent.fee - utility - savings - cc1 - cc2 - gas

weekly.cash <- remaining / 4.33
weekly.food <- 40

daily.cash <- (weekly.cash - weekly.food) / 7

weekly.withdraw <- plyr::round_any(daily.cash, 5) * 7 + weekly.food

print(remaining)
print(weekly.withdraw)
