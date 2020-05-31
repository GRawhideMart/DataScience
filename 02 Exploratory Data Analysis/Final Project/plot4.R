if(!file.exists('./Data.zip') & !file.exists('./Source_Classification_Code.rds') & !file.exists('./summarySCC_PM25.rds')) {
    download.file('https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip', './Data.zip', method = 'curl')
    unzip('./Data.zip')
    file.remove('./Data.zip')
}
library(ggplot2)

points <- as_tibble(readRDS('./Source_Classification_Code.rds')) %>% #Read the SCC table
    select('SCC', 'Short.Name') %>% # Select the columns about name and the foreign key
    filter(grepl('[Cc]oal',Short.Name)) %>% # Filter the rows containing coal
    inner_join(as_tibble(readRDS('./summarySCC_PM25.rds')), by='SCC') %>% # Join table by SCC
    group_by(year, type) %>% # Group by year and type
    summarize(totalEmissions = sum(Emissions / 10^6)) # Find total emissions by year and type

png('plot4.png', width = 640,height = 480)
g <- ggplot(data=points, aes(x=year, y=totalEmissions, fill=type))
print(g + geom_col(position = position_dodge(), width = 1) + ggtitle('Coal Combustion Emissions in U.S.: 1999-2008') + xlab('Year') + ylab('PM2.5 Emissions[MTons]') + labs(fill='Type') + theme_light(base_family = 'Cantarell'))
dev.off()