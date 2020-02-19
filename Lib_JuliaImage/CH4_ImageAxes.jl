using ImageAxes

# specify image axes :x, :y, :z
img = AxisArray(reshape(1:192, (8,8,3)), :x, :y, :z)

# Slice image anlong Axis{:z}, grab (n)
sl = img[Axis{:z}(2)]