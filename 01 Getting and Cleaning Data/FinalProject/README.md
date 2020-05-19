Introduction
============

One of the most exciting areas in all of data science right now is
wearable computing - see for example this article . Companies like
Fitbit, Nike, and Jawbone Up are racing to develop the most advanced
algorithms to attract new users. The data linked to from the course
website represent data collected from the accelerometers from the
Samsung Galaxy S smartphone. A full description is available at the
[site](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)
where the data was obtained.

The script
==========

My *run\_analysis.R* script is supposed to:

1.  Merge the training and the test sets to create one data set.

2.  Extract only the measurements on the mean and standard deviation for
    each measurement.

3.  Use descriptive activity names to name the activities in the data
    set.

4.  Appropriately label the data set with descriptive variable names.

5.  From the data set in step 4, create a second, independent tidy data
    set with the average of each variable for each activity and each
    subject.

To achieve so, first of all it checks if the dataset already exists in
the current directory; if not, it downloads it from the link, unzips it
and saves the download data (*for integrity purposes*, not required, but
it’s just my own practice to do it).

After this preliminary operation, the code starts executing. For this
assignment I chose to put to use my knowledge of the dplyr package,
hence each dataset has been read **as a tibble**.

After reading the activities labels and the various features, and after
renaming the wanted features in a more suitable way, my code starts
importing (as a tibble) the train and test datasets. This is achieved
by:

-   **Importing the sensor data**, using the wanted features as column
    and the data as rows

-   Creating a new column for the **subjects**

-   Creating a new column for the **activities**, which has to be
    converted to *factor* in order to label them correctly (from the
    activities file)

-   Binding the columns together (with *cbind()*) and converting them
    into a tibble.

Following this, I formed a complete dataset by binding the rows of both
the datasets resulting from the previous step. At this point, I factored
the Activities column to be assigned a label instead of the
corresponding number.

For the final part of the assignment, I used *dplyr* functions
*group\_by* (to group by subject and activity) and *summarise\_all* to
group together the means of the various entries.

The script is here for the download and the testing.
