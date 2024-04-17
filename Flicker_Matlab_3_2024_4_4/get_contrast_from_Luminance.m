function contrast = get_contrast_from_Luminance(Luminance, fit_poly_degree, radius_value) 
    jsonFilePath = ['..\dL_L/KONICA_Fit_result_poly_' num2str(fit_poly_degree) '_noabs.json'];
    jsonData = jsondecode(fileread(jsonFilePath));
    if (radius_value == 0.25)
        coefficients = jsonData.size_0_5.coefficients;
    elseif (radius_value == 0.5)
        coefficients = jsonData.size_1.coefficients;
    elseif (radius_value == 8)
        coefficients = jsonData.size_16.coefficients;
    elseif (radius_value == (62.666*37.808/pi)^0.5)
        coefficients = jsonData.size_full.coefficients;
    else
        coefficients = jsonData.size_all.coefficients;
    end
    contrast = abs(polyval(coefficients, log10(Luminance)));
end
