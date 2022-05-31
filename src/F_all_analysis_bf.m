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
subject_list = {'12377' '12494' '12565' '12666' '12675'};
% Path to the parent folder, which contains the data folders for all subjects
home_path  = 'G:\Beep-Flash_sfari\';
study_save = 'G:\Beep-Flash_sfari\study\';

power_grouped = table2array(array2table(zeros(2,length(subject_list))));
trials_num_reduced=187;
max_pwelch_freq=50; %max freq plotted by Pwelch function
time_freq_frequencies_range = [1 50];%high and low freq for time/freq analysis
vis = [];aud = [];vis_filt = [];aud_filt = [];
highpass_filter=20;
lowpass_filter=5;
% channels=[48 32 31 26 30 63 27 29 64];% Cz Cpz Pz Poz Oz
% channel_name={'Cz' 'Cpz' 'Pz' 'Po3' 'Poz' 'Po4' 'O1' 'Oz' 'O2'};
channels=[21 22 23 24 25 57 58 59 60 61];%numbers after re-ref to FPz (most just go up one spot)
channel_name={'P3' 'P5' 'P7' 'P9' 'Po7' 'P4' 'P6' 'P8' 'P10' 'Po8'};
grand_avg_log_vis=[];grand_avg_log_aud=[];
study_name = 'BeepFlash.study';

%Loop through all subjects
for i=1:length(channels) %pwelch on several channels, can probably be done easier but this works
    for s=1:length(subject_list) %all participants
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        data_path  = [home_path subject_list{s} '\\'];
        %% separating epochs and randomly selecting amount of trials
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        EEG = pop_loadset('filename', [subject_list{s} '_epoched.set'], 'filepath', data_path);
        EEG = pop_reref( EEG, 33);%re-ref to FPz because same as paper
        if strcmp(subject_list{s}, '12675')
            EEG = pop_selectevent( EEG, 'type',{'B2(condition15)'},'deleteevents','off','deleteepochs','on','invertepochs','off');
        else
            EEG = pop_selectevent( EEG, 'type',{'B2(condition17)'},'deleteevents','off','deleteepochs','on','invertepochs','off');
        end
        EEG = pop_select(EEG, 'trial', randsample(1:size(EEG.data,3), trials_num_reduced));
        EEG_Visual=EEG;
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_vis.set'],'filepath', study_save);%save
        EEG = pop_eegfiltnew(EEG, 'locutoff',5,'plotfreqz',1);
        EEG = pop_eegfiltnew(EEG, 'hicutoff',14,'plotfreqz',1);
        EEG_Visual_filt=EEG;
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_vis_filt.set'],'filepath', study_save);%save
        EEG = pop_loadset('filename', [subject_list{s} '_epoched.set'], 'filepath', data_path);
        EEG = pop_reref( EEG, 33);%re-ref to Fpz because same as paper
        EEG = pop_selectevent( EEG, 'type',{'B1(condition16)'},'deleteevents','off','deleteepochs','on','invertepochs','off');
        EEG = pop_select(EEG, 'trial', randsample(1:size(EEG.data,3), trials_num_reduced));
        EEG_Audio=EEG;
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_aud.set'],'filepath', study_save);%save
        EEG = pop_eegfiltnew(EEG, 'locutoff',5,'plotfreqz',1);
        EEG = pop_eegfiltnew(EEG, 'hicutoff',14,'plotfreqz',1);
        EEG_Audio_filt=EEG;
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_aud_filt.set'],'filepath', study_save);%save
        close all
        %% pwelch settings
        pwelch_epoch_start=129;%this is 0ms
        pwelch_epoch_end=257;%this is 498ms
        %     WINDOW = 460   ; %The size of the window, optimal is 8 segments with 50% overlap, which is what it will try to do if you leave it empty. (pwelch will cut data in segments and calculate on these indiv segments)
        %     NOVERLAP = [];% samples of overlap from section to section.  If NOVERLAP is omitted or specified as empty, it is set to obtain a 50% overlap, 50% is the normal way of doing this.
        Fs   = EEG_Visual.srate; % sampling rate, amount of samples per unit time
        %     NFFT = EEG_27_std.pnts^2; %Number of DFT points, specified as a positive integer. For a real-valued input signal, x, the PSD estimate, pxx has length (nfft/2 + 1) if nfft is even, and (nfft + 1)/2 if nfft is odd. For a complex-valued input signal,x, the PSD estimate always has length nfft. If nfft is specified as empty, the default nfft is used. If nfft is greater than the segment length, the data is zero-padded. If nfft is less than the segment length, the segment is wrapped using datawrap to make the length equal to nfft.
        %     SPECTRUMTYPE = [];
        [power_audio(:,:),f] = plotPwelch(EEG_Audio.data(channels(i),pwelch_epoch_start:pwelch_epoch_end,:),[],[],max_pwelch_freq,Fs);
        [power_visual(:,:),f] = plotPwelch(EEG_Visual.data(channels(i),pwelch_epoch_start:pwelch_epoch_end,:),[],[],max_pwelch_freq,Fs);
        power_audio_log_all(:,:,s)=10*log10(power_audio);
        power_visual_log_all(:,:,s)=10*log10(power_visual);
        if i==1 %only need to do this 1x for each participant
            vis = cat(3, vis, EEG_Visual.data);%data for newtimef function (time freq)
            aud = cat(3, aud, EEG_Audio.data); %data for newtimef function (time freq)
            vis_filt = cat(3, vis_filt, EEG_Visual_filt.data);%data for newtimef function (time freq)
            aud_filt = cat(3, aud_filt, EEG_Audio_filt.data); %data for newtimef function (time freq)
        end
    end
    
    %% averaging the log of the power, so we can plot it
    grand_avg_log_aud_temp= mean(power_audio_log_all(:,:,:),3);
    grand_avg_log_vis_temp= mean(power_visual_log_all(:,:,:),3);
    
    
    grand_avg_log_vis=[grand_avg_log_vis;grand_avg_log_vis_temp];
    grand_avg_log_aud=[grand_avg_log_aud;grand_avg_log_aud_temp];
