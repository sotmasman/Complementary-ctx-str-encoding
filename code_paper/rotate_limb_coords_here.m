% rotate the limb coordinates to align with nose-tail axis. It also applies
% filters to the data. 

fmin = 0.5;   %default = 1 Hz. filter lower frequency cutoff. for swing/stance peak/trough detection.
fmax = 8;   %default = 8 Hz. filter upper frequency cutoff. for swing/stance peak/trough detection.
% this_marker_pos = sgolayfilt(this_marker_pos, 3, 23);

lf_x = this_marker_pos(:,1);
lf_y = this_marker_pos(:,7);
rf_x = this_marker_pos(:,3);
rf_y = this_marker_pos(:,9);
lr_x = this_marker_pos(:,2);
lr_y = this_marker_pos(:,8);
rr_x = this_marker_pos(:,4);
rr_y = this_marker_pos(:,10);
n_x = this_marker_pos(:,5);
n_y = this_marker_pos(:,11);
t_x = this_marker_pos(:,6);
t_y = this_marker_pos(:,12);

nt_x = n_x - t_x;
nt_y = n_y - t_y; 
nt_angle = atan2(nt_x, nt_y);  %nose-tail angle. make sure to use the function atan2, not atan to avoid discontinuities in angle.
nt_angle_unwrap = unwrap(nt_angle);
rot_lf_x = lf_x.*cos(nt_angle) - lf_y.*sin(nt_angle); %rotate by nose-tail angle.
rot_lf_y = lf_x.*sin(nt_angle) + lf_y.*cos(nt_angle);
rot_rf_x = rf_x.*cos(nt_angle) - rf_y.*sin(nt_angle); %rotate by nose-tail angle.
rot_rf_y = rf_x.*sin(nt_angle) + rf_y.*cos(nt_angle);
rot_lr_x = lr_x.*cos(nt_angle) - lr_y.*sin(nt_angle); %rotate by nose-tail angle.
rot_lr_y = lr_x.*sin(nt_angle) + lr_y.*cos(nt_angle);
rot_rr_x = rr_x.*cos(nt_angle) - rr_y.*sin(nt_angle); %rotate by nose-tail angle.
rot_rr_y = rr_x.*sin(nt_angle) + rr_y.*cos(nt_angle);
rot_n_x = n_x.*cos(nt_angle) - n_y.*sin(nt_angle); %rotate by nose-tail angle.
rot_n_y = n_x.*sin(nt_angle) + n_y.*cos(nt_angle);
rot_t_x = t_x.*cos(nt_angle) - t_y.*sin(nt_angle); %rotate by nose-tail angle.
rot_t_y = t_x.*sin(nt_angle) + t_y.*cos(nt_angle);

%the rotated y position represents the forward-backward axis
%the rotated x position represents the left-right axis
nlf_x = rot_n_x - rot_lf_x;   %rotated position relative to nose.
nlf_y = rot_n_y - rot_lf_y;  
nrf_x = rot_n_x - rot_rf_x;   %rotated position relative to nose.
nrf_y = rot_n_y - rot_rf_y;  
nlr_x = rot_n_x - rot_lr_x;   %rotated position relative to nose.
nlr_y = rot_n_y - rot_lr_y;  
nrr_x = rot_n_x - rot_rr_x;   %rotated position relative to nose.
nrr_y = rot_n_y - rot_rr_y;  

%filters the coordinates relative to nose position.
[filt_nlf, time]=filter_data(nlf_y, framerate, 'bandpass', 3, fmin, fmax);
[filt_nlr, time]=filter_data(nlr_y, framerate, 'bandpass', 3, fmin, fmax);
[filt_nrf, time]=filter_data(nrf_y, framerate, 'bandpass', 3, fmin, fmax);
[filt_nrr, time]=filter_data(nrr_y, framerate, 'bandpass', 3, fmin, fmax);