if(!file.exists('./Data.zip') & !file.exists('./Source_Classification_Code.rds') & !file.exists('./summarySCC_PM25.rds')) {
    download.file('https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip', './Data.zip', method = 'curl')
    unzip('./Data.zip')
    file.remove('./Data.zip')
}

NEI <- readRDS('summarySCC_PM25.rds')
SCC <- readRDS('Source_Classification_Code.rds')

points <- with(NEI, tapply(Emissions / 10^6, year, sum))

png('plot1.png', width = 400,height = 400)
plot(names(points),points,type='o',xlab = 'Years',ylab='PM2.5 Emissions [Tons*10^6]',pch=19)
dev.off()