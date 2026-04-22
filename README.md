# Table of Contents
1. [General Info](#general-info)
2. [Instructions](#instructions)
3. [Data Tabs](#data-tabs)
4. [FAQs](#faqs)

## General Info
- This is an R Shiny App that allows you to tidy PAMS VOCs data from ChemStation PAMS Reporter program (.csv) into a tidied .csv file that can be downloaded so the data is ready for 2nd level review.
- The app does the following:
  1. Adds missing column names (PAMSHC, TNMOC, Total Unknown, Date, Time, etc.)
  2. Optional - adjust the datetime stamps in case there was a time drift in the GC.
  3. Creates an accurate date-time column for which hour the data represents.
  4. Arranges dataframe in the correct order (VOCs need to be in correct order to submit to AQS).
  5. Fills in hours of missing data (due to power outage, calibration, instrument repair, etc.) with "NA"
  6. Includes all VOC AQS codes and a column for any null/qualifying codes.
- This code will only work with .csv files.
- The tidied file is a downloadable .csv file.


## Instructions
**Please Note:** App will not work correctly in R studio's native web launcher please change settings in Run App -> set to run External or select open in Browser when running it in R studio. 
1. Download the Repository and Make sure R, R studio, and all packages are installed in order for the App to properly function
2. Run the App in your normal web browser and browse your computer for the Raw data file (only select 1 at a time).
3. Check off the optional "Apply Timestamp Drift Correction" box if timestamps drifted past the hour (usually indicated in 1st level review notes).
4. Click "Download Completed CSV" and file will be named according to the original raw data file name.

## Data Tabs
This is information on is shown in each of the Display Tabs. 
- Raw Data Preview: preview of Raw Data that was originally uploaded.
- Tidied Data Preview: preview of Tidied VOC data that can be downloaded.
- Summary: shows total rows, columns, date range, if there were missing hours filled with "NA", and if the timestamp drift correction was applied.

## FAQs
1. Why does my data produces an error when reading in my raw data files?
A: There are many sources of error for this problem including: Data not in right file format (ie. not .csv), Contains corruption in the data file, or browser incompability (make sure you are using a web Browser!). If errors mentions a specific file you can look in the File Names tab to identify what file is giving you the error and attempt to correct it.
2. What data format does the App support?
A: Input data must be in .csv format and download data will be .csv as well
3. What is the file limit/size for uploading data?
A: The file limit size is based on your memory limit of your device. 
4. When would you recommend using the Timestamp Drift option?
A: I recommend reviewing the 1st level review notes for any inidcation that the timestamp drifted. Also double check the file names of the original raw data files. The file names include the exact timestamp which is typically looks like 15:57:48 meaning that the data represents 15:00. However, the timestamp sometimes drifts into the next hour due to GC issues, looking like this 16:03:57, but the data is actually still representative of the previous hour 15:00. Checking this box applies a condition where, if the minutes in the timestamp are less than 20, change the hour in the timestamp to the previous hour. In general, this helps correct that time drift. Be sure to double check with 1st level review and raw data file names to ensure that the timestamp in the completed datafile reflects what actually occurred.
5. I have and issue/request/question about the app, how can I contact you?
A: Please contact me through Github by creating a new issue and labeling it appropriately and I will try to get back to you ASAP.
