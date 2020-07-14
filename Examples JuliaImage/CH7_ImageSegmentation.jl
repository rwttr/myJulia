using Images, ImageSegmentation, FileIO

img = load("horse.jpg")

# Store seed point in (position, label) tuples
seeds = [(CartesianIndex(126,81),1), 
         (CartesianIndex(93,255),2), 
         (CartesianIndex(213,97),3)]
segments = seeded_region_growing(img, seeds)
print(seeds)