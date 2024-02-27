##############
# 3D forest hegiht with R
# 25/02/2024
# Video tutorial: https://www.youtube.com/watch?v=4ScYWPMzy6E

###################################
# 1.- INSTALL LIBRARIES
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
# 2.- SEARCH AND DOWNLOAD DATASET
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
raster_files <-
list.files(
    path = getwd(),
    pattern = "ETH",
    full.names = T
)

###################################
# 3.- DEFINE AREA OF STUDY
# Use GADM data for the specified region
get_country_borders <- function() {
    main_path <- getwd()
    country_borders <- geodata::gadm(
        country = "MX",
        level = 1,
        path = main_path
    ) |> sf::st_as_sf()

    return(country_borders)
}

# Show the list of elements included in the data
country_borders <- get_country_borders()
unique(
    country_borders$NAME_1
)

# Select desired AOE
Jalisco_sf <- country_borders |>
    dplyr::filter(
        NAME_1 == "Jalisco"
    ) |> sf::st_as_sf()

# ----------------------------------
# 4.- LOAD FOREST HEIGHT

# Load downloaded data
forest_height_list <- lapply(
    raster_files,
    terra::rast
)

print("Crop files")
# Crop files
forest_height_rasters <- lapply(
    forest_height_list,
    function(x) {
        terra::crop(
            x,
            # Crop area
            terra::vect(
                Jalisco_sf
            ),
            # Tell terra library keep the elements inside 
            snap = "in"
            # mask = T
        )
    }
)

# Create the mosaic
forest_height_mosaic <- do.call(
    terra::mosaic,
    forest_height_rasters
)

# Aggregate data
forest_height_Jalisco <- forest_height_mosaic |>
  terra::aggregate(
    fact = 10
  )

# ----------------------------------
# 5. RASTER TO DATAFRAME
# convert mosaic to dataframe
forest_height_Jalisco_df <- forest_height_Jalisco |>
  as.data.frame(
    xy = T
  )

head(forest_height_Jalisco_df)
names(forest_height_Jalisco_df)[3] <- "height"

# ----------------------------------
# 5. BREAKS
fixed_breaks_df <- c(0, 10, 20, 30, 40, 50, 60)

breaks <- classInt::classIntervals(
    forest_height_Jalisco_df$height,
    n = 6,
    style = "fixed",
    fixedBreaks = fixed_breaks_df
)$brks

# ----------------------------------
# 5. Color pallete
colors <- c(
    "white", "#ffd3af", "#fbe06e", 
    "#6daa55", "#205544"
)

texture <- colorRampPalette(
    colors,
    bias = 2

)(7) # Number of colors to createe