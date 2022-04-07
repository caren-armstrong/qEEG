%% start reading data-- before using pipeline, edit, then use this to convert all of your .edf files to .mat files containing:
%file: the name of the .mat file you will create from this .edf
%eeg: a matrix with EEG data
%ecg: a vector with ECG data
%Fs: the sampling rate
%time: a vector in seconds that can be used for plotting your signals
%%
%read in file you want and deidentify, replacing the ID with the name you
%specify
file=input('patient ID filename in single quotes: ');
e='.edf';
e=append(file,e);
[info,eeg]=edfread(e);
clear e;
%%
%replace deidentified jibberish with coded name
info.patientID=file;
%determine/set sampling rate
Fs = info.frequency(1,1);

%cut off first minute to allow for impedence test etc. 
eeg(:, [1:(60*Fs)]) = [];
time=[1:length(eeg)]/Fs; %this makes a time vector in seconds rather than samples for plotting stuff

%define ecg-- look at info.label to check the columns used for ECG: 
ecg=(eeg(29,:)-eeg(30,:)); 

%% SAVE .mat
%save initial extracted and deidentified .mat file
save(file);
