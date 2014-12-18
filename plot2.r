url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
local_zip <- "local.zip"
code_file <- "Source_Classification_Code.rds"
summary_file <- "summarySCC_PM25.rds"
baltimore_fips = 24510

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

# We don't need the SCC data for this question.
#if (is.null(environment()$SCC)) {
#  SCC <- readRDS(code_file)
#}

library(reshape2)
filtered = NEI[NEI$fips == baltimore_fips,]
m <- melt(data=filtered,
          id.vars=c("year", "Pollutant", "fips", "SCC", "type"),
          value.vars=c("Emissions"))
y <- dcast(m, year + Pollutant ~ variable, sum)
png("plot2.png")
barplot(y$Emissions,
        names.arg=y$year,
        main="Baltimore City, MD PM2.5 Emissions Decreased 1999-2008",
        ylab="Total tons of PM2.5 Emissions",
        xlab="Year"
        )
dev.off()