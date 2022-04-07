% This file assumes you may have data from one or more sources, and you start by importing 
% all of the .mat files from a single source. 
% If you have only one file, go to line 42, uncomment line 43, and just run that section.
% You will run this pipeline once for each 'source', selecting all EEGs with
% the same info.label data and then entering the corresponding rereference file for
% your 'source' (check the rereference file you will use ("rereferenceEXAMPLE" is default) 
% against the info.label obtained after importing your EEGs in the startEXAMPLE step).
% Repeat this pipeline for each 'source' requiring a different rereference function
%%
% import the .mat files in the group
disp('Select the appropriate .mat files matching the rerefrence file you will use')

[files,path] = uigetfile('.mat','MultiSelect','on');

nofiles = size(files,2);

samples = table('Size',[nofiles 3], 'VariableTypes',{'string','double','double'},'VariableNames',{'file','start time','stop time'} );

%%
%import and make matrices of EEG data depending on the info.label for
%different EEG sources. You will need as many rereference functions as
%sources 
source=input('Enter source: eg: rereferenceEXAMPLE in "":');

for i = 1:nofiles
    all = load([path files{i}]);
    file = all.file;
    %filestr = convertCharsToStrings(file);
    Fs = all.Fs;
    eeg = all.eeg;
    ecg = all.ecg;
    % Rereference the data
% necessary inputs: eeg, Fs, ecg, file
if source=="rereferenceEXAMPLE"
    [bipolar_montage,bipolar_labels,laplacian_montage,laplacian_labels] = rereferenceEXAMPLE(eeg);
else if source=="alternate_rereference" %if needed, create & add other rereference functions and nest more else sections
        [bipolar_montage,bipolar_labels,laplacian_montage,laplacian_labels] = alternate_rereference(eeg);
%if needed, you can use this same code for multiple rereference files if not all files have the same order in info.label
    else error('check rereference');
    end
end
%% if you have only one .mat file, uncomment line 43 and just run this section instead of the whole file
% [bipolar_montage,bipolar_labels,laplacian_montage,laplacian_labels] = rereferenceEXAMPLE(eeg);
 
% Filter the data (<1Hz and >70Hz as well as notch)
[filted_bipolar,filted_laplacian,filted_ecg] = filtermyeeg(bipolar_montage,laplacian_montage,ecg,Fs);

% Extract good segments of data for calculations
rejection_bin_ins = 0.5; % size of rejection bin in s
calculation_bin_ins = 4; % size of calculation bin in s
amplitude_rejection = 500; % threshold of flat amplitude-based rejection (in uV)
z_set = 3; % standard deviation set for RMS/LL
features = 2; % number of features we are using to automatically reject, you could add more (2, RMS and LL)

[bipolar_segments_for_calcs,bipolar_storage] = rejection(filted_bipolar,...
       rejection_bin_ins,calculation_bin_ins,Fs,z_set,features,amplitude_rejection);
[laplacian_segments_for_calcs,laplacian_storage] = rejection(filted_laplacian,...
    rejection_bin_ins,calculation_bin_ins,Fs,z_set,features,amplitude_rejection);

% Quantitative EEG
% Amplitude-based calculations
%Amplitude Parameters Matrices:
%Row 1: Mean Amplitude
%Row 2: Stdev Amplitude
%Row 3: Skewness Amplitude
%Row 4: Kurtosis Amplitude 
%Row 5: Mean Absolute Value Amplitude

%Columns: Each column corresponds to a channel. These channels are specified
%when creating the montages.

%DEPTH. Each entry in the third dimension represents an individual
%segment of data that the code has deemed to be usable. With many 
%segments, we thus have distributions of the power values for each channel
%over the entire period of data collection. 
[bipolar_amp_calcs] = amplitude_params(bipolar_segments_for_calcs);
[laplacian_amp_calcs] = amplitude_params(laplacian_segments_for_calcs);

% Power spectral-based calculations
%ROWS. For all columns and depths, the rows can be interpreted as follows:
% Row 1 Delta Power;
% Row 2 Theta Power;
% Row 3 Alpha Power;
% Row 4 Beta Power;
% Row 5 1/f slope

