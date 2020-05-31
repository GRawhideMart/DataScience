if(!file.exists('./Data.zip') & !file.exists('./Source_Classification_Code.rds') & !file.exists('./summarySCC_PM25.rds')) {
    download.file('https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip', './Data.zip', method = 'curl')
    unzip('./Data.zip')
    file.remove('./Data.zip')
}

baltimore <- as_tibble(readRDS('./summarySCC_PM25.rds')) %>% # Read the dataset
    filter(fips == '24510') %>% # Filter out the rows not needed
    group_by(year) %>% # Self-explaining
    summarize(sum(Emissions)) # Sum of total emissions by year in baltimore

names(baltimore) <- c('year','totalEmissions')

png('plot2.png', width = 400,height = 400)
barplot(baltimore$totalEmissions, names.arg = baltimore$year, xlab = 'Years', ylab = 'PM2.5 Emissions in Baltimore [MTons]', col = 'brown')
dev.off()