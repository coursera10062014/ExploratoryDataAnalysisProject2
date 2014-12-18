url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
local_zip <- "local.zip"
code_file <- "Source_Classification_Code.rds"
summary_file <- "summarySCC_PM25.rds"

if (!file.exists(local_zip)) {
  download.file(url, destfile = local_zip, mode = "wb")
}

if (!file.exists(code_file) || !file.exists(summary_file)) {
  unzip(local_zip)
}

if (is.null(environment()$NEI)) {
  NEI <- readRDS(summary_file)
  NEI$Pollutant = as.factor(NEI$Pollutant)
  NEI$type = as.factor(NEI$type)
  NEI$year = as.factor(NEI$year)
  NEI$SCC = as.factor(NEI$SCC)
  NEI$fips = as.factor(NEI$fips)
}

if (is.null(environment()$SCC)) {
  SCC <- readRDS(code_file)
}

if (is.null(environment()$merged)) {
  merged <- merge(NEI, SCC, by="SCC")
}
rows <- grep("^Fuel Comb - .*Coal", merged$EI.Sector)
coal <- merged[rows,]
colSol = coal[,c(4,6)]
library(reshape2)
m <- melt(data=colSol,
          id.vars=c("year"),
          value.vars=c("Emissions"))
y <- dcast(m, year ~ variable, sum)
           
png("plot4.png")
#windows()
library(ggplot2)
g <- ggplot(y, aes(x=year, y=Emissions)) +
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle=90, hjust=1)) +
  ggtitle("National Coal Combustion-Related Sources")
print(g)
dev.off()