# MIDAS.jl - Automated GPS Time Series Processing Tool

## Overview
`MIDAS.jl` is a tool that automates the pipeline for processing GPS time series
for surface deformation analysis. In one call, you can:
1. Download the data from all available stations in your AOI
2. Estimate linear surface deformation rates over the desired time window
3. Plot the raw and fitted time series

## Get started

### Clone the repository
Navigate to the desired directory and run:
```bash
git clone git@github.com:AlexLasalarie/MIDAS.git MIDAS
cd MIDAS
```

### Add the dependencies
Start Julia.
```bash
julia
```
Enter Package mode by typing `]`:
```bash
pkg> activate .
pkg> instantiate
pkg> status
```
Press Backspace to return to the standard Julia prompt once finished.
You can now exit the REPL:
```bash
julia> exit()
```

### Quick launch
To start a development session with all available CPU threads and auto-load the environment:
```bash
julia auto -i dev_startup.jl
```
This will launch the package and load useful development tools, if found in your
global environment.

### Manual launch
Start a Julia session:
```bash
julia
```
Enter Package mode by typing `]`:
```bash
pkg> activate .
```
Exit package mode by pressing Backspace and run:
```bash
julia> using MIDAS
```

## Automated processing of GPS time data

### Download data
Download all the data available over your area of interest by running:
```bash
julia> cd("/path/to/data/directory/")
julia> fetch_data(min_lat, max_lat, min_lon, max_lon)
```
, where `min_lat`, `max_lat`, `min_lon`, `max_lon` define your bounding box.

### Convert to tenv format
The data is downloaded in `.tenv3` format and contains the full time history of
each station. Trim the time series to the desired time window and convert the
data to `tenv` format by running:
```bash
julia> convert2tenv(t1, t2)
```
, where `t1` is the start time and `t2` is the end time, formatted as 
`"yyyymmdd"` strings (i.e. Year, Month, Day).

### Evaluate trends
Estimate linear trends and generate robust fits for all stations using the MIDAS 
algorithm:
```bash
julia> batch_midas(midas_bin)
```
, `midas_bin` is the path to the MIDAS binary.

### Visualize
You can generate plots of the results by running:
```bash
julia> batch_tsplot(frame)
```
, where `frame` is the reference frame of the data (e.g. "NA" for North American
Plate fixed).

## Citations
If you use the `fitted time series` in a publication, please cite:
```
Blewitt, G., C. Kreemer, W. C. Hammond, and J. Gazeaux (2016), MIDAS robust trend estimator for accurate GPS station velocities without step detection, J. Geophys. Res. Solid Earth, 121, 2054-2068, doi:10.1002/2015JB012552.
```

For the GPS data, please cite:
```
Blewitt, G.,Hammond, W. C., and Kreemer, C. (2018), Harnessing the GPS data explosion for interdisciplinary science, Eos, 99, https://doi.org/10.1029/2018EO104623. Published on 24 September 2018.
```
