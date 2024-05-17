classdef Area_FRR_2_VRR_dataset_Luminance
    properties
        coefficients_2d_surface
        coefficients_size_05
        coefficients_size_1
        coefficients_size_16
        coefficients_size_full
    end

    methods
        function obj = Area_FRR_2_VRR_dataset_Luminance()
            jsonFilePath_1 = 'E:\Py_codes\VRR_Real\Flicker_Matlab_3_2024_4_4/VRR_dataset_get_Luminance_2d.json';
            jsonData_1 = jsondecode(fileread(jsonFilePath_1));
            obj.coefficients_2d_surface = jsonData_1.coefficients_3d;
            jsonFilePath_2 = 'E:\Py_codes\VRR_Real\Flicker_Matlab_3_2024_4_4/VRR_dataset_get_Luminance_FRR.json';
            jsonData_2 = jsondecode(fileread(jsonFilePath_2));
            obj.coefficients_size_05 = jsonData_2.size_05_4d;
            obj.coefficients_size_1 = jsonData_2.size_1_4d;
            obj.coefficients_size_16 = jsonData_2.size_16_4d;
            obj.coefficients_size_full = jsonData_2.size_full_4d;
        end

        function Luminance = AT2L(obj, Area, FRR)
            Luminance = 10.^max(polyvaln(obj.coefficients_2d_surface, [log10(Area), FRR]),log10(0.4738));
        end

        function Luminance = AT2L_FRR(obj, FRR, size_value)
            FRR = min(FRR,14.9);
            FRR = max(FRR,0.5);
            if size_value == 0.5
                Luminance = 10.^max(polyval(obj.coefficients_size_05, FRR),log10(0.4738));
            elseif size_value == 1
                Luminance = 10.^max(polyval(obj.coefficients_size_1, FRR),log10(0.4738));
            elseif size_value == 16
                Luminance = 10.^max(polyval(obj.coefficients_size_16, FRR),log10(0.4738));
            elseif size_value == -1
                Luminance = 10.^max(polyval(obj.coefficients_size_full, FRR),log10(0.4738));
            else
                error('WRONG SIZE VALUE !')
            end
        end

        % function Luminance = AT2L_Area(obj, Area, FRR)
        %     Luminance = 10.^max(polyvaln(obj.coefficients, [log10(Area), FRR]),log10(0.4738));
        % end
    end
end
