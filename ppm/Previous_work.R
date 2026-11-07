library(tidyverse)

#This code is intended for all users without R knoledge, that means, just follow the instructions from each letter(A), (B), (C).

# 1. Here you upload your GC data
# (A) PASTE YOUR CSV DATA DIRECTLY BETWEEN THE QUOTES BELOW
csv_data <- "ID,Gas,RT_[min],Width_[min],Area,Height
NAME_SAMPLE_DATE_PROJECT.D,CH4,3.319,0.08,13.1,2.49
NAME_SAMPLE_DATE_PROJECT.D,CO2,5.799,0.17,1197.55,113.09
NAME_SAMPLE_DATE_PROJECT.D,N2O,7.189,0.14,198.1,18.74
"

#2. Load CSV data
data <- read_csv(csv_data, show_col_types = FALSE)

#3. Calculate PPM based on gas equations 
#(B) Change equation depending on your standards
df_ppm <- data %>%
  mutate(
    ppm = case_when(
      Gas == "N2O" ~ Area / 505.2,
      Gas == "CH4" ~ (Area + 33.735) / 6.1221, 
      Gas == "CO2" ~ (Area - 166.58) / 5.2381, 
      TRUE ~ NA_real_
    )
  )

#4. Split by gas, this creates a .csv for each gas within one date across multiple time points,
#(C)ADD THE DATE OR EDIT THE "NAME.csv" file as you wish
df_ppm |> 
  group_split(Gas)  |> 
  walk(function(gas_data) {
    gas_name <- unique(gas_data$Gas)
    col_name <- paste0("ppm_", gas_name)
    
    gas_data  |> 
      rename(!!col_name := ppm)  |> 
      select(ID, Gas, all_of(col_name)) |> 
      write_csv(paste0(gas_name, "DATE_ppm.csv"))
  })