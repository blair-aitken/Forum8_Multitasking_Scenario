#===================================================================================================
#
# Project title: Forum8 Multitasking Scenario
#
# Author(s): Dr Blair Aitken
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
# Last updated on September 25, 2024
#
# More information: https://github.com/blairaitken/forum8_multitasking_scenario

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

# Load required packages
library(data.table)
library(tidyverse)

# Set the working directory and list .csv files including subfolders
setwd("../Data")
drivefiles <- list.files(pattern = "*.csv", recursive = TRUE)

# Initialize an empty data table and read & merge .csv files
driving_data <- data.table()
for (f in drivefiles) {
  ddt <- read_csv(f, col_names = TRUE) %>%
    mutate(file = f)
  driving_data <- rbind(driving_data, ddt, fill = TRUE)
}
rm(ddt, f)  # Clean up intermediate variables

#-------------------------------
# Data Cleaning and Organization
#-------------------------------

driving_data <- driving_data %>%
  mutate(id = as.factor(sub("^.*MEDICO([0-9]{3}).*", "\\1", file)),
         visit = as.factor(sub("^.*V([0-9]+).*", "\\1", file)),
       # drive = as.factor(sub("^.*T([0-9]+).*", "\\1", file))) %>% # Uncomment line to include multiple drives
  rename_with(tolower, everything()) %>%
  select(id, visit, time, steering, type, speedinkmperhour, distancealongroad,
         distancetofrontvehicle, offsetfromlanecenter, lanenumber, lightstate,
         standarddeviationfromlanecenter, file) # Add "drive" column for multiple drives

# Data filtering and unit conversions
driving_data <- driving_data %>%
  filter(lanenumber == 2 & # Remove data from lanes 1 (left-shoulder), 3 (right driving lane) & 4 (right-shoulder)
         type == "uv" & # Remove data from other vehicles in simulation
         (lightstate == "BrakeLight" | lightstate == "" | is.na(lightstate)) & # Remove data when driver is indicating
         !(between(distancealongroad, 19500, 19850)) & # Over-taking event 1
         !(between(distancealongroad, 21750, 22150)) & # Over-taking event 2
         !(between(distancealongroad, 24000, 24250)) & # Over-taking event 3
         !(between(distancealongroad, 26250, 26500))) # Over-taking event 4

# Sort into task
driving_data$task = 0

driving_data$task[driving_data$distancealongroad >= 3800 & driving_data$distancealongroad <= 13800 ] = "car_following" 
driving_data$task[driving_data$distancealongroad >= 15500 & driving_data$distancealongroad <= 27500 ] = "highway_drive"
driving_data$task[driving_data$distancealongroad >= 28000 & driving_data$distancealongroad <= 40000 ] = "dual_task"

driving_data <- driving_data %>%
  filter(task != 0) # Remove data outside of tasks

# Add treatment schedule from randomisation
treatment_randomisation <- list(
  # Example treatment schedule
  "001" = c("A", "E", "C", "D", "B"),
  "002" = c("C", "D", "A", "B", "E"),
  "003" = c("A", "C", "E", "B", "D"),
  "004" = c("D", "C", "B", "E", "A"),
  "005" = c("B", "E", "D", "C", "A"),
  "006" = c("A", "E", "B", "C", "D"),
  "007" = c("A", "D", "E", "B", "C"),
  "008" = c("D", "A", "B", "E", "C"),
  "010" = c("A", "B", "E", "D", "C"),
  "011" = c("E", "A", "D", "C", "B"),
  "012" = c("E", "D", "A", "B", "C"),
  "013" = c("B", "D", "A", "C", "E")
)

# Convert 'id' and 'visit' to factor before assignment to ensure indexing works
driving_data[, `:=`(id = as.factor(id), visit = as.factor(visit))]

# Assign treatments to the driving_data based on id and visit
driving_data[, treatment := sapply(seq_len(.N), function(i) {
  # Check if the id exists in the list and if the visit number is within the range
  if (id[i] %in% names(treatment_randomisation) && as.integer(visit[i]) <= length(treatment_randomisation[[id[i]]])) {
    return(treatment_randomisation[[id[i]]][as.integer(visit[i])])
  } else {
    return(NA)  # Return NA if the id or visit number is out of range
  }
})]

#---------------
# Summarise Data
#---------------

driving_data_summary <- driving_data %>%
  group_by(id, treatment, task) %>% # Add "drive" variable for multiple drives
  summarise(
            SDLP = sd(offsetfromlanecenter, na.rm = TRUE), # Standard deviation of lateral position
            SDS = sd(speedinkmperhour, na.rm = TRUE), # Standard deviation of speed
            average_speed = mean(speedinkmperhour, na.rm = TRUE), # Average speed
            steering_variability = sd(steering, na.rm = TRUE), # Steering variability
            average_headway = mean(distancetofrontvehicle, na.rm = TRUE), # Average headway
            headway_variability = sd(distancetofrontvehicle, na.rm = TRUE)) # Headway variability

#----------------------
# Export Processed Data
#----------------------

write.csv(driving_data_summary, "driving_data_summary.csv", row.names = FALSE) # Exports cleaned data to csv file

#--------------
# End of script
#--------------
