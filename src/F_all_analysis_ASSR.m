% this script is created on 3/14/2022, by Douwe Horsthuis with help from Shlomit, Sophie, Olga and Filip
% create EEGLAB structures with only epochs of one type
% reduces the amount of trials to be the same for everyone (randomly choosing which to trials to delete)
% Shlomit's adaptation of the Pwelch function to plot the frequency spectrum
% newtimef to give a time/frequency analysis of the data (on concatenated data)
% creates a study to look at the ERPs

clear variables
eeglab
%% Subject info for each script
% This defines the set of subjects
subject_list = {'12377' '12494' '12565' '12666' '12675'};
% Path to the parent folder, which contains the data folders for all subjects
home_path  = 'G:\ASSR_oddball\';
study_save = 'G:\ASSR_oddball\study\';
%21 = 27hz std 22=27hz dev 11=40std 12 40hz dev
power_grouped = table2array(array2table(zeros(2,length(subject_list))));
trials_num_reduced=265;
max_pwelch_freq=50; %max freq plotted by Pwelch function
time_freq_frequencies_range = [20 60];%high and low freq for time/freq analysis
power_40=[];power_27=[];
concat_40 = [];concat_27 = [];
highpass_filter_27hz=22;
lowpass_filter_27hz=32;
highpass_filter_40hz=35;
lowpass_filter_40hz=45;

%Loop through all subjects
for s=1:length(subject_list)
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    data_path  = [home_path subject_list{s} '\\'];
    %% separating epochs
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_epoched.set'], 'filepath', data_path);
    EEG = pop_selectevent( EEG, 'type',{'B1(condition21)'},'deleteevents','off','deleteepochs','on','invertepochs','off');
    EEG = pop_select(EEG, 'trial', randsample(1:size(EEG.data,3), trials_num_reduced));
    EEG_27_std=EEG;
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_27_std.set'],'filepath', data_path);%save
    EEG = pop_loadset('filename', [subject_list{s} '_epoched.set'], 'filepath', data_path);
    EEG = pop_selectevent( EEG, 'type',{'B2(condition11)'},'deleteevents','off','deleteepochs','on','invertepochs','off');
    EEG = pop_select(EEG, 'trial', randsample(1:size(EEG.data,3), trials_num_reduced));
    EEG_40_std=EEG;
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_40_std.set'],'filepath', data_path);%save
    %  EEG = pop_loadset('filename', [subject_list{s} '_epoched.set'], 'filepath', data_path);
    %  EEG = pop_selectevent( EEG, 'type',{'B3(condition22)'},'deleteevents','off','deleteepochs','on','invertepochs','off');
    %  EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_27_dev.set'],'filepath', data_path);%save
    %   EEG = pop_loadset('filename', [subject_list{s} '_epoched.set'], 'filepath', data_path);
    %   EEG = pop_selectevent( EEG, 'type',{'B4(condition12)'},'deleteevents','off','deleteepochs','on','invertepochs','off');
    %   EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_40_dev.set'],'filepath', data_path);%save
    %% pwelch settings
    pwelch_epoch_start=52;%this is 0ms
    pwelch_epoch_end=308;%this is 500ms
    %     WINDOW = 460   ; %The size of the window, optimal is 8 segments with 50% overlap, which is what it will try to do if you leave it empty. (pwelch will cut data in segments and calculate on these indiv segments)
    %     NOVERLAP = [];% samples of overlap from section to section.  If NOVERLAP is omitted or specified as empty, it is set to obtain a 50% overlap, 50% is the normal way of doing this.
    Fs   = EEG_27_std.srate; % sampling rate, amount of samples per unit time
    %     NFFT = EEG_27_std.pnts^2; %Number of DFT points, specified as a positive integer. For a real-valued input signal, x, the PSD estimate, pxx has length (nfft/2 + 1) if nfft is even, and (nfft + 1)/2 if nfft is odd. For a complex-valued input signal,x, the PSD estimate always has length nfft. If nfft is specified as empty, the default nfft is used. If nfft is greater than the segment length, the data is zero-padded. If nfft is less than the segment length, the segment is wrapped using datawrap to make the length equal to nfft.
    %     SPECTRUMTYPE = [];
    %[power_40_std(:,:),f] = plotPwelch(EEG_40_std.data(48,pwelch_epoch_start:pwelch_epoch_end,:),[],[],max_pwelch_freq,Fs);
    %[power_27_std(:,:),f] = plotPwelch(EEG_27_std.data(48,pwelch_epoch_start:pwelch_epoch_end,:),[],[],max_pwelch_freq,Fs);
    %power_40_log_all(:,:,s)=10*log10(power_40_std);
    %power_27_log_all(:,:,s)=10*log10(power_27_std);
   % if i==1 %only need to do this 1x for each participant
        concat_40 = cat(3, concat_40, EEG_40_std.data);%data for newtimef function (time freq)
        concat_27 = cat(3, concat_27, EEG_27_std.data); %data for newtimef function (time freq)
        %         data{s}.data_40=EEG_40_std.data;
        %         data{s}.data_27=EEG_27_std.data;
        %         data{s}.id=subject_list{s};
        %         data{s}.fs=EEG.srate;
        %         data{s}.times=EEG.times;
        %         data{s}.chan=EEG.chanlocs;
%    end
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

print([home_path 'Pwelch_cz'], '-dpng' ,'-r300');
close all
%% tf
figure; [ersp,itc,powbaseCommon,times,freqs,erspboot,itcboot, tfdata] =newtimef( EEG, 1, 47, [-352  945], [3  13] , 'topovec', 47, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'FCz', 'baseline',[0], 'freqs', [20 60], 'plotphase', 'off', 'padratio', 1);

