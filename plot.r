require("simplermarkdown")
d <- read.csv("result.csv", header = T, stringsAsFactors = F, sep = ",")
d$t1 <- strptime(d$start_time, "%Y-%m-%d %H:%M:%OS")
d$t2 <- strptime(d$stop_time, "%Y-%m-%d %H:%M:%OS")
d$total_seconds <- round(as.double(d$t2 - d$t1), 3)
d$rows_per_second <- round(d$records / d$total_seconds)

d2 <- data.frame(
  start_time = d$t1,
  stop_time = d$t2,
  total_seconds = d$total_seconds,
  total_records = d$records,
  partitions = d$partitions,
  rows_per_second = d$rows_per_second
)
md_table(d2)

p1 <- subset(d, partitions == 1)
p3 <- subset(d, partitions == 3)
p5 <- subset(d, partitions == 5)
p10 <- subset(d, partitions == 10)

plot(records ~ total_seconds, data = p1, xlab = "seconds", ylab = "records", cex = 2, pch = 20, col = "red") # nolint
lines(records ~ total_seconds, data = p1, lwd = 2, col = "red")

points(records ~ total_seconds, data = p3, cex = 2, pch = 20, col = "orange")
lines(records ~ total_seconds, data = p3, lwd = 2, col = "orange")

points(records ~ total_seconds, data = p5, cex = 2, pch = 20, col = "green")
lines(records ~ total_seconds, data = p5, lwd = 2, col = "green")

points(records ~ total_seconds, data = p10, cex = 2, pch = 20, col = "purple")
lines(records ~ total_seconds, data = p10, lwd = 2, col = "purple")

leg.txt <- c("tasks.max=10", "tasks.max=5", "tasks.max=3", "tasks.max=1")

legend(list(x = 140, y = 5000000),
  legend = leg.txt, lty = 1, merge = T, lwd = 2,
  col = c("purple", "green", "orange", "red"),
  bty = "n",
  y.intersp = 2
)


grid()
