using Images, CoordinateTransformations, TestImages

img = testimage("mri");
println(summary(img))

# Example Transformation
tfm = recenter(RotMatrix(pi/8), center(img)[1:2]) 

