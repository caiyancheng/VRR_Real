function scale_s = get_scale_from_ecc_simple(ecc_s) %强烈建议使用fit_degree=1
    jsonFilePath = '..\VRR_subjective_Quest\fit_poly_eccentricity_all.json';
    jsonData = jsondecode(fileread(jsonFilePath));
    scale_s = zeros(1,length(ecc_s));
    coefficients = jsonData.fit_degree_1_coefficients;
    c_0 = polyval(coefficients, 0);
    for ecc_i = 1:length(ecc_s)
        ecc_value = abs(ecc_s(ecc_i));
        scale_s(ecc_i) = c_0/polyval(coefficients, ecc_value);
    end
end
