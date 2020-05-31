if(!file.exists('./Data.zip') & !file.exists('./Source_Classification_Code.rds') & !file.exists('./summarySCC_PM25.rds')) {
    download.file('https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip', './Data.zip', method = 'curl')
    unzip('./Data.zip')
    file.remove('./Data.zip')
}
library(dplyr)
library(ggplot2)

points <- as_tibble(readRDS('./Source_Classification_Code.rds')) %>%
    select('SCC', 'EI.Sector') %>%
    inner_join(as_tibble(readRDS('./summarySCC_PM25.rds')), by='SCC') %>%
    filter(fips == '24510' & type == 'ON-ROAD') %>%
    mutate(EI.Sector = gsub('Mobile - On-Road ', '', EI.Sector)) %>%
    mutate(EI.Sector = gsub('Vehicles', '', EI.Sector)) %>%
    mutate(EI.Sector = gsub('Heavy Duty', 'H-Duty', EI.Sector)) %>%
    mutate(EI.Sector = gsub('Light Duty', 'L-Duty', EI.Sector)) %>%
    mutate(EI.Sector = gsub('Diesel', 'Die', EI.Sector)) %>%
    mutate(EI.Sector = gsub('Gasoline', 'Gas', EI.Sector)) %>%
    group_by(year, EI.Sector) %>%
    summarize(totalEmissions = sum(Emissions))

png('plot5.png', width = 800,height = 600)
g <- ggplot(data=points, aes(x=year, y=totalEmissions, fill=EI.Sector))
print(g + geom_col(position = position_dodge(), width = 1) + ggtitle('Motor-Vehicle Emissions in Baltimore: 1999-2008') + xlab('Year') + ylab('PM2.5 Emissions[Tons]') + labs(fill='Vehicle EI Type') + theme_light(base_family = 'Cantarell'))
dev.off()