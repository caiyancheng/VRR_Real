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
% S_result_all: 4*8*4, %Observer_index, VRR_F, Size
log10_S_all_low_t = nanmean(nanmean(log10(S_result_all(:,1:4,:)),1),3);
log10_S_all_high_t = nanmean(nanmean(log10(S_result_all(:,5:8,:)),1),3);
log10_S_onlylow_t = nanmean(nanmean(log10(S_result_onlylow),1),3);
log10_S_onlyhigh_t = nanmean(nanmean(log10(S_result_onlyhigh),1),3);

log10_S_onlylow_deviation = log10_S_onlylow_t(:) - log10_S_all_low_t(:);
log10_S_onlyhigh_deviation = log10_S_onlyhigh_t(:) - log10_S_all_high_t(:);

[h,p,ci,stats] = ttest(log10_S_onlylow_deviation, log10_S_onlyhigh_deviation);
X = 1;