end


%% ploting like SB's but using pwelch as previously setup
figure();
tiledlayout(ceil(length(channels)/2),ceil(length(channels)/2));
for i=1:size(grand_avg_log_vis,1)
    nexttile
    set(gcf, 'Position',  [100, 100, 400, 300])
    colors = [0 1 1];
    plot(f, grand_avg_log_vis(i,:),'Color',colors,'LineWidth',2);
    hold on;
    colors = [0.5883    0.5229    0.7612];
    plot(f, grand_avg_log_aud(i,:),'Color',colors,'LineWidth',2);
    hold on;
    title(channel_name{i});
    xlabel('Frequency (Hz)')
    ylabel('Magnitude (dB)')
    leg = legend('Visual Cue', 'Auditory Cue', 'Orientation','Vertical');
    set(gca,'fontsize', 16);
end

set(gcf, 'Position',  [100, 100, 2000, 2000])

print([home_path 'Pwelch_BF'], '-dpng' ,'-r300');
close all
%% time frequency analysis
for s=1:length(subject_list) %all participants
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    %% separating epochs and randomly selecting amount of trials
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_vis_filt.set'], 'filepath', study_save);
    EEG_Visual_filt=EEG;
    EEG = pop_loadset('filename', [subject_list{s} '_aud_filt.set'], 'filepath', study_save);
    EEG_Audio_filt=EEG;
    data_aud_chan=zeros(length(channel_name),37,200);
    data_vis_chan=zeros(length(channel_name),37,200);
    for i =1:length(channel_name)
        % figure();[ersp,itc,powbaseCommon,times,freqs,erspboot,itcboot, tfdata] =  newtimef({EEG_Audio_filt.data(channels(i),:,:) EEG_Visual_filt.data(channels(i),:,:)},...
        %     EEG.pnts,...%frames (uses the total amount of sample points in the data
        %     [EEG.xmin EEG.xmax]*1000,... %using the epoch times of the data *1000 to go from s to ms
        %     EEG.srate,... %finds the sampling rate in the data
        %     [3 7],... % 3 7 seems like a good suggestion, the wavelets should give a good balance between amount of cycles + is suggested by mike x cohen book
        %     'freqs', [4 40],... %we care for alpha 8-12hz so this should be enough
        %     'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
        %     'commonbase', 'on',... %this is default, not sure how/why to set the baseline
        %     'title', {'Audio', 'visual', 'audio - visual'} );%
        % % 'mcorrect', 'fdr',... %correcting for multiple comparisons not possible when comparing datasets
        % % 'pcontour', 'off',... % puts a contour around the plot for what is significant - very ugly
        clear ersp times freqs ;
        figure();[ersp,itc,powbaseCommon,times,freqs,erspboot,itcboot, tfdata] =  newtimef(EEG_Audio_filt.data(channels(i),:,:),...
            EEG.pnts,...%frames (uses the total amount of sample points in the data
            [EEG.xmin EEG.xmax]*1000,... %using the epoch times of the data *1000 to go from s to ms
            EEG.srate,... %finds the sampling rate in the data
            [3 7],... % 3 7 seems like a good suggestion, the wavelets should give a good balance between amount of cycles + is suggested by mike x cohen book
            'freqs', [4 40],... %we care for alpha 8-12hz so this should be enough
            'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
            'commonbase', 'on',... %this is default, not sure how/why to set the baseline
            'mcorrect', 'fdr',... %correcting for multiple comparisons not possible when comparing datasets
            'title', 'Audio' );%
        data_aud_chan(i,:,:)=ersp; %will contain all the data per person per channel
        close all; clear ersp times freqs ;
        
        figure();[ersp,itc,powbaseCommon,times,freqs,erspboot,itcboot, tfdata] =  newtimef(EEG_Visual_filt.data(channels(i),:,:),...
            EEG.pnts,...%frames (uses the total amount of sample points in the data
            [EEG.xmin EEG.xmax]*1000,... %using the epoch times of the data *1000 to go from s to ms
            EEG.srate,... %finds the sampling rate in the data
            [3 7],... % 3 7 seems like a good suggestion, the wavelets should give a good balance between amount of cycles + is suggested by mike x cohen book
            'freqs', [4 40],... %we care for alpha 8-12hz so this should be enough
            'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
            'commonbase', 'on',... %this is default, not sure how/why to set the baseline
            'mcorrect', 'fdr',... %correcting for multiple comparisons not possible when comparing datasets
            'title', 'Audio' );%
        data_vis_chan(i,:,:)=ersp; %will contain all the data per person per channel
        close all;
        
    end
    data_vis_indv=mean(data_vis_chan,1);
    data_aud_indv=mean(data_aud_chan,1);
end
data.aud=squeeze(mean(data_aud_indv,1)); %might have to add cell2mat, probably not.
data.vis=squeeze(mean(data_vis_indv,1));
data.subj.aud=data_aud_indv;
data.subj.vis=data_vis_indv;
data.id=subject_list;
data.freq=freqs;
data.times=times;
figure();
image(data.aud,'CDataMapping','scaled');
imagesc(data.times,data.freq,data.aud)  
colorbar;

%% building a study
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
[STUDY ALLEEG] = std_editset( STUDY, ALLEEG, 'name','BF','updatedat','on','rmclust','off' );
[STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
eeglab redraw % This is to update EEGLAB GUI so that you can build STUDY from GUI menu.
[STUDY EEG] = pop_savestudy( STUDY, EEG, 'filename',study_name,'filepath',study_save);
[STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, {},'savetrials','on','interp','on','recompute','on','erp','on','erpparams',{'rmbase',[-50 0] });

%[STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, {},'savetrials','on','interp','on','recompute','on','ersp','on','erspparams',{'tlimits', [EEG_Visual.xmin EEG_Visual.xmax]*1000, 'cycles',0,'ntimesout',200, 'alpha', 0.05},'itc','on');
[STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, {},'savetrials','on','interp','on','recompute','on','erp','on','erpparams',{'rmbase',[-50 0] },'spec','on','specparams',{'specmode','fft','logtrials','off'},'ersp','on','erspparams',{'cycles',0,'nfreqs',100,'ntimesout',200},'itc','on');

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
    s1=subplot(3,4,i);
    title(channel_name{i})
    %leg = legend('Orientation','Vertical', 'Location', 'Best');
    fig=openfig([home_path 'ERP_' channel_name{i} '.fig']);
    ax1 = gca;
    fig1 = get(ax1,'children'); %get handle to all the children in the figure
    copyobj(fig1,s1);%adding them together
    close all%need to close the loaded figure or it will mess up the rest
end

