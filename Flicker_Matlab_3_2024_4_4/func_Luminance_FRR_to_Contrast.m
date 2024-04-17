function contrast = func_Luminance_FRR_to_Contrast(Luminance, T_frequency, coefficients)
    contrast = max(polyvaln(coefficients, [Luminance, T_frequency]),0);
end
