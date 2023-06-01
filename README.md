# Forum8 Impaired Driving

## Overview
This Github repository was created in conjuction with the open-access publication: 

Aitken, B. & Arkell, T. (2023). Validation of a Novel Driving Simulation Task: A Pilot Study. 

## Table of Contents

- [Overview](#overview)
- [Dependencies](#dependencies)
- [Driving simulations](#driving-simulations)
  - [Highway driving task](#highway-driving-task)
  - [Car-following task](#car-following-task)
  - [Dual task](dual-task)
  - [Outcomes](#outcomes)
- [How to run data analysis](#how-to-run-data-analysis)
- [Contact information](#contact-information)

## Dependencies 
* R (https://cran.r-project.org)
  * data.table (https://github.com/Rdatatable/data.table)
  * tidyverse (https://www.tidyverse.org) 
* UC-win/Road Ver. 14 by Forum8 (https://www.forum8.co.jp)

## Driving simulations
The `forum8_impaired_driving_scenarios.rd` file contains a total of 7 unique, yet comparable UC-win/Road Version 13 compatable driving simulations comprising of three 8-minute tasks:

### Highway driving task
In the highway drive, participants are instructed to drive at a constant speed of 100 km/h, braking & overtaking other vehicles if necessary. This task includes four over-taking events spaced evenly over the 12 km drive.

### Car-following task
The car-following task commences with a vehicle appearing approximately 50 meters in front of the participants vehicle & participants are instructed to follow & maintain a safe but constant distance (headway) to it.

<br><img width="500" alt="Car-following Task" src="https://github.com/blair-aitken/Forum8_Impaired_Driving/assets/131508862/6b61392f-ed8c-4cf8-bae4-d3daa5848bbb"><br><br>

The lead vehicle accelerates or decelerates every 400 meters in a sinusoidal manner between 60 & 90 km/h, with single speed changes of no more than ± 10 km/h. Thus, participants must slow down in order to avoid collision, & to speed up in order to keep up with the leading car

### Dual task
During this task, letters ranging from A to F appear inside a green hexagon are presented on screen directly in front of the participant. As each letter appears, participants respond by quickly press the corresponding button on their dashboard & promptly return both hands to the steering wheel.

<br><img width="500" alt="Divided Attention Task" src="https://github.com/blair-aitken/Forum8_Impaired_Driving/assets/131508862/ae75cb19-188e-4945-a6d2-d525edb1fa13"><br><br>

A total of 50 trials are presented, with each letter appearing for X seconds every 10 seconds. Participants are also instructed to maintain a constant speed of 100 km/h in the left lane while driving. 

### Outcomes
Six primary driving endpoints are calculated using the `forum8_impaired_driving_analysis.R` script to assess simulated driving performance. The definitions of these outcomes are as follows:
*	**SDLP**: Measured in centimetres, with an increase in SDLP indicating decreased vehicle control. To reduce the influence of intentional deviation from the lane centre, data points during lane change events marked using indicators (e.g., over-taking traffic) are removed, & only data from the target lane are included.
*	**Mean speed**: Mean speed, measured in km/h, sustained throughout the task.
*	**SDS**: The standard deviation of speed, measured in km/h, with an increase in SDS indicating an increase in speed variability.
*	**Steering variability**: The standard deviation of the steering wheel angle values ranging from 0 (absolute center) to 1 (absolute left or right) with higher values represent increased movement of the steering wheel. 
*	 **Lane deviations**: Scored as 1 each time the vehicle crossed from the driving lane into the left shoulder or right lane, excluding intentional overtaking manoeuvres.
*	**Mean Headway**: Mean distance, measured in meters, maintained between the participant’s vehicle and the lead vehicle during the car-following task.
*	**Headway variability**: The standard deviation of headway, measured in meters, with an increase in headway indicating a decreased ability to maintain a consistent distance between the lead vehicle.

Each of the simulations contain variations in lead vehicle speed (car-following task) & stimuli order (dual task). The appearance (i.e., make, model & colour) of other vehicles was also randomised for each drive to further increase the novelty.The drives are otherwise identical so that each version will produce comparable results. For example, the length of each drive, the environments encountered & key drive features are the same for each simulation. 

The daytime driving environment is realistically portrayed with road signs & other vehicles (cars, buses, trucks & motorcycles) which travelled in the opposing lane at a constant speed. The landscape contains trees, mountains & clouds in a foggy sky. In each task, participants drove along a straight, dual-carriage highway in the left (in accordance with Australian driving regulations).

All 7 versions of the driving simulation are located in the `Forum8_Drives` folder.

## How to run data analysis
1. UC-win/Road output files should be named using the following format:
* "STUDYCODE_000_00_T0.csv"
* Where:
  * "STUDYCODE" is the study identifier
  * "000" is the participant number (e.g., 001, 002, 003, ...)
  * "V0" is the visit number (e.g., V1, V2, V3, ...)
  * "T0" is the drive number (e.g., T1, T2, T3, ...)

2. The `forum8_impaired_driving_analysis.R` script should be placed in the same folder as all CSV data files.

3. The script reads all CSV files in the folder & groups by Study, participant number, visit number & drive number. 

4. Summary & raw data will be saved into data folder. 

## Contact information
For questions or additional information about this repository, please contact baitken@swin.edu.au.



