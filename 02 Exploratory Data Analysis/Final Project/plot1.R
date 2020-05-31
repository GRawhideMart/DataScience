if(!file.exists('./Data.zip') & !file.exists('./Source_Classification_Code.rds') & !file.exists('./summarySCC_PM25.rds')) {
    download.file('https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip', './Data.zip', method = 'curl')
    unzip('./Data.zip')
    file.remove('./Data.zip')
}

require(dplyr)
NEI <- as_tibble(readRDS('summarySCC_PM25.rds'))
points <- NEI %>%
    group_by(year) %>%
    summarize(totalEmissions = sum(Emissions / 10^6))

png('plot1.png', width = 400,height = 400)
barplot(points$totalEmissions, names.arg = points$year, xlab = 'Years', ylab = 'PM2.5 Emissions [MTons]', col = 'cyan')
dev.off()