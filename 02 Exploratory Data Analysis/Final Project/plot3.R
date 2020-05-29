if(!file.exists('./Data.zip') & !file.exists('./Source_Classification_Code.rds') & !file.exists('./summarySCC_PM25.rds')) {
    download.file('https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip', './Data.zip', method = 'curl')
    unzip('./Data.zip')
    file.remove('./Data.zip')
}

library(ggplot2)

NEI <- readRDS('summarySCC_PM25.rds')
SCC <- readRDS('Source_Classification_Code.rds')

baltimore <- subset(NEI, fips == '24510')
points <- aggregate(Emissions ~ type + year, data = baltimore, sum)

png('plot3.png', width=400, height=400)
g <- ggplot(data=points, aes(x=year, y=Emissions, color=type))
print(g + geom_point() + geom_line() + ggtitle("Emission by Source Type in Baltimore: 1999-2008") + xlab("Year") + ylab("PM2.5 Emissions (Tons)"))
dev.off()