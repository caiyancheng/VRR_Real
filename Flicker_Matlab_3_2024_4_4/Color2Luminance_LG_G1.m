classdef Color2Luminance_LG_G1
    properties
        degree_C2L
        degree_L2C
        C2L_coefficients
        C2L_coefficients_full
        color_value_min
        color_value_min_Luminance
        color_value_min_Luminance_full
        color_value_max
        color_value_max_Luminance
        color_value_max_Luminance_full
        L2C_coefficients
        L2C_coefficients_full
        Luminance_value_min
        Luminance_value_min_color
        Luminance_value_min_color_full
        Luminance_value_max
        Luminance_value_max_color
        Luminance_value_max_color_full
    end
    
    methods
        function obj = Color2Luminance_LG_G1(degree_C2L, degree_L2C)
            obj.degree_C2L = degree_C2L;
            obj.degree_L2C = degree_L2C;
            C2L_fit_result = jsondecode(fileread(sprintf('E:\\Py_codes\\VRR_Real\\G1_Calibration\\KONICA_Color_Luminance_Fit_result_poly_%d.json', degree_C2L)));
            L2C_fit_result = jsondecode(fileread(sprintf('E:\\Py_codes\\VRR_Real\\G1_Calibration\\KONICA_Luminance_Color_Fit_result_poly_%d.json', degree_L2C)));
            
            obj.C2L_coefficients = C2L_fit_result.size_nofull_all.coefficients;
            obj.C2L_coefficients_full = C2L_fit_result.size_full.coefficients;
            obj.color_value_min = C2L_fit_result.Color_min;
            obj.color_value_min_Luminance = 10 .^ polyval(obj.C2L_coefficients, obj.color_value_min);
            obj.color_value_min_Luminance_full = 10 .^ polyval(obj.C2L_coefficients_full, obj.color_value_min);
            obj.color_value_max = C2L_fit_result.Color_max;
            obj.color_value_max_Luminance = 10 .^ polyval(obj.C2L_coefficients, obj.color_value_max);
            obj.color_value_max_Luminance_full = 10 .^ polyval(obj.C2L_coefficients_full, obj.color_value_max);
            
            obj.L2C_coefficients = L2C_fit_result.size_nofull_all.coefficients;
            obj.L2C_coefficients_full = L2C_fit_result.size_full.coefficients;
            obj.Luminance_value_min = L2C_fit_result.Luminance_min;
            obj.Luminance_value_min_color = polyval(obj.L2C_coefficients, log10(obj.Luminance_value_min));
            obj.Luminance_value_min_color_full = polyval(obj.L2C_coefficients_full, log10(obj.Luminance_value_min));
            obj.Luminance_value_max = L2C_fit_result.Luminance_max;
            obj.Luminance_value_max_color = polyval(obj.L2C_coefficients, log10(obj.Luminance_value_max));
            obj.Luminance_value_max_color_full = polyval(obj.L2C_coefficients_full, log10(obj.Luminance_value_max));
        end
        
        function Luminance_value = C2L(obj, color_value, full_screen)
            if nargin < 3
                full_screen = false;
            end
            if full_screen
                if color_value < obj.color_value_min
                    Luminance_value = obj.color_value_min_Luminance_full;
                elseif color_value > obj.color_value_max
                    Luminance_value = obj.color_value_max_Luminance_full;
                else
                    Luminance_value = 10 .^ polyval(obj.C2L_coefficients_full, color_value);
                end
            else
                if color_value < obj.color_value_min
                    Luminance_value = obj.color_value_min_Luminance;
                elseif color_value > obj.color_value_max
                    Luminance_value = obj.color_value_max_Luminance;
                else
                    Luminance_value = 10 .^ polyval(obj.C2L_coefficients, color_value);
                end
            end
        end
        
        function color_value = L2C(obj, Luminance_value, full_screen)
            if nargin < 3
                full_screen = false;
            end
            if full_screen
                if Luminance_value < obj.Luminance_value_min
                    color_value = obj.Luminance_value_min_color_full;
                elseif Luminance_value > obj.Luminance_value_max
                    color_value = obj.Luminance_value_max_color_full;
                else
                    color_value = polyval(obj.L2C_coefficients_full, log10(Luminance_value));
                end
            else
                if Luminance_value < obj.Luminance_value_min
                    color_value = obj.Luminance_value_min_color;
                elseif Luminance_value > obj.Luminance_value_max
                    color_value = obj.Luminance_value_max_color;
                else
                    color_value = polyval(obj.L2C_coefficients, log10(Luminance_value));
                end
            end
        end
    end
end
