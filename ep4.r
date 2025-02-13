# ep 4

# we should already have dataframes for 
# HARV_DTM and HARV_DSM
# if need to reload and remake HARV_DSM

DSM_HARV <- 
  rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")
DSM_HARV_df <- as.data.frame(DSM_HARV, xy = TRUE)
names(DSM_HARV_df)[names(DSM_HARV_df) == 'HARV_dsmCrop'] <- 'Elevation'


# describe the files
# will they overlay?
# green / red
describe("data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif")
describe("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")

# crs, resolution, and extent are all the same!


# Terrain
# Think "Treetops"
ggplot() +
  geom_raster(data = DTM_HARV_df , 
              aes(x = x, y = y, fill = HARV_dtmCrop)) +
  scale_fill_gradientn(name = "Elevation", colors = terrain.colors(10)) + 
  coord_quickmap()

# Surface
# Think "Bare" surface
ggplot() +
  geom_raster(data = DSM_HARV_df , 
              aes(x = x, y = y, fill = Elevation)) +
  scale_fill_gradientn(name = "Elevation", colors = terrain.colors(10)) + 
  coord_quickmap()


# do math to create canopy height model
# treetops - bare earth = tree height
CHM_HARV <- DSM_HARV - DTM_HARV
CHM_HARV_df <- as.data.frame(CHM_HARV, xy = TRUE)

ggplot() +
  geom_raster(data = CHM_HARV_df , 
              aes(x = x, y = y, fill = HARV_dsmCrop)) + 
  scale_fill_gradientn(name = "Canopy Height", colors = terrain.colors(10)) + 
  coord_quickmap()

#check distribution of values
# lots of pixels near the ground
# lots of 20 meter trees
# makes sense
ggplot(CHM_HARV_df) +
  geom_histogram(aes(HARV_dsmCrop))


# challenge
min(CHM_HARV_df$HARV_dsmCrop, na.rm = TRUE)

max(CHM_HARV_df$HARV_dsmCrop, na.rm = TRUE)

ggplot(CHM_HARV_df) +
  geom_histogram(aes(HARV_dsmCrop))

ggplot(CHM_HARV_df) +
  geom_histogram(aes(HARV_dsmCrop), colour="black", 
                 fill="darkgreen", bins = 6)

# the above has auto-breaks. we want to specify our own.
custom_bins <- c(0, 10, 20, 30, 40)
CHM_HARV_df <- CHM_HARV_df %>%
  mutate(canopy_discrete = cut(HARV_dsmCrop,
                               breaks = custom_bins))

ggplot() +
  geom_raster(data = CHM_HARV_df, aes(x = x, y = y,
                                  fill = canopy_discrete)) + 
  scale_fill_manual(values = terrain.colors(4)) + 
  coord_quickmap()

# Efficient Raster Calculations
# this is the second way to do raster math: an overlay
CHM_ov_HARV <- lapp(sds(list(DSM_HARV,DTM_HARV)),
                       fun = function(r1, r2) { return( r1 - r2) })

CHM_ov_HARV_df <- as.data.frame(CHM_ov_HARV, xy = TRUE)

ggplot() +
  geom_raster(data = CHM_ov_HARV_df, 
              aes(x = x, y = y, fill = HARV_dsmCrop)) + 
  scale_fill_gradientn(name = "Canopy Height", colors = terrain.colors(10)) + 
  coord_quickmap()


# you'll see these are the same.
max(CHM_ov_HARV_df$HARV_dsmCrop, na.rm = TRUE)
max(CHM_HARV_df$HARV_dsmCrop, na.rm = TRUE)

# save our work
writeRaster(CHM_ov_HARV, "output/CHM_HARV.tiff",
            filetype="GTiff",
            overwrite=TRUE,
            NAflag=-9999)

## SJER Challenge
CHM_ov_SJER <- lapp(sds(list(DSM_SJER, DTM_SJER)),
fun = function(r1, r2){ return(r1 - r2) })

CHM_ov_SJER_df <- as.data.frame(CHM_ov_SJER, xy = TRUE)

ggplot(CHM_ov_SJER_df) +
  geom_histogram(aes(SJER_dsmCrop))

ggplot() +
  geom_raster(data = CHM_ov_SJER_df, 
              aes(x = x, y = y, 
                  fill = SJER_dsmCrop)
  ) + 
  scale_fill_gradientn(name = "Canopy Height", 
                       colors = terrain.colors(10)) + 
  coord_quickmap()

writeRaster(CHM_ov_SJER, "output/chm_ov_SJER.tiff",
            filetype = "GTiff",
            overwrite = TRUE,
            NAflag = -9999)

#compare plots 
# alot more bare earth in the desert, eh?
ggplot(CHM_HARV_df) +
  geom_histogram(aes(HARV_dsmCrop))

ggplot(CHM_ov_SJER_df) +
  geom_histogram(aes(SJER_dsmCrop))
