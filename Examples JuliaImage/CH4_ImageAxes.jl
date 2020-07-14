using ImageAxes

# specify image axes :x, :y, :z
img = AxisArray(reshape(1:192, (8,8,3)), :x, :y, :z)

# Slice image anlong Axis{:z}, grab (n) plate
sl = img[Axis{:z}(2)]

# Give Axis Unit
using Unitful
const mm = u"mm"
img = AxisArray(reshape(1:192, (8,8,3)),
                Axis{:x}(1mm:1mm:8mm),
                Axis{:y}(1mm:1mm:8mm),
                Axis{:z}(2mm:3mm:8mm));

# Temporal Axis (Axis{:time})
# ------------------------------------------------
const s = u"s"
img = AxisArray(reshape(1:9*300, (3,3,300)),
                Axis{:x}(1:3),
                Axis{:y}(1:3),
                Axis{:time}(1s/30:1s/30:10s))
# retrieve temporal axis
ax = timeaxis(img)
#indexing time axis
img[ax(4)] # returns the 4th "timeslice"
