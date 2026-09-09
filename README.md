# MIDAS.jl - Automated GPS Time Series Processing Tool

## Overview
`MIDAS.jl` automates the pipeline for processing GPS time series to perform
surface deformation analysis. In a single workflow, you can:
* Download GPS data across any area of interest (AOI)
* Estimate robust linear surface deformation trends via the MIDAS algorithm
* Generate plots of raw and fitted time series

---

## Installation and setup

### 1. Compile the MIDAS binary
MIDAS requires the core Fortran binary compiled from the 
[UNR Geodesy website](https://geodesy.unr.edu/). Download the package under 
`Download the MIDAS code and examples`, compile the binary, and note the path 
to your executable (e.g., `/path/to/.midas/midas`).

### 2. Clone the repository
Navigate to the desired directory and run:
```bash
git clone git@github.com:AlexLasalarie/MIDAS.git MIDAS
cd MIDAS
```

### 3. Install dependencies
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

---

## Launch options

### Quick launch
To start a development session and auto-load the environment:
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

---

## Automated processing workflow
For clean organization, navigate to your target working directory before running
pipeline commands:
```bash
julia> cd("/path/to/data/directory")
```

### Full automated pipeline
Execute the entire download, filtering, fitting, and plotting pipeline in a 
single command:
```bash
julia> auto_midas(min_lat, max_lat, min_lon, max_lon, t1, t2, midas_bin)
```
**Parameters:**
* `min_lat`, `max_lat`, `min_lon`, `max_lon`: bounding box coordinates of AOI
* `t1`, `t2`: start and end dates formatted as "yyyymmdd" strings (e.g., "20010101")
* `midas_bin`: absolute path to your compiled MIDAS binary file

---

## Modular pipeline steps
If you prefer running the analysis step-by-step:

* **Fetch data:** download all available data over your AOI.
```bash
julia> fetch_data(min_lat, max_lat, min_lon, max_lon)
```

* **Convert format:** trim records to desired time window and convert files to
`tenv` format.
```bash
julia> convert2tenv(t1, t2)
```

* **Evaluate trends:** Estimate linear trends and generate robust fits using the 
MIDAS algorithm.
```bash
julia> batch_midas(midas_bin)
```

* **Visualize:** generate and save summary plots into a local `figs` directory.
```bash
julia> batch_tsplot(frame)  # e.g., frame = "NA" for North American Plate
```

## Citations
When using `MIDAS.jl` or data derived from this pipeline in publications, please
cite:
* **MIDAS algorithm:**
```
Blewitt, G., C. Kreemer, W. C. Hammond, and J. Gazeaux (2016), MIDAS robust trend estimator for accurate GPS station velocities without step detection, J. Geophys. Res. Solid Earth, 121, 2054-2068, doi:10.1002/2015JB012552.
```
* **GPS data archive:**
```
Blewitt, G.,Hammond, W. C., and Kreemer, C. (2018), Harnessing the GPS data explosion for interdisciplinary science, Eos, 99, https://doi.org/10.1029/2018EO104623. Published on 24 September 2018.
```
