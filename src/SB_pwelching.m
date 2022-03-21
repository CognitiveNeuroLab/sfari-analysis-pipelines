%clear variables
%eeglab
%% Subject info for each script
% This defines the set of subjects
subject_list = {'12377' '12494' '12565' '12666' '12675'};
% Path to the parent folder, which contains the data folders for all subjects
home_path  = 'D:\ASSR_oddball\';
study_save = 'D:\ASSR_oddball\study\';

trials_num_reduced=50; %input here the amount of trials we will use for everyone (270=lowerst n trials of all participant)
%power_40=[];power_27=[];
for s = 1:length(subject_list)
    clear power_40_std power_27_std
    % power_40_std= zeros(64,257); power_27_std= zeros(64,257);
    data_path  = [home_path subject_list{s} '\\'];
    %loading data (one stream)
    EEG_40_std = pop_loadset('filename',[subject_list{s} '_40_std.set'],'filepath', study_save );
    %reducing trials to be same between participants
    EEG_40_std = pop_select(EEG_40_std, 'trial', randsample(1:size(EEG_40_std.data,3), trials_num_reduced));
    %doing the same for the other stream
    EEG_27_std = pop_loadset('filename',[subject_list{s} '_27_std.set'],'filepath', study_save );
    EEG_27_std = pop_select(EEG_27_std, 'trial', randsample(1:size(EEG_27_std.data,3), trials_num_reduced));
    
    pwelch_epoch_start=52;%this is 0ms
    pwelch_epoch_end=308;%this is 500ms 
%     WINDOW = 460   ; %The size of the window, optimal is 8 segments with 50% overlap, which is what it will try to do if you leave it empty. (pwelch will cut data in segments and calculate on these indiv segments)
%     NOVERLAP = [];% samples of overlap from section to section.  If NOVERLAP is omitted or specified as empty, it is set to obtain a 50% overlap, 50% is the normal way of doing this.
     Fs   = EEG_27_std.srate; % sampling rate, amount of samples per unit time
%     NFFT = EEG_27_std.pnts^2; %Number of DFT points, specified as a positive integer. For a real-valued input signal, x, the PSD estimate, pxx has length (nfft/2 + 1) if nfft is even, and (nfft + 1)/2 if nfft is odd. For a complex-valued input signal,x, the PSD estimate always has length nfft. If nfft is specified as empty, the default nfft is used. If nfft is greater than the segment length, the data is zero-padded. If nfft is less than the segment length, the segment is wrapped using datawrap to make the length equal to nfft.
%     SPECTRUMTYPE = [];
    [power_40_std(:,:),f] = plotPwelch(EEG_40_std.data(48,pwelch_epoch_start:pwelch_epoch_end,:),[],[],50,Fs);
    [power_27_std(:,:),f] = plotPwelch(EEG_27_std.data(48,pwelch_epoch_start:pwelch_epoch_end,:),[],[],50,Fs);
    power_40_log_all(:,:,s)=10*log10(power_40_std);
    power_27_log_all(:,:,s)=10*log10(power_27_std);
end

%% averaging the log of the power, so we can plot it
grand_avg_log_40= mean(power_40_log_all(:,:,:),3);
grand_avg_log_27= mean(power_27_log_all(:,:,:),3);

%% ploting like SB's but using pwelch as previously setup
figure();

    colors = [0.5883    0.5229    0.7612];
    plot(f, grand_avg_log_40,'Color',colors,'LineWidth',2);
    hold on;
    colors = colors*0.5; %darker
    plot(f, grand_avg_log_27,'Color',colors,'LineWidth',2);

title('50 trials time-frequency conversion with Welch');
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
set(gca,'fontsize', 16);

 