figure();[ersp,itc,powbaseCommon,times,freqs,erspboot,itcboot, tfdata] =  newtimef(EEG.data(48,:,:) ,...
    EEG.pnts,...%frames (uses the total amount of sample points in the data
    [EEG.xmin EEG.xmax]*1000,... %using the epoch times of the data *1000 to go from s to ms
    EEG.srate,... %finds the sampling rate in the data
    'cycles', [3 13],... % if 0,use FFTs and Hanning window tapering see "varwin" in the newtimef help file
    'freqs', time_freq_frequencies_range,...
    'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
    'commonbase', 'on',... %this is default, not sure how/why to set the baseline
    'mcorrect', 'fdr',... %correcting for multiple comparisons
    'pcontour', 'off',... % puts a contour around the plot for what is significant
    'ntimesout', 400,... % amount of datapoints 
    'title', 'Cz');%

print([home_path 'ERSP_40hz_cz'], '-dpng' ,'-r300');
close all

%% time frequency analysis
figure();[ersp,itc,powbaseCommon,times,freqs,erspboot,itcboot, tfdata] =  newtimef(concat_40(48,:,:) ,...
    EEG_40_std.pnts,...%frames (uses the total amount of sample points in the data
    [EEG_40_std.xmin EEG_40_std.xmax]*1000,... %using the epoch times of the data *1000 to go from s to ms
    EEG_40_std.srate,... %finds the sampling rate in the data
    'cycles', [3 0.5],... % if 0,use FFTs and Hanning window tapering see "varwin" in the newtimef help file
    'freqs', time_freq_frequencies_range,...
    'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
    'commonbase', 'on',... %this is default, not sure how/why to set the baseline
    'mcorrect', 'fdr',... %correcting for multiple comparisons
    'pcontour', 'off',... % puts a contour around the plot for what is significant
    'title', 'Wavelet 3 1');%

print([home_path 'ERSP_40hz_cz'], '-dpng' ,'-r300');
close all

figure();[ersp,itc,powbaseCommon,times,freqs,erspboot,itcboot, tfdata] =  newtimef(concat_27(48,:,:) ,...
    EEG_27_std.pnts,...%frames (uses the total amount of sample points in the data
    [EEG_27_std.xmin EEG_27_std.xmax]*1000,... %using the epoch times of the data *1000 to go from s to ms
    EEG_27_std.srate,... %finds the sampling rate in the data
    0,... % if 0,use FFTs and Hanning window tapering see "varwin" in the newtimef help file
    'freqs', time_freq_frequencies_range,...
    'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
    'commonbase', 'on',... %this is default, not sure how/why to set the baseline
    'mcorrect', 'fdr',... %correcting for multiple comparisons
    'pcontour', 'on',... % puts a contour around the plot for what is significant
    'title', '100 trials 27hz Cz');%

print([home_path 'ERSP_27hz_cz'], '-dpng' ,'-r300');
close all

%% building a study
for s=1:length(subject_list)
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    data_path  = [home_path subject_list{s} '\\'];
    %% Re-filtering
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_27_std.set'], 'filepath', data_path);
    EEG = pop_eegfiltnew(EEG, 'locutoff',highpass_filter_27hz,'plotfreqz',1);
    EEG = pop_eegfiltnew(EEG, 'hicutoff',lowpass_filter_27hz,'plotfreqz',1);
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_27_std_erp.set'],'filepath', study_save);%save
    EEG = pop_loadset('filename', [subject_list{s} '_40_std.set'], 'filepath', data_path);
    EEG = pop_eegfiltnew(EEG, 'locutoff',highpass_filter_40hz,'plotfreqz',1);
    EEG = pop_eegfiltnew(EEG, 'hicutoff',lowpass_filter_40hz,'plotfreqz',1);
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_40_std_erp.set'],'filepath', study_save);%save
    
end
% Obtain all .set file under /data/makoto/exampleProject/.
% In this example, suppose all set files have names like subj123_group2.set
allSetFiles = dir([study_save filesep '*.set']); % filesep inserts / or \ depending on your OS.
study_name = 'assr_std.study';
% Start the loop.
for setIdx = 1:length(allSetFiles)
    
    % Obtain the file names for loading.
    loadName = allSetFiles(setIdx).name; % subj123_group2.set
    dataName = loadName(1:end-4);        % subj123_group2
    
    % Load data. Note that 'loadmode', 'info' is to avoid loading .fdt file to save time and RAM.
    EEG = pop_loadset('filename', loadName, 'filepath', study_save, 'loadmode', 'info');
    
    % Enter EEG.subjuct.
    EEG.subject = dataName(1:5); % is the 5 numbers of the id 12000
    
    % Enter EEG.condition.
    EEG.condition = dataName(7:12); % 21_std
    
    % Store the current EEG to ALLEEG.
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
end
[STUDY ALLEEG] = std_editset( STUDY, ALLEEG, 'name','ASSR','updatedat','on','rmclust','off' );
[STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
eeglab redraw % This is to update EEGLAB GUI so that you can build STUDY from GUI menu.
[STUDY EEG] = pop_savestudy( STUDY, EEG, 'filename',study_name,'filepath',study_save);
[STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, {},'savetrials','on','interp','on','recompute','on','erp','on','erpparams',{'rmbase',[-100 0] });
STUDY = std_erpplot(STUDY,ALLEEG,'channels',{'Cz'}, 'design', 1);
print([home_path 'ERP_cz'], '-dpng' ,'-r300');
close all