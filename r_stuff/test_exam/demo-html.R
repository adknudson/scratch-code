library("exams")

myexam <- c("q1a.Rmd", "q1b.Rmd", "q1c.Rmd")

set.seed(10)
exams2html(myexam, n = 3,
  encoding = "UTF-8",
  edir = "exercises",
  template = "templates/plain.html",
  converter = "pandoc-mathjax",
  dir = "output")
