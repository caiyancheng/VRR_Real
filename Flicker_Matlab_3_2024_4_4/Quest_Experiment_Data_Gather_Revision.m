clear all;
clc;
Observer_list = {'Ale', 'Ali', 'Chuyao', 'Claire', 'Dounia', 'haoyu', 'Hongyun_Gao', 'Jane', 'Maliha', 'pupu', 'Shushan', 'Tianbo_Liang', 'Yancheng_Cai', 'Yaru', 'Yuan', 'Zhen'};
Observer_onlylow = {'Ale', 'Ali', 'Claire', 'Dounia', 'haoyu', 'Jane', 'Maliha', 'pupu', 'Yuan', 'Zhen'};
Observer_onlyhigh = {'Chuyao', 'Tianbo_Liang'};
Observer_all = {'Hongyun_Gao', 'Yancheng_Cai', 'Yaru', 'Shushan'};
F_all = [0.5,2,4,8,10,12,14,16];

ff_dict = struct('vrr_f_12', 11.9, 'vrr_f_14', 13.3, 'vrr_f_16', 14.9);
degree_C2L = 7;
degree_L2C = 7;
CL_transform = Color2Luminance_LG_G1(degree_C2L, degree_L2C);
Sensitivity_transform = Luminance_VRR_2_Sensitivity();

S_result_all = NaN(length(Observer_all), 8, 4); %Observer_index, VRR_F, Size
S_result_onlylow = NaN(length(Observer_onlylow), 4, 4);
S_result_onlyhigh = NaN(length(Observer_onlyhigh), 4, 4);

%第一遍循环先收集所有数据准备revision(注意revision仅仅针对onlyhigh)
for observer_index = 1:length(Observer_list)
    observer_name = Observer_list{observer_index};
    quest_exp_path = ['E:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_4_all\Observer_' observer_name '_2'];
    config_data = jsondecode(fileread(fullfile(quest_exp_path, 'config.json')));
    df = readtable(fullfile(quest_exp_path, 'reorder_result_D_thr.csv'));
    Quest_VRR_Fs = config_data.change_parameters.VRR_Frequency;
    Quest_Sizes = config_data.change_parameters.Size;

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

            Sensitivity = Sensitivity_transform.LT2S(Luminance, FRR);

            if ismember(observer_name, Observer_all)
                observer_find_index = find(strcmp(Observer_all, observer_name));
                f_find_index = find(F_all == vrr_f_value);
                S_result_all(observer_find_index, f_find_index, size_index) = Sensitivity;
            end
            if ismember(observer_name, Observer_onlylow)
                observer_find_index = find(strcmp(Observer_onlylow, observer_name));
                f_find_index = find(F_all(1:4) == vrr_f_value);
                S_result_onlylow(observer_find_index, f_find_index, size_index) = Sensitivity;
            end
            if ismember(observer_name, Observer_onlyhigh)
                observer_find_index = find(strcmp(Observer_onlyhigh, observer_name));
                f_find_index = find(F_all(5:8) == vrr_f_value);
                S_result_onlyhigh(observer_find_index, f_find_index, size_index) = Sensitivity;
            end
        end
    end
end

S_all_low_mean = nanmean(log10(S_result_all(:,1:4,:)), 'all');
S_all_high_mean = nanmean(log10(S_result_all(:,5:8,:)), 'all');
S_onlylow_mean = nanmean(log10(S_result_onlylow), 'all');
S_onlyhigh_mean = nanmean(log10(S_result_onlyhigh), 'all');

k_scaler = (S_onlylow_mean - S_all_low_mean + S_all_high_mean) / S_onlyhigh_mean;

%第二遍进行写入
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
            C_t = Contrast_transform.LT2C(log10(Luminance), FRR);
            if C_t == 0
                disp('Invalid');
                continue;
            end
            Sensitivity = 1 / C_t;
            if isnan(Luminance_high)
                S_low = NaN;
            else
                S_low = min(1 / Contrast_transform.LT2C(log10(Luminance_low), FRR), Sensitivity);
                if S_low == 0
                    S_low = NaN;
                end
            end
            if isnan(Luminance_low)
                S_high = NaN;
            else
                S_high = max(1 / Contrast_transform.LT2C(log10(Luminance_high), FRR), Sensitivity);
                if S_high == 0
                    S_high = NaN;
                end
            end

            S_result_csv.Size_Degree{end+1} = NEW_size_value;
            S_result_csv.VRR_Frequency{end+1} = vrr_f_value;
            S_result_csv.FRR{end+1} = FRR;
            S_result_csv.Luminance{end+1} = Luminance;
            S_result_csv.Luminance_high{end+1} = Luminance_high;
            S_result_csv.Luminance_low{end+1} = Luminance_low;
            S_result_csv.Sensitivity{end+1} = Sensitivity;
            S_result_csv.Sensitivity_high{end+1} = S_high;
            S_result_csv.Sensitivity_low{end+1} = S_low;

            if ismember(observer_name, Observer_all)
                observer_find_index = find(strcmp(Observer_all, observer_name));
                S_result_all(observer_find_index, vrr_f_index, size_index) = Sensitivity;
            end
            if ismember(observer_name, Observer_onlylow)
                observer_find_index = find(strcmp(Observer_onlylow, observer_name));
                S_result_onlylow(observer_find_index, vrr_f_index, size_index) = Sensitivity;
            end
            if ismember(observer_name, Observer_onlyhigh)
                observer_find_index = find(strcmp(Observer_all, observer_name));
                S_result_onlyhigh(observer_find_index, vrr_f_index, size_index) = Sensitivity;
            end
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
    writetable(S_table, fullfile(quest_exp_path, 'S_origin_result.csv'));
end


