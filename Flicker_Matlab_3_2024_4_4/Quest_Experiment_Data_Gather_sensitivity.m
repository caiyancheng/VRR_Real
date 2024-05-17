clear all;
clc;
Observer_list = {'Ale', 'Ali', 'Chuyao', 'Claire', 'Dounia', 'haoyu', 'Hongyun_Gao', 'Jane', 'Maliha', 'pupu', 'Shushan', 'Tianbo_Liang', 'Yancheng_Cai', 'Yaru', 'Yuan', 'Zhen'};
ff_dict = struct('vrr_f_12', 11.9, 'vrr_f_14', 13.3, 'vrr_f_16', 14.9);
degree_C2L = 7;
degree_L2C = 7;
CL_transform = Color2Luminance_LG_G1(degree_C2L, degree_L2C);
Sensitivity_transform = Luminance_VRR_2_Sensitivity();

for observer_index = 1:length(Observer_list)
    observer_name = Observer_list{observer_index};
    quest_exp_path = ['E:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_4_all\Observer_' observer_name '_2'];
    config_data = jsondecode(fileread(fullfile(quest_exp_path, 'config.json')));
    df = readtable(fullfile(quest_exp_path, 'reorder_result_D_thr.csv'));
    Quest_VRR_Fs = config_data.change_parameters.VRR_Frequency;
    Quest_Sizes = config_data.change_parameters.Size;

    S_result_csv = struct();
    S_result_csv.Size_Degree = {};
    S_result_csv.VRR_Frequency = {};
    S_result_csv.FRR = {};
    S_result_csv.Luminance = {};
    S_result_csv.Luminance_high = {};
    S_result_csv.Luminance_low = {};
    S_result_csv.Sensitivity = {};
    S_result_csv.Sensitivity_high = {};
    S_result_csv.Sensitivity_low = {};

    for vrr_f_index = 1:length(Quest_VRR_Fs)
        vrr_f_value = Quest_VRR_Fs(vrr_f_index);
        for size_index = 1:length(Quest_Sizes)
            size_value = Quest_Sizes{size_index};
            if ischar(size_value)
                filtered_df = df((isnan(df.Size_Degree)) & (df.VRR_Frequency == vrr_f_value), :);
            else
                filtered_df = df((df.Size_Degree == size_value) & (df.VRR_Frequency == vrr_f_value), :);
            end
            Color_value = filtered_df.threshold;
            Color_value_low = filtered_df.threshold_ci_low;
            Color_value_high = filtered_df.threshold_ci_high;
            if isnan(Color_value)
                disp('Invalid');
                continue;
            end
            if vrr_f_value > 10
                FRR = ff_dict.(['vrr_f_' num2str(vrr_f_value)]);
            else
                FRR = vrr_f_value;
            end
            if ~ischar(size_value)
                NEW_size_value = size_value;
                Luminance = CL_transform.C2L(Color_value);
                Luminance_high = max(CL_transform.C2L(Color_value_high),Luminance);
                Luminance_low = min(CL_transform.C2L(Color_value_low),Luminance);
            else
                NEW_size_value = -1; % -1 means full
                Luminance = CL_transform.C2L(Color_value, true);
                Luminance_high = max(CL_transform.C2L(Color_value_high, true),Luminance);
                Luminance_low = min(CL_transform.C2L(Color_value_low, true),Luminance);
            end
            S = Sensitivity_transform.LT2S(Luminance, FRR);
            if isnan(Luminance_low)
                S_low = NaN;
            else
                S_low = min(Sensitivity_transform.LT2S(Luminance_low, FRR),S);
            end
            if isnan(Luminance_high)
                S_high = NaN;
            else
                S_high = max(Sensitivity_transform.LT2S(Luminance_high, FRR),S);
            end
            
            S_result_csv.Size_Degree{end+1} = NEW_size_value;
            S_result_csv.VRR_Frequency{end+1} = vrr_f_value;
            S_result_csv.FRR{end+1} = FRR;
            S_result_csv.Luminance{end+1} = Luminance;
            S_result_csv.Luminance_high{end+1} = Luminance_high;
            S_result_csv.Luminance_low{end+1} = Luminance_low;
            S_result_csv.Sensitivity{end+1} = S;
            S_result_csv.Sensitivity_high{end+1} = S_high;
            S_result_csv.Sensitivity_low{end+1} = S_low;
        end
    end
    S_result_csv.Size_Degree = S_result_csv.Size_Degree';
    S_result_csv.VRR_Frequency = S_result_csv.VRR_Frequency';
    S_result_csv.FRR = S_result_csv.FRR';
    S_result_csv.Luminance = S_result_csv.Luminance';
    S_result_csv.Luminance_high = S_result_csv.Luminance_high';
    S_result_csv.Luminance_low = S_result_csv.Luminance_low';
    S_result_csv.Sensitivity = S_result_csv.Sensitivity';
    S_result_csv.Sensitivity_high = S_result_csv.Sensitivity_high';
    S_result_csv.Sensitivity_low = S_result_csv.Sensitivity_low';

    S_table = struct2table(S_result_csv);
    writetable(S_table, fullfile(quest_exp_path, 'matlab_reorder_result_D_thr_S.csv'));
end


