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
home_path  = 'D:\F.A.S.T. Response task\';
study_save = 'D:\F.A.S.T. Response task\study\';
%21 = 27hz std 22=27hz dev 11=40std 12 40hz dev
power_grouped = table2array(array2table(zeros(2,length(subject_list))));
trials_num_reduced=110;
max_pwelch_freq=20; %max freq plotted by Pwelch function
time_freq_frequencies_range = [1 40];%high and low freq for time/freq analysis
power_40=[];power_27=[];
concat_obj_upsdwn = [];concat_obj_nrm = [];
concat_face_upsdwn=[]; concat_face_nrm =[];
% highpass_filter_27hz=22;
% lowpass_filter_27hz=32;
% highpass_filter_40hz=35;
% lowpass_filter_40hz=45;
channels=[48 32 31 26 30 63 27 29 64];% Cz Cpz Pz Poz Oz
channel_name={'Cz' 'Cpz' 'Pz' 'Po3' 'Poz' 'Po4' 'O1' 'Oz' 'O2'};
grand_avg_log_obj_upsdwn=[];grand_avg_log_obj_nrm=[];grand_avg_log_face_upsdwn=[];grand_avg_log_face_nrm=[];
%Loop through all subjects
for i=1:length(channels) %pwelch on several channels, can probably be done easier but this works
    for s=1:length(subject_list) %all participants
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        data_path  = [home_path subject_list{s} '\\'];
        %% separating epochs and randomly selecting amount of trials
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        EEG = pop_loadset('filename', [subject_list{s} '_epoched.set'], 'filepath', data_path);
        EEG = pop_selectevent( EEG, 'type',{'B1(31)'},'deleteevents','off','deleteepochs','on','invertepochs','off');
        EEG = pop_select(EEG, 'trial', randsample(1:size(EEG.data,3), trials_num_reduced));
        EEG_object_norm=EEG;
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_object_norm.set'],'filepath', study_save);%save
        EEG = pop_loadset('filename', [subject_list{s} '_epoched.set'], 'filepath', data_path);
        EEG = pop_selectevent( EEG, 'type',{'B2(condition32)'},'deleteevents','off','deleteepochs','on','invertepochs','off');
        EEG = pop_select(EEG, 'trial', randsample(1:size(EEG.data,3), trials_num_reduced));
        EEG_object_upsidedown=EEG;
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_object_upsidedown.set'],'filepath', study_save);%save
        EEG = pop_loadset('filename', [subject_list{s} '_epoched.set'], 'filepath', data_path);
        EEG = pop_selectevent( EEG, 'type',{'B3(condition21)'},'deleteevents','off','deleteepochs','on','invertepochs','off');
        EEG = pop_select(EEG, 'trial', randsample(1:size(EEG.data,3), trials_num_reduced));
        EEG_face_norm=EEG;
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_face_norm.set'],'filepath', study_save);%save
        EEG = pop_loadset('filename', [subject_list{s} '_epoched.set'], 'filepath', data_path);
        EEG = pop_selectevent( EEG, 'type',{'B4(condition22)'},'deleteevents','off','deleteepochs','on','invertepochs','off');
        EEG = pop_select(EEG, 'trial', randsample(1:size(EEG.data,3), trials_num_reduced));
        EEG_face_upsidedown=EEG;
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_face_upsidedown.set'],'filepath', study_save);%save
        
        %% pwelch settings
        pwelch_epoch_start=27;%this is 0ms
        pwelch_epoch_end=78;%this is 500ms
        %     WINDOW = 460   ; %The size of the window, optimal is 8 segments with 50% overlap, which is what it will try to do if you leave it empty. (pwelch will cut data in segments and calculate on these indiv segments)
        %     NOVERLAP = [];% samples of overlap from section to section.  If NOVERLAP is omitted or specified as empty, it is set to obtain a 50% overlap, 50% is the normal way of doing this.
        Fs   = EEG_object_norm.srate; % sampling rate, amount of samples per unit time
        %     NFFT = EEG_27_std.pnts^2; %Number of DFT points, specified as a positive integer. For a real-valued input signal, x, the PSD estimate, pxx has length (nfft/2 + 1) if nfft is even, and (nfft + 1)/2 if nfft is odd. For a complex-valued input signal,x, the PSD estimate always has length nfft. If nfft is specified as empty, the default nfft is used. If nfft is greater than the segment length, the data is zero-padded. If nfft is less than the segment length, the segment is wrapped using datawrap to make the length equal to nfft.
        %     SPECTRUMTYPE = [];
        [power_obj_upsdwn(:,:),f] = plotPwelch(EEG_object_upsidedown.data(channels(i),pwelch_epoch_start:pwelch_epoch_end,:),[],[],max_pwelch_freq,Fs);
        [power_obj_norm(:,:),f] = plotPwelch(EEG_object_norm.data(channels(i),pwelch_epoch_start:pwelch_epoch_end,:),[],[],max_pwelch_freq,Fs);
        [power_face_upsdwn(:,:),f] = plotPwelch(EEG_face_upsidedown.data(channels(i),pwelch_epoch_start:pwelch_epoch_end,:),[],[],max_pwelch_freq,Fs);
        [power_face_norm(:,:),f] = plotPwelch(EEG_face_norm.data(channels(i),pwelch_epoch_start:pwelch_epoch_end,:),[],[],max_pwelch_freq,Fs);
        power_obj_upsdwn_log_all(:,:,s)=10*log10(power_obj_upsdwn);
        power_obj_nrm_log_all(:,:,s)=10*log10(power_obj_norm);
        power_face_upsdwn_log_all(:,:,s)=10*log10(power_face_upsdwn);
        power_face_nrm_log_all(:,:,s)=10*log10(power_face_norm);
        if i==1 %only need to do this 1x for each participant
            concat_obj_upsdwn = cat(3, concat_obj_upsdwn, EEG_object_upsidedown.data);%data for newtimef function (time freq)
            concat_obj_nrm = cat(3, concat_obj_nrm, EEG_object_norm.data); %data for newtimef function (time freq)
            concat_face_upsdwn = cat(3, concat_face_upsdwn, EEG_face_upsidedown.data);%data for newtimef function (time freq)
            concat_face_nrm = cat(3, concat_face_nrm, EEG_face_norm.data); %data for newtimef function (time freq)
        end
    end
    
    %% averaging the log of the power, so we can plot it
    grand_avg_log_obj_upsdwn_temp= mean(power_obj_upsdwn_log_all(:,:,:),3);
    grand_avg_log_obj_nrm_temp= mean(power_obj_nrm_log_all(:,:,:),3);
    grand_avg_log_face_upsdwn_temp= mean(power_face_upsdwn_log_all(:,:,:),3);
    grand_avg_log_face_nrm_temp= mean(power_face_nrm_log_all(:,:,:),3);
    
    grand_avg_log_obj_upsdwn=[grand_avg_log_obj_upsdwn;grand_avg_log_obj_upsdwn_temp];
    grand_avg_log_obj_nrm=[grand_avg_log_obj_nrm;grand_avg_log_obj_nrm_temp];
    grand_avg_log_face_upsdwn=[grand_avg_log_face_upsdwn;grand_avg_log_face_upsdwn_temp];
    grand_avg_log_face_nrm=[grand_avg_log_face_nrm;grand_avg_log_face_nrm_temp];
