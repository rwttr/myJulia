using Images, ImageSegmentation

img = load("Lib_JuliaImage/horse.jpg")

# Store seed point in (seed position, label) tuples
seeds = [(CartesianIndex(126,81),1), 
         (CartesianIndex(93,255),2), 
         (CartesianIndex(213,97),3)]
segments = seeded_region_growing(img, seeds)
