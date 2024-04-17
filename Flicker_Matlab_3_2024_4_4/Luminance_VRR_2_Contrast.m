classdef Luminance_VRR_2_Contrast
    properties
        coefficients
    end
    
    methods
        function obj = Luminance_VRR_2_Contrast()
            jsonFilePath = 'E:\Py_codes\VRR_Real\Flicker_Matlab_3_2024_4_4/Luminance_FRR_to_Contrast.json';
            jsonData = jsondecode(fileread(jsonFilePath));
            obj.coefficients = jsonData.coefficients_3d;
        end
        
        function Contrast = LT2C(obj, log10_Luminance, T_frequency)
            Contrast = max(polyvaln(obj.coefficients, [log10_Luminance, T_frequency]),0);
            % Contrast = polyvaln(obj.coefficients, [log10_Luminance, T_frequency]);
        end
    end
end
