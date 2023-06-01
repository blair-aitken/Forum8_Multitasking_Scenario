#===================================================================================================
#
# Project title: Validation of a Novel Driving Simulation Task: A Pilot Study
#
# Author(s): Mr Blair Aitken & Dr Tom Arkell
#
# Additional contributor(s): Dr Brook Shiferaw
#              
# License: This script is made available under the Creative Commons Attribution (CC BY) license. 
#          You are free to use, modify, and share this script as long as you provide attribution
#          to the original author(s).
#          
#          
# Terms of use: By using this script, you agree to cite the original source and provide attribution
#               to the author(s) in any publications or presentations that result from its use.
#               You are also free to modify and share the script, but any derivative works must also
#               be made available under the same license.
#               
# Disclaimer: This script is provided "as is" and the author(s) cannot be held liable for  
#             any errors or issues that arise from its use.
#
# Contact information: For questions or additional information about this script, 
#                      please contact baitken@swin.edu.au.
#
# Last updated on May 9, 2023
#
# More information: https://github.com/blairaitken/projectname

# Notes
#------
# 1. CSV files should be named using the following format:
#    "STUDYCODE_000_00_T0.csv"
#    where:
#    - "STUDYCODE" is the study identifier
#    - "000" is the participant number (e.g., 001, 002, 003, ...)
#    - "V0" is the visit number (e.g., V1, V2, V3, ...)
#    - "T0" is the drive number (e.g., T1, T2, T3, ...)
#
# 2. This script should be placed in the same folder as all CSV data files.
# 3. The script reads all .csv files in the folder and merges them based on common column headings.
#   
#===================================================================================================

#---------------
# 1. DATA IMPORT
#---------------

# Load required packages
#------------------------
library(data.table)
library(tidyverse)
  
# Get a list of .csv files in the folder
#----------------------------------------
drivefiles <- list.files(pattern = "*.csv")

# Initialize an empty data.table
#--------------------------------
driving_data <- data.table()

# Read and merge .csv files
#---------------------------
for (f in drivefiles) {
  ddt <- read_csv(f, col_names = T)
  ddt$file <- f
  driving_data <- rbind(driving_data, ddt, fill = T)
}

# Remove unnecessary variables
#------------------------------
rm(ddt, f, drivefiles)

# driving_data now contains the merged data from all .csv files in the data folder

#------------------------------------------------------------------
# 2. CLEAN & ORGANISE HIGHWAY DRIVING & DIVIDED ATTENTION TASK DATA
#------------------------------------------------------------------

# Extract id, visit, drive number & study code from file name
#------------------------------------------------------------
driving_data$id <- as.numeric(sub("^.*[a-zA-Z]+([0-9]{3}).*", "\\1", driving_data$file)) 
driving_data$visit <- as.factor(sub("^.*[a-zA-Z]+[0-9]{3}_V([0-9]+).*", "\\1", driving_data$file)) 
driving_data$drive_number <- as.factor(sub("^.*[a-zA-Z]+[0-9]{3}_V[0-9]+_T([0-9]+).*", "\\1", driving_data$file))

# Covert all headings to lower case
#----------------------------------
colnames(driving_data) <- tolower(colnames(driving_data))

# Create separate data sheet for headway analysis
#-----------------------------------------------
headway_data <- driving_data

# Remove non-user vehicles
#--------------------------
driving_data <- subset(driving_data, driving_data$type == "uv")

# Sort into kilometers
#---------------------
driving_data$distancealongroad <- as.integer(driving_data$distancealongroad/1)

# Remove unwanted data
#---------------------
# Remove empty cells in 'offsetfromlanecenter' and 'lanenumber' columns
driving_data <- driving_data %>%
  drop_na(offsetfromlanecenter, lanenumber)

# Remove empty cells and data while driver is indicating and outside of lane
driving_data <- driving_data %>%
  filter((lightstate == "BrakeLight" | lightstate == "" | is.na(lightstate)) &
           (lanenumber == 2))

