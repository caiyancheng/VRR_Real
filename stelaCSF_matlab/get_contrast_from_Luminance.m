function contrast = get_contrast_from_Luminance(Luminance, fit_poly_degree, size_value) 
    jsonFilePath = ['B:\Py_codes\VRR_Real\dL_L/KONICA_Fit_result_poly_' num2str(fit_poly_degree) '_noabs.json'];
    jsonData = jsondecode(fileread(jsonFilePath));
    if (size_value == 0.5)
        coefficients = jsonData.size_0_5.coefficients;
    elseif (size_value == 1)
        coefficients = jsonData.size_1.coefficients;
    elseif (size_value == 16)
        coefficients = jsonData.size_16.coefficients;
    elseif (size_value == (62.666+37.808)/4)
        coefficients = jsonData.size_full.coefficients;
    else
        coefficients = jsonData.size_all.coefficients;
    end
    contrast = abs(polyval(coefficients, log10(Luminance)));
end
