function extractROIshadowDiff(fnameRGB1, fnameRGB2)
    # 1st function
    rgb1 = load(fnameRGB1);
    rgb2 = load(fnameRGB2);
    
    rgb1_gray = Gray.(rgb1);
    rgb2_gray = Gray.(rgb2);

    # ---------- Trunk Segmentation -----------
    # Remove Holes within Trunk
    I_trunk = binarize(rgb1_gray, Otsu());    
    I_trunk2 = imfill(.!Bool.(I_trunk), (0, 2000));
    I_trunk_mask = Gray.(.!I_trunk2);

    # Convert Color type to Standard Array of Floating point
    rgb1_masked = convert(Array{Float32}, rgb1_gray .* I_trunk_mask);
    rgb2_masked = convert(Array{Float32}, rgb2_gray .* I_trunk_mask);

    # ---------- Image Diff -----------
    # Normalize Brightness : Recenter mean at 0 Value
    # Valid pixel locations on trunk
    trunk_validpx = findall(Bool.(I_trunk_mask));

    rgb1_validpx = rgb1_masked[trunk_validpx];
    rgb2_validpx = rgb2_masked[trunk_validpx];

    # Mean valid pixel values
    meanPxVal_rgb1 = mean(rgb1_validpx);
    meanPxVal_rgb2 = mean(rgb2_validpx);

    # Normalize
    rgb1_validpx_n = rgb1_validpx .- meanPxVal_rgb1;
    rgb2_validpx_n = rgb2_validpx .- meanPxVal_rgb2;

    # Image Diff
    rgb_diff = rgb1_validpx_n - rgb2_validpx_n;

    # Soft-threshold negative to zero
    for i in eachindex(rgb_diff)
        if rgb_diff[i] < 0
            rgb_diff[i] = 0;
        end
    end

    # -------------- K-means (input = row vector) -----------------    
    # Initial Centroids
    nnz_rgb_diff = sparse(rgb_diff);  
    initial_centroid = [0;mean(nnz_rgb_diff.nzval);maximum(rgb_diff)]';
    R = kmeans!(rgb_diff', initial_centroid; maxiter=100, display=:none);

    # Pick highest cluster
    R_label = R.centers;
    max_label = findall(x -> x == maximum(R_label), R_label[:]);
    # Beware type of searching pivot
    pick_idx = findall(x -> x == max_label[1], R.assignments);
    bg_idx = findall(x -> x != max_label[1], R.assignments);

    resultpx = rgb_diff;
    resultpx[bg_idx] .= 0;
    resultpx[pick_idx] .= 1;


    #I_output = rgb1_gray .* 0;
    #I_output[R_pick] .= 1;

    # ------------ Preprocessing : Median Filter 3x3 ----------------
    I_output = rgb1_gray .* 0;
    I_output[trunk_validpx] .= resultpx;
    I_output = Bool.(I_output);
    I_output = mapwindow(median, I_output, (3, 3))
    # Return Binary
    return I_output
end