library(raster)
setwd("/home/lyndsay/docs/contribution")

geo <- read.csv("geography.csv")

elev <- raster("ETOPO1_Ice_g_geotiff.tif")
geo$elevation <- extract(elev, geo[, c("lon", "lat")], method="simple")

worldclim <- getData("worldclim",var="bio",res=10)
climate <- worldclim[[c(1,2,7,12,15)]]
names(climate) <- c("avg_temp", "diurnal_range", "annual_temp_range", "avg_precipitation","precipitation_seasonality")
points <- SpatialPoints(data.frame(geo$lon, geo$lat), proj4string = climate@crs)
values <- extract(x=climate,y=points)
geo <- cbind.data.frame(geo$glottocode, geo$elevation, coordinates(points),values)
names(geo) <- c("Glottocode", "elevation", "lon", "lat", "avg_temp", "diurnal_range","annual_temp_range", "avg_precipitation", "precipitation_seasonality")
geo$avg_temp = geo$avg_temp / 10 # WorldClim stores temps as 10*C, just removing that scale so data is clearer
geo$diurnal_range = geo$diurnal_range / 10
geo$annual_temp_range = geo$annual_temp_range / 10

detach("package:raster", unload=TRUE)
library(dplyr)
geo <- geo %>% select(-lon, -lat)
ejectives <- read.csv("ejectives.csv")
ejectives <- left_join(ejectives, geo, by="Glottocode")
rm(geo, elev, climate, points, values, worldclim)
ejectives <- ejectives %>% select(-X)
ejectives <- ejectives %>% filter(elevation >= -5)
write.csv(ejectives, "ejectives.csv")
