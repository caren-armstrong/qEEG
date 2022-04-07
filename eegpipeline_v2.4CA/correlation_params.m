function [output] = correlation_params(segmentsforcalc,Fs)
%{
    Title: Functional Connectivity in Scalp EEG

    Purpose: Examine connectivity of scalp EEG signals during resting stte.  
    
    Author: modified by Caren Armstrong 2021

   Inputs:
        - segmentsforcalc: Directory containing  cell array with each cell
        containing equal segments of EEG
        segments of EEG in which rows are channels and columns are samples
        - F: sampling frequency

    Outputs:
        - a matrix of spearman rank correlation coefficient rho from -1 to 1 with rows
        being L to R correlation; ant-post correlation with Fp1 leads; ant-post correlation 
        with F leads;and frontal-temporal correlations and columns being individual segments-- 
%Correlation and coherence matrix:
% ROWS:  
% Row 1: Spearman correlations L to R; 
% Row 2: Spearman correlation ant-post with Fp1; 
% Row 3: Spearman correlation ant-post with F3; 
% Row 4: Spearman correlation frontal-temporal;
% Row 5: coherence R to L; 
% Row 6: coherence ant-post with Fp1;
% Row 7: coherence ant-post F3; 
% Row 8: coherence frontal-temporal;
% COLUMNS: They are not channel based because the measures are derived from channels, 
% Column 1: over all frequencies
% Column 2: over delta frequencies only
% Column 3: over theta frequencies only
% Column 4: over alpha frequencies only
% Column 5: over beta frequencies only
% DEPTH each 4s epoch averge correlation or coherence in the specified
channels
%}
montage=cell2mat(segmentsforcalc(1));

if size(montage,1)==18;
    montage="bipolar";
else if size(montage,1)==19;
        montage="laplacian";
    else
        error('check montage')
    end
end

if montage=="bipolar"
    LRx=[1,2,3,4,9,10,11,12];
    LRy=[5,6,7,8,13,14,15,16];
    APFpx=[1,5];
    APFpy=[4,8];
    APFx=[9,13];
    APFy=[12,16];
    FTx=[1,5,9,13,17];
    FTy=[11,12,15,16];
else if montage=="laplacian"
    LRx=[1,2,3,4,5,6,7,8];
    LRy=[9,10,11,12,13,14,15,16];
    APFpx=[1,9];
    APFpy=[8,16];
    APFx=[2,10];
    APFy=[8,16];
    FTx=[1,2,9,10];
    FTy=[6,7,14,15];
    else
        error('check montage again');
    end
end

% 1 - 70 Hz bandpass filter
[bd,ad] = butter(2,[1 3.9]/(Fs/2),'bandpass');
[bt,at] = butter(2,[4 7.9]/(Fs/2),'bandpass');
[ba,aa] = butter(2,[8 12.9]/(Fs/2),'bandpass');
[bb,ab] = butter(2,[13 25]/(Fs/2),'bandpass');

deltafilt={};
thetafilt={};
alphafilt={};
betafilt={};

