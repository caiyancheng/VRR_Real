function [lms_bkg, lms_delta] = luminance_2_lms(luminance_list)
LMS_mean_scaler = [0.698134723317136, 0.301865276682864, 0.020656359494849];
LMS_delta_scaler = LMS_mean_scaler / norm(LMS_mean_scaler);
lms_bkg = zeros(1, length(luminance_list), 3);
lms_bkg(:,:,1) = luminance_list .* LMS_mean_scaler(1);
lms_bkg(:,:,2) = luminance_list .* LMS_mean_scaler(2);
lms_bkg(:,:,3) = luminance_list .* LMS_mean_scaler(3);
lms_delta = zeros(1, length(luminance_list), 3);
lms_delta(:,:,1) = ones(size(luminance_list)) .* LMS_delta_scaler(1);
lms_delta(:,:,2) = ones(size(luminance_list)) .* LMS_delta_scaler(2);
lms_delta(:,:,3) = ones(size(luminance_list)) .* LMS_delta_scaler(3);
end