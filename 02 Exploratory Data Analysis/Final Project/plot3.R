if(!file.exists('./Data.zip') & !file.exists('./Source_Classification_Code.rds') & !file.exists('./summarySCC_PM25.rds')) {
    download.file('https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip', './Data.zip', method = 'curl')
    unzip('./Data.zip')
    file.remove('./Data.zip')
}

require(dplyr)
require(ggplot2)

baltimore <- as_tibble(readRDS('./summarySCC_PM25.rds')) %>%
         filter(fips == '24510') %>%
         group_by(year,type) %>%
         summarise(totalEmissions = sum(Emissions))

png('plot3.png', width=400, height=400)
g <- ggplot(data=baltimore, aes(x=year, y=totalEmissions, fill=type))
print(g + geom_col(position = position_dodge(), width = 1) + ggtitle('Emission by Source Type in Baltimore: 1999-2008') + xlab('Year') + ylab('PM2.5 Emissions [Tons]') + theme_light(base_family = 'Cantarell'))
dev.off()