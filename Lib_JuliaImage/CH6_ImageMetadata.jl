#ImageMeta type combines properties of arrays and Dict

using Colors, ImageMetadata, Dates
img = ImageMeta(fill(RGB(1,0,0), 3, 2), date=Date(2016, 7, 31), time="high noon")

#access img data by
img.data # old
data(img) # old
arraydata(img)

# change change metadata 
img.time = "morning"