%COLUMNS. Each column correponds to a channel. These channels are specified
%when creating the montage matrices

%DEPTH. Each entry in the third dimension represents an individual 
%segment of data that the code has deemed to be usable. With many
%segments, we thus have distributions of the power values for each channel
%over the entire period of data collection. 
[bipolar_power_calcs] = power_params(bipolar_segments_for_calcs,Fs);
[laplacian_power_calcs] = power_params(laplacian_segments_for_calcs,Fs);

%Correlation and coherence matrix:
% ROWS:  
% Row 1: Spearman correlations R vs L; 
% Row 2: Spearman correlation ant vs post with Fp1; 
% Row 3: Spearman correlation ant vs post with F3 (to avoid eyeblink artifact); 
% Row 4: Spearman correlation frontal vs temporal;
% Row 5: coherence R vs L; 
% Row 6: coherence ant vs post with Fp1;
% Row 7: coherence ant vs post F3 (to avoid eyeblink artifact); 
% Row 8: coherence frontal vs temporal;
% COLUMNS: They are not channel based in this section, because the measures are derived from channels, 
% Column 1: over all frequencies
% Column 2: over delta frequencies only
% Column 3: over theta frequencies only
% Column 4: over alpha frequencies only
% Column 5: over beta frequencies only
% DEPTH each 4s epoch averge correlation or coherence in the specified channels
[bipolar_corr_calcs] = correlation_params(bipolar_segments_for_calcs,Fs);
[laplacian_corr_calcs] = correlation_params(laplacian_segments_for_calcs,Fs);

% add time info to the saved file so you can see stats on how much of the
% file is kept bs discarded for each file
total_min_in_record = size(filted_bipolar,2)/(60*Fs);

total_min_kept_bipolar = size(bipolar_storage,1)*calculation_bin_ins/60;
total_min_reject_bipolar =  total_min_in_record - total_min_kept_bipolar;

total_min_kept_laplacian =  size(laplacian_storage,1)*calculation_bin_ins/60;
total_min_reject_laplacian =  total_min_in_record - total_min_kept_laplacian;

% Plotting-- turn section off if you do not wish to see the data plotted for each file 
data_offset = 300; % offset for each trace
label_offset = 200; % offset for each label
ecgscale = 0.1; % scale factor for the ECG trace
plot_goodandbad(filted_bipolar,bipolar_labels,bipolar_segments_for_calcs,...
    bipolar_storage,rejection_bin_ins,calculation_bin_ins,data_offset,label_offset,...
    filted_ecg,ecgscale,Fs)
plot_goodandbad(filted_laplacian,laplacian_labels,laplacian_segments_for_calcs,...
    laplacian_storage,rejection_bin_ins,calculation_bin_ins,data_offset,label_offset,...
    filted_ecg,ecgscale,Fs)


% Assembling all Quantitative EEG calculations into a saveable object
patient.bipolar_amp = bipolar_amp_calcs;
patient.bipolar_power = bipolar_power_calcs;
patient.laplacian_amp = laplacian_amp_calcs;
patient.laplacian_power = laplacian_power_calcs;
patient.storage_bipolar = bipolar_storage;
patient.storage_laplacian = laplacian_storage;
patient.bipolar_channels = bipolar_labels;
patient.laplacian_channels = laplacian_labels;
patient.bipolar_corr = bipolar_corr_calcs;
patient.laplacian_corr = laplacian_corr_calcs;
patient.Fs = Fs;
patient.total_min = total_min_in_record;
patient.total_min_bp = total_min_kept_bipolar;
patient.total_min_lap = total_min_kept_laplacian;
patient.ID=file;

%save all of this for a file named with patient ID followed by analysis
%containg the calculations, the raw EEG, the raw EKG, and the sampling rate
a='analysis';
file=append(file,a);
clear a e;
save(file,'patient', 'eeg', 'ecg', 'Fs');

    clearvars -except samples files nofiles path source
end