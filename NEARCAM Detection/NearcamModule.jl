module NEARCAM
using Images, ImageSegmentation, FileIO, ImageBinarization, SparseArrays,
Clustering

include("extractROIshadowDiff.jl")
export extractROIshadowDiff,
extractLowEdge,
extractROILowEdge,
extractTapline,
detectTapline


function extractLowEdge()
    println("this is my function2")
end

function extractROILowEdge()
    println("this is my function3")
end

function extractTapline()
    println("this is my function4")
end

function detectTapline()
    println("this is my function5")
end

end