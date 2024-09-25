![image](https://github.com/user-attachments/assets/a3011ec8-1eb4-4081-b43a-e18cc2ee837e)# Forum8 Multitasking Scenario

## Table of Contents

- [Overview](#overview)
- [Dependencies](#dependencies)
- [Driving simulations](#driving-simulations)
  - [Highway driving task](#highway-driving-task)
  - [Car-following task](#car-following-task)
  - [Dual task](dual-task)
  - [Outcomes](#outcomes)
- [Setup](#setup)
- [How to run data analysis](#how-to-run-data-analysis)
- [Modifying the data analysis script](#modifying-the-data-analysis-script)
- [Contact information](#contact-information)

## Dependencies 
* R (https://cran.r-project.org)
  * data.table (https://github.com/Rdatatable/data.table)
  * tidyverse (https://www.tidyverse.org) 
* UC-win/Road Ver. 14 by Forum8 (https://www.forum8.co.jp)

## Driving simulations
The UC-win/Road `forum8_impaired_driving_scenarios.rd` file contains three 8-minute driving tasks conducted on a bidirectional, four-lane highway with a lane width of 3.4 meters. The tasks are as follows:

### Highway driving task
Participants maintain a constant speed of 100 km/h in the left lane and performed four overtaking manoeuvres during a 12 km drive. 

<br><img width="2880" alt="Highway_Driving_Screenshot" src="https://github.com/blair-aitken/Forum8_Impaired_Driving/assets/131508862/ab17f415-d2ab-49b0-8b2e-44ab97e980ec"><br>

### Car-following task
The task begins with a vehicle materialising 50 meters ahead of the participant's vehicle. Participants are instructed to follow this vehicle, maintaining a safe and consistent distance (headway) from it.

<br><img width="2880" alt="Car_Following_Screenshot" src="https://github.com/blair-aitken/Forum8_Impaired_Driving/assets/131508862/2097b757-2110-4585-a6ce-ba23ecef0179"><br>

The lead vehicle varied its speed in a sinusoidal pattern every 400 meters, fluctuating between 60 and 90 km/h, with single speed changes no greater than ± 10 km/h. Consequently, participants are required to adjust their speed by decelerating to avoid collisions and accelerating to keep up with the lead vehicle. 

### Dual task
In this task, participants are presented with letters from A to F enclosed within a green hexagon on screens positioned at the left and right of their peripheral vision.

<br><img width="2880" alt="Dual_Task_Screenshot" src="https://github.com/blair-aitken/Forum8_Impaired_Driving/assets/131508862/6ad8de32-d64f-47a2-9284-e5ff6533c9bf"><br>

When a letter appears, participants are required to respond quickly by pressing the corresponding button on their dashboard, followed by immediately returning both hands to the steering wheel. Participants completed a total of 50 trials in the dual task. Each letter appeared for one second, with an approximate interval of 10 seconds between each letter. Participants were instructed to maintain a constant speed of 100 km/h in the left lane while simultaneously performing the task.

### Outcomes
Six primary driving endpoints are calculated using the `forum8_impaired_driving_analysis.R` script to assess simulated driving performance. The definitions of these outcomes are as follows:
*	**SDLP**: Measured in centimetres, with an increase in SDLP indicating decreased vehicle control. To reduce the influence of intentional deviation from the lane centre, data points during lane change events marked using indicators (e.g., over-taking traffic) are removed, & only data from the target lane are included.
*	**Mean speed**: Mean speed, measured in km/h, sustained throughout the task.
*	**SDS**: The standard deviation of speed, measured in km/h, with an increase in SDS indicating an increase in speed variability.
*	**Steering variability**: The standard deviation of the steering wheel angle values ranging from 0 (absolute center) to 1 (absolute left or right) with higher values represent increased movement of the steering wheel. 
*	 **Lane deviations**: Scored as 1 each time the vehicle crossed from the driving lane into the left shoulder or right lane, excluding intentional overtaking manoeuvres.
*	**Mean headway**: Mean distance, measured in meters, maintained between the participant’s vehicle and the lead vehicle during the car-following task.
*	**Headway variability**: The standard deviation of headway, measured in meters, with an increase in headway indicating a decreased ability to maintain a consistent distance between the lead vehicle.

Each version includes variations in lead vehicle speed for the car-following task and stimuli order for the dual task. Additionally, the appearance of other vehicles, including make, model, and color, is randomized across each version to enhance novelty. Despite these variations, the drives remain otherwise identical to ensure comparable results across versions.

Users can easily modify weather conditions, such as rain or fog, and select between daytime and nighttime driving scenarios. By default, the tasks adhere to Australian driving regulations, with participants driving in the left lane. Customized versions tailored for the United States and European Union, inclusive of local road signage, are available upon request.

## Setup
1. Use `git clone` or download the project from this page.

2. Once you have the project files on your local machine, locate the `forum8_impaired_driving_scenario.rd` file containg the UC/win-Road scenarios.

3. Open the scenario selector within the file to choose the specific task or version you want to use. The scenario selector allows you to switch between different tasks or versions available within the single  file. 

## How to run data analysis
1. UC-win/Road output files should be named using the following format:
* "STUDYCODE_000_00_T0.csv"
* Where:
  * "STUDYCODE" is the study identifier
  * "000" is the participant number (e.g., 001, 002, 003, ...)
  * "V0" is the visit number (e.g., V1, V2, V3, ...)
  * "T0" is the drive number (e.g., T1, T2, T3, ...)

2. The `forum8_impaired_driving_analysis.R` script should be placed in the same folder as all CSV data files.

3. The script reads all CSV files in the folder & groups by participant id, visit, & drive number. 

4. Summary & raw data will be saved into data folder.

## Modifying the data analysis script
The `forum8_impaired_driving_analysis.R` script is fully customizable and includes detailed comments that explain what each line of code does. This allows you to easily adapt it to your own data analysis needs. Below are key sections you may want to customize:

### 1. Handling Different File Naming Conventions
The script assumes a specific naming convention for CSV files (`STUDYCODE_000_00_T0.csv`). If your data files have a different naming convention, you'll need to modify the section that extracts information from file names. For example:

```R
# Modify the regular expressions according to your file naming convention
driving_data$id <- as.numeric(sub("^your_regular_expression_here", "\\1", driving_data$file))
driving_data$visit <- as.factor(sub("^your_regular_expression_here", "\\1", driving_data$file))
driving_data$drive_number <- as.factor(sub("^your_regular_expression_here", "\\1", driving_data$file))
```

### 2. Adding New Data Filtering Criteria
Depending on your analysis, you may need to apply different filtering criteria to the data. For example, you could add additional filters or modify existing ones in the sections where data is being cleaned and organized.

```R
# Filtering based on a custom condition
driving_data <- driving_data %>%
  filter(custom_column >= some_value)
  ```
  
### 3. Customising data export
The script exports the data in CSV format. You could modify the export section to output the data in a different format or save it to a specific location.

```R
# Exporting the data to an Excel file
library(writexl)
write_xlsx(driving_data_summary, "path_to_save_file/driving_data_summary.xlsx")
```

Remember to ensure that any additional libraries needed for your modifications are loaded at the beginning of the script.

## Contact information
For questions or additional information about this repository, please contact baitken@swin.edu.au.



