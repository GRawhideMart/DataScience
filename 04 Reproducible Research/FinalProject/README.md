Synopsis
--------

Storms and other severe weather events can cause both public health and
economic problems for communities and municipalities. Many severe events
can result in fatalities, injuries, and property damage, and preventing
such outcomes to the extent possible is a key concern. This analysis’
goal is to highlight the most common accidents, both from a human life’s
perspective and from an economic one.

-   *Remark: the events in the database start in the year 1950 and end
    in November 2011. In the earlier years of the database there are
    generally fewer events recorded, most likely due to a lack of good
    records. More recent years should be considered more complete.*

Data Processing
---------------

The analysis starts by getting the data; this comes in the form of a
comma-separated-value file compressed via the bzip2 algorithm to reduce
its size.

    url <- 'https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2'
    if(!file.exists('StormData.csv.bz2')){download.file(url, './StormData.csv.bz2', method = 'curl')}
    downloaded_at <- Sys.time() # This variable will be sort of a metadata containing the time of downloading.

*Download data: 2020-06-02 15:45:32*

This database tracks characteristics of major storms and weather events
in the United States, including when and where they occur, as well as
estimates of any fatalities, injuries, and property damage. Additional
[documentation](https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2Fpd01016005curr.pdf)
and a
[FAQ](https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2FNCDC%20Storm%20Events-FAQ%20Page.pdf)
are available.  
In order to have a more convenient way to process data, I use the
*dplyr* and *ggplot2* libraries.

    require(dplyr)

First and foremost, the data must be read. As I mentioned, the general
line will be treating it as a tibble, special object provided by
*dplyr*.

    storm <- as_tibble(read.csv('StormData.csv.bz2'))

The dataset contains **902297 observations** of **37 variables**.

I want to check out how many measurements were taken per year. In order
to do that, I’ll chain some functions.

    # Declare a new variable from storm
    eventsPerYear <- storm %>%
        # Add a column by formatting the date and leaving only the year
        mutate(YEAR = format(as.Date.character(BGN_DATE, '%m/%d/%Y'), '%Y')) %>%
        # Group the result by year
        group_by(YEAR) %>%
        #Count the events per year
        summarize(Events = n())

    pal <- colorRampPalette(c('red','yellow','green','blue')) # A palette to show barplot
    barplot(eventsPerYear$Events, names.arg = eventsPerYear$YEAR, xlab = 'Year', ylab = 'No. of Events', main = 'Events per Year', col=pal(62), width = 720)

![](Analysis_files/figure-markdown_strict/Measurements%20per%20year-1.png)

From the barplot above, it’s clear that data before **1995** is much
more meaningful; which is why that subset is what I will base my
analysis on; furthermore, out of the 37 columns of the original dataset
I’m only interested in:

-   **EVTYPE** which contains the event type;
-   **FATALITIES**
-   **INJURIES**
-   **PROPDMG** which contains the damage to properties;
-   **PROPDMGEXP** which contains the order of magnitude of the damage
    to properties;
-   **CROPDMG** which contains the damage to crops;
-   **CROPDMGEXP** which contains the order of magnitude of the damage
    to crops;

<!-- -->

    # Declare a new table from the original one
    events <- storm %>%
        # Add year column
        mutate(YEAR = format(as.Date.character(BGN_DATE, '%m/%d/%Y'), '%Y')) %>%
        # Select the columns of interest
        select('YEAR','EVTYPE','FATALITIES','INJURIES','PROPDMG','PROPDMGEXP','CROPDMG','CROPDMGEXP') %>%
        # Filter out events before 1995
        filter(YEAR >= 1995)

The new subset contains the **75.53%** of the original data, which
justifies the neglecting.  
At this point, I will create two distinct datasets for the aspects
regarding **life** and another for the aspects regarding **economy**.

    life <- events %>%
        select('EVTYPE','FATALITIES','INJURIES')

    economy <- events %>%
        select('EVTYPE','PROPDMG','PROPDMGEXP','CROPDMG','CROPDMGEXP')

