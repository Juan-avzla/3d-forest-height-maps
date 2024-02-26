##############
# 3D forest hegiht with R
# 25/02/2024
# Video tutorial: https://www.youtube.com/watch?v=4ScYWPMzy6E

###################################
# Install libraries
libs <- c(
    "tidyverse", "sf", "geodata",
    "terra", "classInt", "rayshader"    
)

# Check if the libraries are already isntalled
installed_libs <- libs %in% rownames(
    installed.packages()
)

# Install the libraries which aren't installed
if(any(installed_libs == F)){
    # Select mirror
    options(repos = c(CRAN = "https://cran.rstudio.com"))

    install.packages(
        libs[!installed_libs]
    )
}

invisible(lapply(
   libs,
   library,
   character.only = T
))

###################################
# Search for dataset
# ETH Global Sentinel-2 10m Canopy Height (2020)
# Dataset.Info: https://gee-community-catalog.org/projects/canopy/
# Dataset: https://www.research-collection.ethz.ch/handle/20.500.11850/609802

# Download ETH data from tile_index.html
urls <- c(
    "https://libdrive.ethz.ch/index.php/s/cO8or7iOe5dT2Rt/download?path=%2F3deg_cogs&files=ETH_GlobalCanopyHeight_10m_2020_N21W105_Map.tif",
    "https://libdrive.ethz.ch/index.php/s/cO8or7iOe5dT2Rt/download?path=%2F3deg_cogs&files=ETH_GlobalCanopyHeight_10m_2020_N21W102_Map.tif",
    "https://libdrive.ethz.ch/index.php/s/cO8or7iOe5dT2Rt/download?path=%2F3deg_cogs&files=ETH_GlobalCanopyHeight_10m_2020_N18W108_Map.tif",
    "https://libdrive.ethz.ch/index.php/s/cO8or7iOe5dT2Rt/download?path=%2F3deg_cogs&files=ETH_GlobalCanopyHeight_10m_2020_N18W105_Map.tif",
    "https://libdrive.ethz.ch/index.php/s/cO8or7iOe5dT2Rt/download?path=%2F3deg_cogs&files=ETH_GlobalCanopyHeight_10m_2020_N18W102_Map.tif"
)

# Download the data
for (url in urls) {
    download.file(
        url,
        destfile = sub(".*=","", basename(url)),
        mode = "wb",
        timeout = 120
    )
}

# Inspect the elements
# raster_files <-
list.files(
    path = getwd(),
    pattern = "ETH",
    full.names = T
)

