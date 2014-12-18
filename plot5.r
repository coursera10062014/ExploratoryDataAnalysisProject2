url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
local_zip <- "local.zip"
code_file <- "Source_Classification_Code.rds"
summary_file <- "summarySCC_PM25.rds"
baltimore_fips = 24510
losangeles_fips = "06037"  # must be string form due to leading zero.

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

# We have to decide what "motor vehicle sources" are here.
# Does that include trains?  Airplanes?  Snowmobiles?
# I decided the best filter here was all mobile sources.
rows <- grep("^Mobile.*$", merged$EI.Sector)

mobile <- merged[rows,]
baltimore = mobile$fips == baltimore_fips
la = mobile$fips == losangeles_fips
either = baltimore | la
filteredMobile = mobile[either,]
filteredMobile$city = as.factor(
  sapply(filteredMobile$fips, function(fips) {
    if (fips == baltimore_fips) {
      "Baltimore, MD"
    } else if (fips == losangeles_fips) {
      "Los Angeles County, CA"
    } else {
      "Susan"
    }
  }))

colSol = filteredMobile[,c(4,6, 21)]
library(reshape2)
m <- melt(data=colSol,
          id.vars=c("year", "city"),
          value.vars=c("Emissions"))
y <- dcast(m, year + city ~ variable, sum)
           
png("plot5.png")
library(ggplot2)
g <- ggplot(y, aes(x=year, y=Emissions, fill=city)) +
  geom_bar(stat="identity") +
  facet_grid(. ~ city) +
  theme(axis.text.x = element_text(angle=90, hjust=1)) +
  ggtitle("Emissions over time in Baltimore and LA")
print(g)
dev.off()