A final processing adjustment has to be made about the economy part.
Since the order of magnitude is put in a separate column with respect to
the significant value, this comes as a factor. Let’s convert each level
to the multiplying factor it represents.  
*Remark: special characters which are not numbers are data without clear
meaning, so they must be removed.*

    levels(economy$PROPDMGEXP)

    ##  [1] ""  "-" "?" "+" "0" "1" "2" "3" "4" "5" "6" "7" "8" "B" "h" "H" "K" "m" "M"

    levels(economy$CROPDMGEXP)

    ## [1] ""  "?" "0" "2" "B" "k" "K" "m" "M"

    #The different levels show ununiformity of the ways to indicate orders of magnitude. This has to be addressed.
    levels(economy$CROPDMGEXP) <- c(0,0,1,100,10^9,10^3,10^3,10^6,10^6)
    levels(economy$PROPDMGEXP) <- c(0,0,0,0,1,10,100,10^3,10^4,10^5,10^6,10^7,10^8,10^9,10^2,10^2,10^3,10^6,10^6)

    # Having mapped all the values, I'll now reassign the columns
    economy <- economy %>%
        mutate(CROPDMGEXP = as.numeric(levels(CROPDMGEXP))[economy$CROPDMGEXP]) %>%
        mutate(PROPDMGEXP = as.numeric(levels(PROPDMGEXP))[economy$PROPDMGEXP]) %>%
        mutate(Property_Damage = PROPDMG * PROPDMGEXP) %>%
        mutate(Crop_Damage = CROPDMG * CROPDMGEXP) %>%
        select('EVTYPE', 'Property_Damage', 'Crop_Damage')

Analysis
--------

Being the data processed, I’ll now proceed with the analysis in order to
address the questions.

### Life

-   **Which types of events are most harmful to population health?**

I’ll treat separately the data coming from `fatalities` and from
`injuries`.

#### Fatalities

    fatalities <- life %>%
        group_by(EVTYPE) %>%
        summarize(Fatalities = sum(FATALITIES))

    topFatalities <- fatalities %>%
        arrange(desc(Fatalities)) %>%
        top_n(15)

    head(topFatalities)

    ## # A tibble: 6 x 2
    ##   EVTYPE         Fatalities
    ##   <fct>               <dbl>
    ## 1 EXCESSIVE HEAT       1903
    ## 2 TORNADO              1545
    ## 3 FLASH FLOOD           934
    ## 4 HEAT                  924
    ## 5 LIGHTNING             729
    ## 6 FLOOD                 423

Since `fatalities` contains a lot of 0s (i.e. non-fatal events), I
selected only the first 15 rows.

-   The top 15 rows in this case contain **81.58%** of all the events,
    so this is valid.

#### Injuries

    injuries <- life %>%
        group_by(EVTYPE) %>%
        summarize(Injuries = sum(INJURIES))

    topInjuries <- injuries %>%
        arrange(desc(Injuries)) %>%
        top_n(15)

    head(topInjuries)

    ## # A tibble: 6 x 2
    ##   EVTYPE         Injuries
    ##   <fct>             <dbl>
    ## 1 TORNADO           21765
    ## 2 FLOOD              6769
    ## 3 EXCESSIVE HEAT     6525
    ## 4 LIGHTNING          4631
    ## 5 TSTM WIND          3630
    ## 6 HEAT               2030

Again `injuries` contains a lot of 0s (i.e. non-fatal events), I
selected only the first 15 rows.

-   The top 15 rows in this case contain **88.82%** of all the events,
    so this is valid.

Let’s plot the injuries and fatalities by event type.

-   Since I’m only interested in fractions of the total, I will use *pie
    charts*.

