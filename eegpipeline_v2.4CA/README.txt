Hello--before you use eegpipeline_v2.4CA.m, here are some orienting instructions:

Note that you will need to begin with a .mat file of each EEG you want,
created either using startEXAMPLE.m (you can use if starting with an .edf) 
OR otherwise generating the following variables (saved as '*'.mat where '*' is what you define 'file' below):
(1) eeg: your EEG data with each row being a channel and each column being sample
(2) ecg: your EKG data with one row and each column being a sample (check line 26 of startEXAMPLE.m)
(3) Fs: the sampling frequency in Hz (#samples per second)
(4) file: this can be the patient ID or other EEG ID that you want to use to open and manipulate that EEG file 

Before running the eegpipeline program with your .mat files:
(5) confirm that you are using EEG taken using a standard 10-20 system 
(or that you can convert your data to 10-20 in the rereference function)
(6) have more than one EEG to analyze 
(if you do not have more than one, load your .mat file, uncomment line 43 of the pipeline, & run just that section of the code)
(7) check that the channel index for the ecg in line 26 of startEXAMPLE.m was correct in identifying the EKG channels
(8) check that the channel labels/column numbers in lines 18-58 of the rereferenceEXAMPLE.m function are correct based on 
the info.label information found in your EEG after running startEXAMPLE.m (more information follows below)
(9) OUTPUT will be a file for each EEG labeled 'analysis' following the file name and containing 
an object called 'patient' which contains analyzed data including matrices of amplitude, power, correlation data, 
the sampling rate, channel labels, and the amount of time kept. 
These matrices in 'patient' will exist for both bipolar and laplacian montages. 
The file will also contain the raw eeg and ecg data with rejected segments cut out.
See code/bottom of this readme for information on the interpretation of the rows, columns, and depth of each matrix. 

More information on point 8 above:
When running this pipeline, you must be careful that your info.label data match the rereference function you are using:
- IF all of your EEGs have identical info.label data after they are imported in startEXAMPLE.m, you will: 
(1) compare lines 18-58 of the rereferenceEXAMPLE.m function against your info.label data 
and edit channel names/column numbers as needed
(2) run the pipeline, selecting  all of your .mat files and entering the default "rereferenceEXAMPLE" when prompted for source

- IF you have some EEGs with different rereference needs, 
(1) duplicate, rename, and edit lines 18-58 of the rereferenceEXAMPLE.m function,
making one new function for each different info.label data 'source'
(2) edit lines 36-37 of the pipeline to reflect all new rereference functions you may need 
(replace/duplicate "alternate_rereference" as needed)
(3) run the pipeline once for each 'source,' selecting only the .mat files corresponding to the rereference function you enter 
with each run

OUTPUT format information:
-----
% Amplitude Parameters Matrices (patient.bipolar_amp or patient.laplacian_amp):
% Row 1: Mean Amplitude
% Row 2: Stdev Amplitude
% Row 3: Skewness Amplitude
% Row 4: Kurtosis Amplitude 
% Row 5: Mean Absolute Value Amplitude

% Columns: Each column corresponds to a channel. These channels are specified
%when creating the montages.

% DEPTH. Each entry in the third dimension represents an individual
% segment of data that the code has deemed to be usable. With many 
% segments, we thus have distributions of the power values for each channel
% over the entire period of data collection. 
-----
% Power spectral-based calculations (patient.bipolar_power or patient.laplacian_power):
% ROWS. For all columns and depths, the rows can be interpreted as follows:
% Row 1 Delta Power;
% Row 2 Theta Power;
% Row 3 Alpha Power;
% Row 4 Beta Power;
% Row 5 1/f slope

% COLUMNS. Each column correponds to a channel. These channels are specified
% when creating the montage matrices

% DEPTH. Each entry in the third dimension represents an individual 
% segment of data that the code has deemed to be usable. With many
% segments, we thus have distributions of the power values for each channel
% over the entire period of data collection. 
-----
% Correlation and coherence matrix (patient.bipolar_corr or patient.laplacian_corr):
% ROWS:  
% Row 1: Spearman correlations R vs L; 
% Row 2: Spearman correlation ant vs post with Fp1; 
% Row 3: Spearman correlation ant vs post with F3 (can use to avoid eyeblink artifact); 
% Row 4: Spearman correlation frontal vs temporal;
% Row 5: coherence R vs L; 
% Row 6: coherence ant vs post with Fp1;
% Row 7: coherence ant vs post F3 (can use to avoid eyeblink artifact); 
% Row 8: coherence frontal vs temporal;
% COLUMNS: NOTE these are not channel based in this section, because the measures are derived from channels 
% Column 1: over all frequencies
% Column 2: over delta frequencies only
% Column 3: over theta frequencies only
% Column 4: over alpha frequencies only
% Column 5: over beta frequencies only
% DEPTH each 4s epoch averge correlation or coherence in the specified channels