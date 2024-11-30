function S = simple_lCSF(luminance, k1, k2, k3)
    S = k1 .* ((1 + k2./luminance) .^ (-k3));
end