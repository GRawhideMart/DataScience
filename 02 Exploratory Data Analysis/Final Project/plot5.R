if(!file.exists('./Data.zip') & !file.exists('./Source_Classification_Code.rds') & !file.exists('./summarySCC_PM25.rds')) {
    download.file('https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip', './Data.zip', method = 'curl')
    unzip('./Data.zip')
    file.remove('./Data.zip')
}
library(ggplot2)
NEI <- readRDS('summarySCC_PM25.rds')
SCC <- readRDS('Source_Classification_Code.rds')

#Extract gas related data from SCC
SCC2 <- subset(SCC, select = c(SCC, EI.Sector)) # columns to keep

#Find pollutants on road in Baltimore and merge the datasets
baltimoreOnRoad <- subset(NEI, fips == '24510' & type == 'ON-ROAD')
mrg <- merge(x=baltimoreOnRoad, y=SCC2, by='SCC')

points <- aggregate(Emissions ~ EI.Sector + year, data = mrg, sum)
points$EI.Sector <- gsub('Mobile - On-Road ', '', points$EI.Sector)
points$EI.Sector <- gsub('Heavy Duty', 'H-Duty', points$EI.Sector)
points$EI.Sector <- gsub('Light Duty', 'L-Duty', points$EI.Sector)
points$EI.Sector <- gsub('Diesel', 'Die', points$EI.Sector)
points$EI.Sector <- gsub('Gasoline', 'Gas', points$EI.Sector)

png('plot5.png', width = 500,height = 500)
g <- ggplot(data=points, aes(x=year, y=Emissions, color=EI.Sector))
print(g + geom_point() + geom_line() + ggtitle('Motor-Vehicle Emissions in Baltimore: 1999-2008') + xlab('Year') + ylab('PM2.5 Emissions[Tons]') + theme_minimal())
dev.off()