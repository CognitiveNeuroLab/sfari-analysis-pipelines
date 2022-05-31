% this script is created on 3/14/2022, by Douwe Horsthuis with help from Shlomit, Sophie and Filip
% create EEGLAB structures with only epochs of one type
% reduces the amount of trials to be the same for everyone (randomly choosing which to trials to delete)
% Shlomit's adaptation of the Pwelch function to plot the frequency spectrum
% newtimef to give a time/frequency analysis of the data (on concatenated data)
% creates a study to look at the ERPs

clear variables
eeglab
%% Subject info for each script
% This defines the set of subjects
subject_list = {'12377' '12494' '12565' '12675'};
% Path to the parent folder, which contains the data folders for all subjects
home_path  = 'G:\IllusoryContours_sfari\';
study_save = 'G:\IllusoryContours_sfari\study\';
%21 = 27hz std 22=27hz dev 11=40std 12 40hz dev
power_grouped = table2array(array2table(zeros(2,length(subject_list))));
trials_num_reduced=240;
max_pwelch_freq=100; %max freq plotted by Pwelch function
time_freq_frequencies_range = [1 150];%high and low freq for time/freq analysis
IC = [];random = [];

% highpass_filter_27hz=22;
% lowpass_filter_27hz=32;
% highpass_filter_40hz=35;
% lowpass_filter_40hz=45;
channels=[48 32 31 26 30 63 27 29 64];% Cz Cpz Pz Poz Oz
channel_name={'Cz' 'Cpz' 'Pz' 'Po3' 'Poz' 'Po4' 'O1' 'Oz' 'O2'};
grand_avg_log_ic=[];grand_avg_log_rand=[];
study_name = 'IllusoryContours.study';
%Loop through all subjects
for i=1:length(channels) %pwelch on several channels, can probably be done easier but this works
    for s=1:length(subject_list) %all participants
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        data_path  = [home_path subject_list{s} '\\'];
        %% separating epochs and randomly selecting amount of trials
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        EEG = pop_loadset('filename', [subject_list{s} '_epoched.set'], 'filepath', data_path);
        EEG = pop_selectevent( EEG, 'type',{'B2(condition21)'},'deleteevents','off','deleteepochs','on','invertepochs','off');
        EEG = pop_select(EEG, 'trial', randsample(1:size(EEG.data,3), trials_num_reduced));
        EEG_IC=EEG;
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_ic.set'],'filepath', study_save);%save
        EEG = pop_loadset('filename', [subject_list{s} '_epoched.set'], 'filepath', data_path);
        EEG = pop_selectevent( EEG, 'type',{'B1(condition20)'},'deleteevents','off','deleteepochs','on','invertepochs','off');
        EEG = pop_select(EEG, 'trial', randsample(1:size(EEG.data,3), trials_num_reduced));
        EEG_random=EEG;
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_random.set'],'filepath', study_save);%save
        
        %% pwelch settings
        pwelch_epoch_start=52;%this is 0ms
        pwelch_epoch_end=307;%this is 498ms
        %     WINDOW = 460   ; %The size of the window, optimal is 8 segments with 50% overlap, which is what it will try to do if you leave it empty. (pwelch will cut data in segments and calculate on these indiv segments)
        %     NOVERLAP = [];% samples of overlap from section to section.  If NOVERLAP is omitted or specified as empty, it is set to obtain a 50% overlap, 50% is the normal way of doing this.
        Fs   = EEG_IC.srate; % sampling rate, amount of samples per unit time
        %     NFFT = EEG_27_std.pnts^2; %Number of DFT points, specified as a positive integer. For a real-valued input signal, x, the PSD estimate, pxx has length (nfft/2 + 1) if nfft is even, and (nfft + 1)/2 if nfft is odd. For a complex-valued input signal,x, the PSD estimate always has length nfft. If nfft is specified as empty, the default nfft is used. If nfft is greater than the segment length, the data is zero-padded. If nfft is less than the segment length, the segment is wrapped using datawrap to make the length equal to nfft.
        %     SPECTRUMTYPE = [];
        [power_random(:,:),f] = plotPwelch(EEG_random.data(channels(i),pwelch_epoch_start:pwelch_epoch_end,:),[],[],max_pwelch_freq,Fs);
        [power_IC(:,:),f] = plotPwelch(EEG_IC.data(channels(i),pwelch_epoch_start:pwelch_epoch_end,:),[],[],max_pwelch_freq,Fs);
        power_random_log_all(:,:,s)=10*log10(power_random);
        power_IC_log_all(:,:,s)=10*log10(power_IC);
        if i==1 %only need to do this 1x for each participant
            IC = cat(3, IC, EEG_IC.data);%data for newtimef function (time freq)
            random = cat(3, random, EEG_random.data); %data for newtimef function (time freq)
        end
    end
    
    %% averaging the log of the power, so we can plot it
    grand_avg_log_random_temp= mean(power_random_log_all(:,:,:),3);
    grand_avg_log_IC_temp= mean(power_IC_log_all(:,:,:),3);
    
    
    grand_avg_log_ic=[grand_avg_log_ic;grand_avg_log_IC_temp];
    grand_avg_log_rand=[grand_avg_log_rand;grand_avg_log_random_temp];