% filter at different frequencies prior to correlation
for j= 1:size(segmentsforcalc,2)
    temp=segmentsforcalc{1,j};
    for i = 1:size(temp,1)
    dfilt(:,i)=filtfilt(bd,ad,temp(i,:)');
    tfilt(:,i)=filtfilt(bt,at,temp(i,:)');
    afilt(:,i)=filtfilt(ba,aa,temp(i,:)');
    bfilt(:,i)=filtfilt(bb,ab,temp(i,:)');
    end
    deltafiltered{1,j} = dfilt';
    thetafiltered{1,j} = tfilt';
    alphafiltered{1,j} = afilt';
    betafiltered{1,j} = bfilt';
end
clear i j

correlation=[];
for i = 1:size(segmentsforcalc,2)
    allchannels = segmentsforcalc{i}';
    deltafilt = deltafiltered{i}';
    thetafilt = thetafiltered{i}';
    alphafilt = alphafiltered{i}';
    betafilt = betafiltered{i}';
    LRcorr=corr(allchannels(:,LRx),allchannels(:,LRy),'Type','Spearman');
    LRcorr=mean(abs(diag(LRcorr)));
    LRcorrd=corr(deltafilt(:,LRx),deltafilt(:,LRy),'Type','Spearman');
    LRcorrd=mean(abs(diag(LRcorrd)));
    LRcorrt=corr(thetafilt(:,LRx),thetafilt(:,LRy),'Type','Spearman');
    LRcorrt=mean(abs(diag(LRcorrt)));
    LRcorra=corr(alphafilt(:,LRx),alphafilt(:,LRy),'Type','Spearman');
    LRcorra=mean(abs(diag(LRcorra)));
    LRcorrb=corr(betafilt(:,LRx),betafilt(:,LRy),'Type','Spearman');
    LRcorrb=mean(abs(diag(LRcorrb)));
    APFpcorr=corr(allchannels(:,APFpx),allchannels(:,APFpy),'Type','Spearman');
    APFpcorr=mean(abs(diag(APFpcorr)));
    APFpcorrd=corr(deltafilt(:,APFpx),deltafilt(:,APFpy),'Type','Spearman');
    APFpcorrd=mean(abs(diag(APFpcorrd)));
    APFpcorrt=corr(thetafilt(:,APFpx),thetafilt(:,APFpy),'Type','Spearman');
    APFpcorrt=mean(abs(diag(APFpcorrt)));
    APFpcorra=corr(alphafilt(:,APFpx),alphafilt(:,APFpy),'Type','Spearman');
    APFpcorra=mean(abs(diag(APFpcorra)));
    APFpcorrb=corr(betafilt(:,APFpx),betafilt(:,APFpy),'Type','Spearman');
    APFpcorrb=mean(abs(diag(APFpcorrb)));
    APFcorr=corr(allchannels(:,APFx),allchannels(:,APFy),'Type','Spearman');
    APFcorr=mean(abs(diag(APFcorr))); 
    APFcorrd=corr(deltafilt(:,APFx),deltafilt(:,APFy),'Type','Spearman');
    APFcorrd=mean(abs(diag(APFcorrd)));
    APFcorrt=corr(thetafilt(:,APFx),thetafilt(:,APFy),'Type','Spearman');
    APFcorrt=mean(abs(diag(APFcorrt)));
    APFcorra=corr(alphafilt(:,APFx),alphafilt(:,APFy),'Type','Spearman');
    APFcorra=mean(abs(diag(APFcorra)));
    APFcorrb=corr(betafilt(:,APFx),betafilt(:,APFy),'Type','Spearman');
    APFcorrb=mean(abs(diag(APFcorrb)));
    FTcorr=corr(allchannels(:,FTx),allchannels(:,FTy),'Type','Spearman');
    FTcorr=mean(mean(abs(FTcorr))); 
    FTcorrd=corr(deltafilt(:,FTx),deltafilt(:,FTy),'Type','Spearman');
    FTcorrd=mean(abs(diag(FTcorrd)));
    FTcorrt=corr(thetafilt(:,FTx),thetafilt(:,FTy),'Type','Spearman');
    FTcorrt=mean(abs(diag(FTcorrt)));
    FTcorra=corr(alphafilt(:,FTx),alphafilt(:,FTy),'Type','Spearman');
    FTcorra=mean(abs(diag(FTcorra)));
    FTcorrb=corr(betafilt(:,FTx),betafilt(:,FTy),'Type','Spearman');
    FTcorrb=mean(abs(diag(FTcorrb)));
    correlation(1:4,1:5,i)=[LRcorr LRcorrd LRcorrt LRcorra LRcorrb;APFpcorr APFpcorrd...
        APFpcorrt APFpcorra APFpcorrb;APFcorr APFcorrd APFcorrt APFcorra APFcorrb;FTcorr...
        FTcorrd FTcorrt FTcorra FTcorrb];
end
   
coherence=[];
for j = 1:size(segmentsforcalc,2)
    allchannels = segmentsforcalc{j}';
    [LRcoh,W] = mscohere(allchannels(:,LRx),allchannels(:,LRy),Fs,[],[],Fs);
    %output here is the channels compared in columns and W is a frequency vector)
    % rows are 1 off from freq so row 1 is 0, row to 1Hz etc
    LRcohall = mean(mean(LRcoh));
    LRcohd = mean(mean(LRcoh(2:4,:)));
    LRcoht = mean(mean(LRcoh(5:8,:)));
    LRcoha = mean(mean(LRcoh(9:13,:)));
    LRcohb = mean(mean(LRcoh(14:26,:)));
    APFpcoh = mscohere(allchannels(:,APFpx),allchannels(:,APFpy),Fs,[],[],Fs);
    APFpcohall = mean(mean(APFpcoh));
    APFpcohd = mean(mean(APFpcoh(2:4,:)));
    APFpcoht = mean(mean(APFpcoh(5:8,:)));
    APFpcoha = mean(mean(APFpcoh(9:13,:)));
    APFpcohb = mean(mean(APFpcoh(14:26,:)));
    APFcoh = mscohere(allchannels(:,APFx),allchannels(:,APFy),Fs,[],[],Fs);
    APFcohall = mean(mean(APFcoh));
    APFcohd = mean(mean(APFcoh(2:4,:)));
    APFcoht = mean(mean(APFcoh(5:8,:)));
    APFcoha = mean(mean(APFcoh(9:13,:)));
    APFcohb = mean(mean(APFcoh(14:26,:)));
    FTcoh = mscohere(allchannels(:,FTx),allchannels(:,FTy),Fs,[],[],Fs);
    FTcohall = mean(mean(FTcoh));
    FTcohd = mean(mean(FTcoh(2:4,:)));
    FTcoht = mean(mean(FTcoh(5:8,:)));
    FTcoha = mean(mean(FTcoh(9:13,:)));
    FTcohb = mean(mean(FTcoh(14:26,:)));
    coherence(1:4,1:5,j)=[LRcohall LRcohd LRcoht LRcoha LRcohb;APFpcohall APFpcohd APFpcoht...
        APFpcoha APFpcohb; APFcohall APFcohd APFcoht APFcoha APFcohb; FTcohall FTcohd...
        FTcoht FTcoha FTcohb];
end
output=[correlation;coherence];

clear i j RLcorr RLcoh APFpcorr APFpcoh APFcorr APFcoh FTcorr FTcoh montage correlation coherence...
    LRx LRy APFpx APFpy APFx APFy FTx FTy
end