# Convert offset from lane centre into cms
#-----------------------------------------
driving_data$offsetfromlanecenter2 <- driving_data$offsetfromlanecenter*100

# Convert negative 'offsetfromlanecenter' & steering values to positive values
#-----------------------------------------------------------------------------
driving_data$offsetfromlanecenter2 <- abs(driving_data$offsetfromlanecenter2)
driving_data$steering <- abs(driving_data$steering)

# Sort into task
#---------------
driving_data$task = 0

driving_data$task[driving_data$distancealongroad >= 4200 & driving_data$distancealongroad <= 13800 ] = "car_following"
driving_data$task[driving_data$distancealongroad >= 15500 & driving_data$distancealongroad <= 27500 ] = "highway_drive"
driving_data$task[driving_data$distancealongroad >= 28000 & driving_data$distancealongroad <= 40000 ] = "choiceRT"

# Remove data outside of tasks
#------------------------------
driving_data <- driving_data[!(driving_data$task == 0), ]

#------------------------------------------------------
# 3. CLEAN & ORGANISE HEADWAY DATA (CAR-FOLLOWING TASK)
# -----------------------------------------------------

# Sort into kilometers
#---------------------
headway_data$bin1 <- as.integer(headway_data$distancealongroad / 1)

# Sort into task
#---------------
headway_data$task <- 0
headway_data$task[headway_data$bin1 >= 3800 & headway_data$bin1 <= 14000] <- 1

# Remove data outside of tasks
#-----------------------------
headway_data <- subset(headway_data, headway_data$task == 1)

# Order rows by time
#-------------------
headway_data <- headway_data[order(id, visit, drive_number, time), ]

# Delete data when car is not following
#--------------------------------------
headway_data <- headway_data %>%
  filter(!(stringr::str_detect(headway_data$type, "uv") & stringr::str_detect(lead(headway_data$type), "uv"))) 

headway_data <- headway_data %>%
  filter(!(stringr::str_detect(headway_data$type, "fv") & stringr::str_detect(lead(headway_data$type), "fv")))

# Subtract user's distance along road from lead vehicle's distance along road
#----------------------------------------------------------------------------
headway_data$headway <- rep(headway_data$distancealongroad[seq(2, nrow(headway_data), by = 2)] - headway_data$distancealongroad[seq(1, nrow(headway_data), by = 2)], each = 2)

# Remove lead vehicle's data
#---------------------------
headway_data <- subset(headway_data, headway_data$type == "uv")

# Convert headway values to positive
#------------------------------------
headway_data$headway <- abs(headway_data$headway)

# Remove headway under 5 meters
#-------------------------------
headway_data <- subset(headway_data, headway_data$headway >= 5)

# Remove headway over 500
#------------------------
headway_data <- subset(headway_data, headway_data$headway <= 500)

# Create task column in head_data dataframe
#------------------------------------------
headway_data$task <- rep("car_following", nrow(headway_data))

#------------------
# 4. SUMMARISE DATA
# -----------------

# Summarise data 
#---------------
driving_data_summary = subset(driving_data) %>%
  group_by(id, visit, drive_number, task) %>%
  summarise(SDLP = sd(offsetfromlanecenter2), SDS = sd(speedinkmperhour), average_speed = mean(speedinkmperhour), steering_variability = sd(steering))

headway_data_summary = subset(headway_data) %>%
  group_by(id, visit, drive_number, task) %>%
  summarise(average_headway = mean(headway), SD_headway = sd(headway))

driving_data_summary <- left_join(driving_data_summary, headway_data_summary, by = c("id", "visit", "drive_number", "task"))

#---------------
# 4. EXPORT DATA
# --------------

# Write to CSV file
#------------------
write.csv(driving_data_sunmary,"driving_data_summary.csv", row.names = F)

write.csv(driving_data,"raw_driving_data.csv", row.names = F)

write.csv(headway_data,"raw_headway_data.csv", row.names = F)

# End of script
