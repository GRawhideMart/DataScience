if(!file.exists('./Data.zip') & !file.exists('./Source_Classification_Code.rds') & !file.exists('./summarySCC_PM25.rds')) {
    download.file('https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip', './Data.zip', method = 'curl')
    unzip('./Data.zip')
    file.remove('./Data.zip')
}
library(ggplot2)

points <- as_tibble(readRDS('./Source_Classification_Code.rds')) %>%
    select('SCC', 'EI.Sector') %>%
    inner_join(as_tibble(readRDS('./summarySCC_PM25.rds')), by='SCC') %>%
    filter((fips == '24510' | fips == '06037') & type == 'ON-ROAD') %>%
    mutate(fips = gsub('06037', 'Los Angeles County', fips)) %>%
    mutate(fips = gsub('24510', 'Baltimore City', fips)) %>%
    mutate(EI.Sector = gsub('Mobile - On-Road ', '', EI.Sector)) %>%
    mutate(EI.Sector = gsub('Vehicles', '', EI.Sector)) %>%
    mutate(EI.Sector = gsub('Heavy Duty', 'H-Duty', EI.Sector)) %>%
    mutate(EI.Sector = gsub('Light Duty', 'L-Duty', EI.Sector)) %>%
    mutate(EI.Sector = gsub('Diesel', 'Die', EI.Sector)) %>%
    mutate(EI.Sector = gsub('Gasoline', 'Gas', EI.Sector)) %>%
    group_by(fips, year, EI.Sector) %>%
    summarize(Emissions = sum(Emissions))

png('plot6.png', width = 1024,height = 768)
g <- ggplot(data=points, aes(x=year, y=Emissions, fill=EI.Sector))
print(g + facet_grid(.~fips) + geom_col(position = position_dodge(), width = 1) + ggtitle('Motor-Vehicle Emissions in Baltimore: 1999-2008') + xlab('Year') + ylab('PM2.5 Emissions[Tons]') + labs(fill='Vehicle EI Type') + theme_light(base_family = 'Cantarell'))
dev.off()