end


%% ploting like SB's but using pwelch as previously setup
figure();
tiledlayout(3,3);
for i=1:size(grand_avg_log_ic,1)
    nexttile
    set(gcf, 'Position',  [100, 100, 400, 300])
    colors = [0 1 1];
    plot(f, grand_avg_log_ic(i,:),'Color',colors,'LineWidth',2);
    hold on;
    colors = [0.5883    0.5229    0.7612];
    plot(f, grand_avg_log_rand(i,:),'Color',colors,'LineWidth',2);
    hold on;
    %     colors = [0.5883    0.5229    0.7612];
    %     plot(f, grand_avg_log_rand(i,:),'Color',colors,'LineWidth',2);
    %     hold on;
    %     colors = colors*0.55; %darker
    %     plot(f, grand_avg_log_ic(i,:),'Color',colors,'LineWidth',2);
    %     hold on;
    title(channel_name{i});
    xlabel('Frequency (Hz)')
    ylabel('Magnitude (dB)')
    leg = legend('IC', 'Random', 'Orientation','Vertical');
    set(gca,'fontsize', 16);
end



set(gcf, 'Position',  [100, 100, 2000, 2000])

print([home_path 'Pwelch_IC'], '-dpng' ,'-r300');
close all
%% time frequency analysis

for i=1:size(grand_avg_log_ic,1)%amount of channels
    figure();[ersp,itc,powbaseCommon,times,freqs,erspboot,itcboot, tfdata] =  newtimef(IC(channels(i),:,:) ,...
        EEG_random.pnts,...%frames (uses the total amount of sample points in the data
        [EEG_random.xmin EEG_random.xmax]*1000,... %using the epoch times of the data *1000 to go from s to ms
        EEG_random.srate,... %finds the sampling rate in the data
        0,... % if 0,use FFTs and Hanning window tapering see "varwin" in the newtimef help file
        'freqs', time_freq_frequencies_range,...
        'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
        'commonbase', 'on',... %this is default, not sure how/why to set the baseline
        'mcorrect', 'fdr',... %correcting for multiple comparisons
        'pcontour', 'off',... % puts a contour around the plot for what is significant
        'title', ['IC ' channel_name{i}]);%
    set(gcf, 'Position',  [100, 100, 2000, 2000])
    print([home_path 'ERSP_IC_' channel_name{i}], '-dpng' ,'-r300');
    close all
    
    
    figure();[ersp,itc,powbaseCommon,times,freqs,erspboot,itcboot, tfdata] =  newtimef(random(channels(i),:,:) ,...
        EEG_IC.pnts,...%frames (uses the total amount of sample points in the data
        [EEG_IC.xmin EEG_IC.xmax]*1000,... %using the epoch times of the data *1000 to go from s to ms
        EEG_IC.srate,... %finds the sampling rate in the data
        0,... % if 0,use FFTs and Hanning window tapering see "varwin" in the newtimef help file
        'freqs', time_freq_frequencies_range,...
        'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
        'commonbase', 'on',... %this is default, not sure how/why to set the baseline
        'mcorrect', 'fdr',... %correcting for multiple comparisons
        'pcontour', 'off',... % puts a contour around the plot for what is significant
        'title', ['Random ' channel_name{i}]);%
    set(gcf, 'Position',  [100, 100, 2000, 2000])
    print([home_path 'ERSP_random_' channel_name{i}], '-dpng' ,'-r300');
    close
    
    
    
    
    %% comparing ERSP - not able to do correcting for multiple comparisons
    
    [ersp,itc,powbase,times,freqs,erspboot,itcboot] = ...
        newtimef({IC(channels(i),:,:) random(channels(i),:,:)},...
        EEG_IC.pnts,...%frames (uses the total amount of sample points in the data
        [EEG_IC.xmin EEG_IC.xmax]*1000,... %using the epoch times of the data *1000 to go from s to ms
        EEG_IC.srate,... %finds the sampling rate in the data
        0,... % if 0,use FFTs and Hanning window tapering see "varwin" in the newtimef help file
        'freqs', time_freq_frequencies_range,...
        'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
        'commonbase', 'on',... %this is default, not sure how/why to set the baseline
        'title', {'IC', 'Random',[ 'Difference IC random ' channel_name{i}]});%
    set(gcf, 'Position',  [100, 100, 2000, 2000])
    print([home_path 'ERSP_IC_diff_' channel_name{i}], '-dpng' ,'-r300');
    close
end
%% building a study
eeglab
% %% extra filtering
% for s=1:length(subject_list)
%     fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
%     data_path  = [home_path subject_list{s} '\\'];
%         %% Re-filtering
%         fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
%         EEG = pop_loadset('filename', [subject_list{s} '_27_std.set'], 'filepath', data_path);
%         EEG = pop_eegfiltnew(EEG, 'locutoff',highpass_filter_27hz,'plotfreqz',1);
%         EEG = pop_eegfiltnew(EEG, 'hicutoff',lowpass_filter_27hz,'plotfreqz',1);
%         EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_27_std_erp.set'],'filepath', study_save);%save
%         EEG = pop_loadset('filename', [subject_list{s} '_40_std.set'], 'filepath', data_path);
%         EEG = pop_eegfiltnew(EEG, 'locutoff',highpass_filter_40hz,'plotfreqz',1);
%         EEG = pop_eegfiltnew(EEG, 'hicutoff',lowpass_filter_40hz,'plotfreqz',1);
%         EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_40_std_erp.set'],'filepath', study_save);%save
%
% end

%% Obtain all .set files.
allSetFiles = dir([study_save filesep '*.set']); % filesep inserts / or \ depending on your OS.

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
    EEG.condition = dataName(7:end); % 21_std
    
    % Store the current EEG to ALLEEG.
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
end
[STUDY ALLEEG] = std_editset( STUDY, ALLEEG, 'name','IC','updatedat','on','rmclust','off' );
[STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
eeglab redraw % This is to update EEGLAB GUI so that you can build STUDY from GUI menu.
[STUDY EEG] = pop_savestudy( STUDY, EEG, 'filename',study_name,'filepath',study_save);
[STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, {},'savetrials','on','interp','on','recompute','on','erp','on','erpparams',{'rmbase',[-50 0] });

%[STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, {},'savetrials','on','interp','on','recompute','on','ersp','on','erspparams',{'tlimits', [EEG_IC.xmin EEG_IC.xmax]*1000, 'cycles',0,'ntimesout',200, 'alpha', 0.05},'itc','on');
%'nfreqs',100

STUDY = pop_erpparams(STUDY, 'plotconditions','together');

for i=1:length(channel_name) %is the amount of channels we want
    STUDY = std_erpplot(STUDY,ALLEEG,'channels',{channel_name{i}}, 'design', 1);
    set(gcf, 'Position',  [100, 100, 2000, 2000])
    print([home_path 'ERP_' channel_name{i}], '-dpng' ,'-r300');
    savefig([home_path 'ERP_' channel_name{i}])
    close all
end
s1=figure('units','normalized','outerposition',[0 0 1 1]);
for i=1:length(channel_name)
    s1=subplot(3,3,i);
    title(channel_name{i})
    leg = legend('Orientation','Vertical', 'Location', 'Best');
    fig=openfig([home_path 'ERP_' channel_name{i} '.fig']);
    ax1 = gca;
    fig1 = get(ax1,'children'); %get handle to all the children in the figure
    copyobj(fig1,s1);%adding them together
    close 2%need to close the loaded figure or it will mess up the rest
end