<!-- -->

    require(ggplot2)
    require(gridExtra)

    gf <- ggplot(topFatalities, aes(x='', y=Fatalities, fill=EVTYPE))
    gi <- ggplot(topInjuries, aes(x='', y=Injuries, fill=EVTYPE))

    fatalitiesPlot <- gf + geom_bar(stat = 'identity', width = 1) + coord_polar('y',start = 0) + labs(fill='Event') + ggtitle('Fatalities') + theme_void(base_family = 'Cantarell')

    injuriesPlot <- gi + geom_bar(stat = 'identity', width = 1) + coord_polar('y',start = 0) + labs(fill='Event') + ggtitle('Injuries') + theme_void(base_family = 'Cantarell')

    gridExtra::grid.arrange(fatalitiesPlot, injuriesPlot, ncol=2)

![](Analysis_files/figure-markdown_strict/Life%20plots-1.png)

From the charts, it appears that **most deaths happened from excessive
heat and tornados**.

-   Is it true, overall? Let’s the fractions.

<!-- -->

    fatalities_excessive_heat <- fatalities %>%
        filter(EVTYPE == 'EXCESSIVE HEAT') %>%
        select('Fatalities') %>%
        summarize(FatalitiesEH = Fatalities, TotalFatalities = sum(fatalities$Fatalities), ratio = FatalitiesEH / TotalFatalities)

    fatalities_excessive_heat$ratio

    ## [1] 0.1861489

    fatalities_tornado <- fatalities %>%
        filter(EVTYPE == 'TORNADO') %>%
        select('Fatalities') %>%
        summarize(FatalitiesTORN = Fatalities, TotalFatalities = sum(fatalities$Fatalities), ratio = FatalitiesTORN / TotalFatalities)

    fatalities_tornado$ratio

    ## [1] 0.1511298

So **excessive heat** and **tornados** take, respectively **18.61%** and
**15.11%** of the total amount of fatalities in the timespan
1995-2011.  
About injuries, the biggest part of them happened due to tornados.

-   To confirm this, I’ll look at the impact of tornados over all the
    injuries.

<!-- -->

    injuries_tornado <- injuries %>%
        filter(EVTYPE == 'TORNADO') %>%
        select('Injuries') %>%
        summarize(InjuriesTORN = Injuries, TotalInjuries = sum(injuries$Injuries), ratio = InjuriesTORN / TotalInjuries)

    injuries_tornado$ratio

    ## [1] 0.3484909

Tornados take **34.85%** of the total injuries.

### Economy

-   **Which types of events have the greatest economic consequences?**

Let’s generate a separate analysis for `property damage` and
`crop damage`.

-   *Remark: due to the big amount of the data, it makes sense to
    consider **billions** of dollars, instead of dollars.*

#### Property Damage

    prop <- economy %>%
        group_by(EVTYPE) %>%
        summarize(Property_Damage = sum(Property_Damage/1e+09))

    top_prop <- prop %>%
        arrange(desc(Property_Damage)) %>%
        top_n(10)

    head(top_prop)

    ## # A tibble: 6 x 2
    ##   EVTYPE            Property_Damage
    ##   <fct>                       <dbl>
    ## 1 FLOOD                       144. 
    ## 2 HURRICANE/TYPHOON            69.3
    ## 3 STORM SURGE                  43.2
    ## 4 TORNADO                      24.9
    ## 5 FLASH FLOOD                  16.0
    ## 6 HAIL                         15.0

Considering just the top 10 results is acceptable, since they contain
**90.61%** of the total amount of property damage from 1995 to 2011.

#### Crop Damage

    crop <- economy %>%
        group_by(EVTYPE) %>%
        summarize(Crop_Damage = sum(Crop_Damage/1e+09))

    top_crop <- crop %>%
        arrange(desc(Crop_Damage)) %>%
        top_n(10)

    head(top_crop)

    ## # A tibble: 6 x 2
    ##   EVTYPE            Crop_Damage
    ##   <fct>                   <dbl>
    ## 1 DROUGHT                 13.9 
    ## 2 FLOOD                    5.42
    ## 3 HURRICANE                2.74
    ## 4 HAIL                     2.61
    ## 5 HURRICANE/TYPHOON        2.61
    ## 6 FLASH FLOOD              1.34

