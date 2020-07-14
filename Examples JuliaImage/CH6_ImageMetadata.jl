#ImageMeta type combines properties of arrays and Dict

using Colors, ImageMetadata, Dates
img = ImageMeta(fill(RGB(1,0,0), 3, 2), date=Date(2016, 7, 31), time="high noon")

#access img data by
img.data # old
data(img) # old
arraydata(img)

# change change metadata 
img.time = "morning"

# set of pixel from ImageMeta is ImageMeta

# copy version
# make a copy of metadata : similar()
c = img[1:2, 1:2];
display("text/plain",arraydata(c))

# view version
# share metadata : shareproperties()
v = view(img, 1:2, 1:2);
display("text/plain",arraydata(v))

# spatialproperties
# properties corresponding to axis
A = reshape(1:15, 3, 5)

# example sum along axis
img = ImageMeta(A, spatialproperties=Set([:maxsum]), 
                maxsum=[maximum(sum(A,dims=1)), 
                maximum(sum(A,dims=2))])

imgp = permutedims(img, (2,1))