end


%% ploting like SB's but using pwelch as previously setup
figure();
tiledlayout(3,3);
for i=1:size(grand_avg_log_face_nrm,1)
    nexttile
    set(gcf, 'Position',  [100, 100, 400, 300])
    colors = [0 1 1];
    plot(f, grand_avg_log_face_nrm(i,:),'Color',colors,'LineWidth',2);
    hold on;
    colors = colors*0.55; %darker
    plot(f, grand_avg_log_face_upsdwn(i,:),'Color',colors,'LineWidth',2);
    hold on;
    colors = [0.5883    0.5229    0.7612];
    plot(f, grand_avg_log_obj_nrm(i,:),'Color',colors,'LineWidth',2);
    hold on;
    colors = colors*0.55; %darker
    plot(f, grand_avg_log_obj_upsdwn(i,:),'Color',colors,'LineWidth',2);
    hold on;
    title(channel_name{i});
    xlabel('Frequency (Hz)')
    ylabel('Magnitude (dB)')
    
    set(gca,'fontsize', 16);
end



set(gcf, 'Position',  [100, 100, 2000, 2000])
leg = legend('Face normal', 'Face up-side-down', 'Object normal', 'Object up-side-down', 'Orientation','horizontal');
leg.Layout.Tile = 'south';
print([home_path 'Pwelch_fast'], '-dpng' ,'-r300');
close all
%% time frequency analysis
figure();[ersp,itc,powbaseCommon,times,freqs,erspboot,itcboot, tfdata] =  newtimef(concat_obj_upsdwn(29,:,:) ,...
    EEG_object_upsidedown.pnts,...%frames (uses the total amount of sample points in the data
    [EEG_object_upsidedown.xmin EEG_object_upsidedown.xmax]*1000,... %using the epoch times of the data *1000 to go from s to ms
    EEG_object_upsidedown.srate,... %finds the sampling rate in the data
    0,... % if 0,use FFTs and Hanning window tapering see "varwin" in the newtimef help file
    'freqs', time_freq_frequencies_range,...
    'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
    'commonbase', 'on',... %this is default, not sure how/why to set the baseline
    'mcorrect', 'fdr',... %correcting for multiple comparisons
    'pcontour', 'off',... % puts a contour around the plot for what is significant
    'title', '110 trials object up-side-down oz');%
set(gcf, 'Position',  [100, 100, 2000, 2000])
print([home_path 'ERSP_obj_upsdwn_oz'], '-dpng' ,'-r300');
close all


figure();[ersp,itc,powbaseCommon,times,freqs,erspboot,itcboot, tfdata] =  newtimef(concat_obj_nrm(29,:,:) ,...
    EEG_object_norm.pnts,...%frames (uses the total amount of sample points in the data
    [EEG_object_norm.xmin EEG_object_norm.xmax]*1000,... %using the epoch times of the data *1000 to go from s to ms
    EEG_object_norm.srate,... %finds the sampling rate in the data
    0,... % if 0,use FFTs and Hanning window tapering see "varwin" in the newtimef help file
    'freqs', time_freq_frequencies_range,...
    'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
    'commonbase', 'on',... %this is default, not sure how/why to set the baseline
    'mcorrect', 'fdr',... %correcting for multiple comparisons
    'pcontour', 'off',... % puts a contour around the plot for what is significant
    'title', '110 trials objects normal oz');%
set(gcf, 'Position',  [100, 100, 2000, 2000])
print([home_path 'ERSP_obj_nrm_oz'], '-dpng' ,'-r300');
close

figure();[ersp,itc,powbaseCommon,times,freqs,erspboot,itcboot, tfdata] =  newtimef(concat_face_upsdwn(29,:,:) ,...
    EEG_object_upsidedown.pnts,...%frames (uses the total amount of sample points in the data
    [EEG_object_upsidedown.xmin EEG_object_upsidedown.xmax]*1000,... %using the epoch times of the data *1000 to go from s to ms
    EEG_object_upsidedown.srate,... %finds the sampling rate in the data
    0,... % if 0,use FFTs and Hanning window tapering see "varwin" in the newtimef help file
    'freqs', time_freq_frequencies_range,...
    'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
    'commonbase', 'on',... %this is default, not sure how/why to set the baseline
    'mcorrect', 'fdr',... %correcting for multiple comparisons
    'pcontour', 'off',... % puts a contour around the plot for what is significant
    'title', '110 trials face up-side-down oz');%
set(gcf, 'Position',  [100, 100, 2000, 2000])
print([home_path 'ERSP_face_upsdwn_oz'], '-dpng' ,'-r300');
close all

figure();[ersp,itc,powbaseCommon,times,freqs,erspboot,itcboot, tfdata] =  newtimef(concat_face_nrm(29,:,:) ,...
    EEG_object_norm.pnts,...%frames (uses the total amount of sample points in the data
    [EEG_object_norm.xmin EEG_object_norm.xmax]*1000,... %using the epoch times of the data *1000 to go from s to ms
    EEG_object_norm.srate,... %finds the sampling rate in the data
    0,... % if 0,use FFTs and Hanning window tapering see "varwin" in the newtimef help file
    'freqs', time_freq_frequencies_range,...
    'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
    'commonbase', 'on',... %this is default, not sure how/why to set the baseline
    'mcorrect', 'fdr',... %correcting for multiple comparisons
    'pcontour', 'off',... % puts a contour around the plot for what is significant
    'title', '110 trials face normal oz');%
set(gcf, 'Position',  [100, 100, 2000, 2000])
print([home_path 'ERSP_face_nrm_oz'], '-dpng' ,'-r300');
close



%% comparing ERSP - not able to do correcting for multiple comparisons

[ersp,itc,powbase,times,freqs,erspboot,itcboot] = ...
    newtimef({concat_face_nrm(29,:,:) concat_face_upsdwn(29,:,:)},...
    EEG_object_norm.pnts,...%frames (uses the total amount of sample points in the data
    [EEG_object_norm.xmin EEG_object_norm.xmax]*1000,... %using the epoch times of the data *1000 to go from s to ms
    EEG_object_norm.srate,... %finds the sampling rate in the data
    0,... % if 0,use FFTs and Hanning window tapering see "varwin" in the newtimef help file
    'freqs', time_freq_frequencies_range,...
    'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
    'commonbase', 'on',... %this is default, not sure how/why to set the baseline
    'title', {'110 trials face normal oz', '110 trials face upsidedown oz', '110 trials face difference oz'});%
set(gcf, 'Position',  [100, 100, 2000, 2000])
print([home_path 'ERSP_face_oz'], '-dpng' ,'-r300');
close

[ersp,itc,powbase,times,freqs,erspboot,itcboot] = ...
    newtimef({concat_obj_nrm(29,:,:) concat_obj_upsdwn(29,:,:)},...
    EEG_object_norm.pnts,...%frames (uses the total amount of sample points in the data
    [EEG_object_norm.xmin EEG_object_norm.xmax]*1000,... %using the epoch times of the data *1000 to go from s to ms
    EEG_object_norm.srate,... %finds the sampling rate in the data
    0,... % if 0,use FFTs and Hanning window tapering see "varwin" in the newtimef help file
    'freqs', time_freq_frequencies_range,...
    'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
    'commonbase', 'on',... %this is default, not sure how/why to set the baseline
    'title', {'110 trials obj normal oz', '110 trials obj upsidedown oz', '110 trials obj difference oz'});%
set(gcf, 'Position',  [100, 100, 2000, 2000])
print([home_path 'ERSP_obj_oz'], '-dpng' ,'-r300');
close

[ersp,itc,powbase,times,freqs,erspboot,itcboot] = ...
    newtimef({concat_face_nrm(29,:,:) concat_obj_nrm(29,:,:)},...
    EEG_object_norm.pnts,...%frames (uses the total amount of sample points in the data
    [EEG_object_norm.xmin EEG_object_norm.xmax]*1000,... %using the epoch times of the data *1000 to go from s to ms
    EEG_object_norm.srate,... %finds the sampling rate in the data
    0,... % if 0,use FFTs and Hanning window tapering see "varwin" in the newtimef help file
    'freqs', time_freq_frequencies_range,...
    'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
    'commonbase', 'on',... %this is default, not sure how/why to set the baseline
    'title', {'110 trials face normal oz', '110 trials obj normal oz', '110 trials difference oz'});%
set(gcf, 'Position',  [100, 100, 2000, 2000])
print([home_path 'ERSP_face_obj_oz'], '-dpng' ,'-r300');
close
%% building a study
eeglab
for s=1:length(subject_list)
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    data_path  = [home_path subject_list{s} '\\'];
    %     %% Re-filtering
    %     fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    %     EEG = pop_loadset('filename', [subject_list{s} '_27_std.set'], 'filepath', data_path);
    %     EEG = pop_eegfiltnew(EEG, 'locutoff',highpass_filter_27hz,'plotfreqz',1);
    %     EEG = pop_eegfiltnew(EEG, 'hicutoff',lowpass_filter_27hz,'plotfreqz',1);
    %     EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_27_std_erp.set'],'filepath', study_save);%save
    %     EEG = pop_loadset('filename', [subject_list{s} '_40_std.set'], 'filepath', data_path);
    %     EEG = pop_eegfiltnew(EEG, 'locutoff',highpass_filter_40hz,'plotfreqz',1);
    %     EEG = pop_eegfiltnew(EEG, 'hicutoff',lowpass_filter_40hz,'plotfreqz',1);
    %     EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_40_std_erp.set'],'filepath', study_save);%save
    
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
    EEG.condition = dataName(7:end); % 21_std
    
    % Store the current EEG to ALLEEG.
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
end
[STUDY ALLEEG] = std_editset( STUDY, ALLEEG, 'name','FAST','updatedat','on','rmclust','off' );
[STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
eeglab redraw % This is to update EEGLAB GUI so that you can build STUDY from GUI menu.
[STUDY EEG] = pop_savestudy( STUDY, EEG, 'filename',study_name,'filepath',study_save);
[STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, {},'savetrials','on','interp','on','recompute','on','erp','on','erpparams',{'rmbase',[-50 0] });
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
    fig=openfig([home_path 'ERP_' channel_name{i} '.fig']);
    ax1 = gca;
    fig1 = get(ax1,'children'); %get handle to all the children in the figure
    copyobj(fig1,s1);%adding them together
    close 2%need to close the loaded figure or it will mess up the rest
end
leg = legend('Face normal', 'Face up-side-down', 'Object normal', 'Object up-side-down', 'Orientation','horizontal', 'Location', 'south');
