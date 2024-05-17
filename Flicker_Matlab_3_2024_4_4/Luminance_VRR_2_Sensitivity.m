classdef Luminance_VRR_2_Sensitivity
    properties
        coefficients
    end
    
    methods
        function obj = Luminance_VRR_2_Sensitivity()
            jsonFilePath = 'E:\Py_codes\VRR_Real\Flicker_Matlab_3_2024_4_4/Luminance_FRR_to_Sensitivity.json';
            jsonData = jsondecode(fileread(jsonFilePath));
            obj.coefficients = jsonData.coefficients_1d;
        end
        
        function Sensitivity = LT2S(obj, Luminance, T_frequency)
            log10_Luminance = log10(Luminance);
            Sensitivity = 10 .^ polyvaln(obj.coefficients, [log10_Luminance, T_frequency]);
        end
        function log10_Sensitivity = LT2S_log(obj, log10_Luminance, T_frequency)
            log10_Sensitivity = polyvaln(obj.coefficients, [log10_Luminance, T_frequency]);
        end
    end
end