The first 10 results contain **86.08%** of the total amount of crop
damage from 1995 to 2011; therefore, it’s acceptable to make this
approximation.

Again, I will plot together the results in *pie charts*.

    gp <- ggplot(top_prop, aes(x='', y=Property_Damage, fill=EVTYPE))
    gc <- ggplot(top_crop, aes(x='', y=Crop_Damage, fill=EVTYPE))

    propPlot <- gp + geom_bar(stat = 'identity', width = 1) + coord_polar('y',start = 0) + labs(fill='Event') + ggtitle('Property Damage') + theme_void(base_family = 'Cantarell')

    cropPlot <- gc + geom_bar(stat = 'identity', width = 1) + coord_polar('y',start = 0) + labs(fill='Event') + ggtitle('Crop Damage') + theme_void(base_family = 'Cantarell')

    gridExtra::grid.arrange(propPlot, cropPlot, ncol=2)

![](Analysis_files/figure-markdown_strict/Economy%20Plots-1.png)

It appears from the charts that the big part of property damage is done
by **floods**, followed by **hurricanes** and **typhoons**; the floods
also appear meaningful in crop damages, where the big part of it all is
due to **drought**.

-   Let’s check it out.

<!-- -->

    prop_flood <- prop %>%
        filter(EVTYPE == 'FLOOD') %>%
        select('Property_Damage') %>%
        summarize(Flood_Damage = Property_Damage, Total_Damage = sum(prop$Property_Damage), ratio = Flood_Damage / Total_Damage)

    prop_flood$ratio

    ## [1] 0.3815502

    prop_ht <- prop %>%
        filter(EVTYPE == 'HURRICANE/TYPHOON') %>%
        select('Property_Damage') %>%
        summarize(HT_Damage = Property_Damage, Total_Damage = sum(prop$Property_Damage), ratio = HT_Damage / Total_Damage)

    prop_ht$ratio

    ## [1] 0.1836084

Floods are responsible for **38.16%** of the damage, while hurricanes
and typhoons are accountable for **18.36%**; cumulatively, they are
responsible for **56.52%** of the total property damages in the years
1995-2011, which is more than half.

    crop_flood <- crop %>%
        filter(EVTYPE == 'FLOOD') %>%
        select('Crop_Damage') %>%
        summarize(Flood_Damage = Crop_Damage, Total_Damage = sum(crop$Crop_Damage), ratio = Flood_Damage / Total_Damage)

    crop_flood$ratio

    ## [1] 0.1438646

    crop_drought <- crop %>%
        filter(EVTYPE == 'DROUGHT') %>%
        select('Crop_Damage') %>%
        summarize(Drought_Damage = Crop_Damage, Total_Damage = sum(crop$Crop_Damage), ratio = Drought_Damage / Total_Damage)

    crop_drought$ratio

    ## [1] 0.3693458

Floods have a small hand in crop damages too (about **14.39%** of the
total); the most significant hand in crop damages is (as previously
observed) due to **drought**, which is responsible for **36.93%** of the
amount.

Results
-------

When it comes to human life:

-   Americans should pay particular attention to **tornados**, since
    they have been responsible for **34.85%** of the injuries and
    **15.11%** of the deaths in America due to storm events;
-   The other evident danger is **excessive heat**; it’s accountable for
    **18.61%** of fatalities, so families should invest in solutions in
    that sense.

About the economic impact of natural disasters:

-   **Floods** are responsible for both great economic losses both to
    properties and to crops (**38.16%** and **14.39%** respectively);
-   The biggest problem for crops turned out (more or less obviously) to
    be **drought**. A good **36.93%** of crop losses is due to drought,
    which is something to be addressed;
-   Another small percentage of property damages is due to
    **hurricanes** and **typhoons**. Protection against these can
    prevent up to **56.52%** of property damages.
