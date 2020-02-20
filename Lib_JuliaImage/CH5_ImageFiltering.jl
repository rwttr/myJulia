using ImageFiltering, TestImages, Images

# Basic Filtering : imfilter()
# Correlation !
img = testimage("mandrill")
imgg = imfilter(img, Kernel.gaussian(3))
imgl = imfilter(img, Kernel.Laplacian())

# Convolution : reflect(kernel)
imgg_conv = imfilter(img, reflect(Kernel.gaussian(3)))

# OffsetArrays.jl
# convert array to set 0,0 at the center : centered() 
centered([1 0 1; 0 1 0; 1 0 1])

# Factored Kernel
# separable property of kernel
kern1 = centered([1/3, 1/3, 1/3])
kernf = kernelfactors((kern1, kern1))
kernp = broadcast(*, kernf...)

imfilter(img, kernf) ≈ imfilter(img, kernp)

# ImageFiltering.imgradients()
Gy, Gx = imgradients(img,Kernel.sobel, "replicate");

# factored kernel
Gy, Gx = imgradients(img,KernelFactors.sobel, "replicate");