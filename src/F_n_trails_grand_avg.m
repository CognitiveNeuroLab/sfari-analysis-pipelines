% EEGLAB and ERPlab epoching script by Douwe Horsthuis on 3/3/2022
clear variables
eeglab

%% Subject info for each script
% This defines the set of subjects
subject_list = {'12377' '12494' '12565' '12666' '12675'};
% Path to the parent folder, which contains the data folders for all subjects
home_path  = 'D:\ASSR_oddball\';
n_bins=4;% enter here the number of bins in your binlist
name_epoch= {'27hz_std' '40hz_std' '27hz_dev' '40hz_dev'};
trials_num_reduced=[250, 250, 60, 60]; %input here the amount of trials for each bin
for bin_n=1:n_bins
    for s=1:length(subject_list)
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        clear data_subj
        % Path to the folder containing the current subject's data
        data_path  = [home_path subject_list{s} '\\'];
        % Load original dataset
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        EEG = pop_loadset('filename', [subject_list{s} '_epoched_' name_epoch{bin_n} '.set'], 'filepath', data_path);
        %retaining the amount of trials you want, by randomly choosing them out of total amount of trials
        EEG = pop_select(EEG, 'trial', randsample(1:size(EEG.data,3), trials_num_reduced(bin_n)));
        %creating ERPS and saving files
       % ERP = pop_averager( EEG , 'Criterion', 1, 'DSindex',1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_done_' name_epoch{bin_n} '.set'],'filepath', data_path);
       % ERP = pop_savemyerp(ERP, 'erpname', [subject_list{s} '_' name_epoch{bin_n} '.erp'], 'filename', [subject_list{s} '_' name_epoch{bin_n} '.erp'], 'filepath', data_path); %saving a.ERP file
        [ALLEEG, ~] = eeg_store(ALLEEG, EEG, CURRENTSET);
    end
end

%% creating a study 
study_name = 'ASSR';
for bin_n=1:n_bins
    for s=1:length(subject_list)
        file_p  = [home_path subject_list{s} '\' subject_list{s} '_done_' name_epoch{bin_n} '.set'];
        if s<10
            subj_n=strcat('s0', string(s));
        else
            subj_n= string(s);
        end
        binname=name_epoch{bin_n};
        study_text= [{file_p, 'subject', subj_n, 'condition', binname}]
    end
end
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
[STUDY ALLEEG] = std_editset( STUDY, ALLEEG, 'name','ASSR','updatedat','off','commands',{...
    {'index',4,'load','D:\\ASSR_oddball\\12377\\12377_done_27hz_std.set','subject','S01','condition','27hz std'},...
    {'index',8,'load','D:\\ASSR_oddball\\12494\\12494_done_27hz_std.set','subject','S02','condition','27hz std'},...
    {'index',12,'load','D:\\ASSR_oddball\\12565\\12565_done_27hz_std.set','subject','S03','condition','27hz std'},...
    {'index',16,'load','D:\\ASSR_oddball\\12666\\12666_done_27hz_std.set','subject','S04','condition','27hz std'},...
    {'index',20,'load','D:\\ASSR_oddball\\12675\\12675_done_27hz_std.set','subject','S05','condition','27hz std'},...
    {'index',5,'load','D:\\ASSR_oddball\\12377\\12377_done_27hz_dev.set','subject','S01','condition','27hz dev'},...
    {'index',9,'load','D:\\ASSR_oddball\\12494\\12494_done_27hz_dev.set','subject','S02','condition','27hz dev'},...
    {'index',13,'load','D:\\ASSR_oddball\\12565\\12565_done_27hz_dev.set','subject','S03','condition','27hz dev'},...
    {'index',17,'load','D:\\ASSR_oddball\\12666\\12666_done_27hz_dev.set','subject','S04','condition','27hz dev'},...
    {'index',21,'load','D:\\ASSR_oddball\\12675\\12675_done_27hz_dev.set','subject','S05','condition','27hz dev'},...
    {'index',6,'load','D:\\ASSR_oddball\\12377\\12377_done_40hz_std.set','subject','S01','condition','40hz std'},...
    {'index',10,'load','D:\\ASSR_oddball\\12494\\12494_done_40hz_std.set','subject','S02','condition','40hz std'},...
    {'index',14,'load','D:\\ASSR_oddball\\12565\\12565_done_40hz_std.set','subject','S03','condition','40hz std'},...
    {'index',18,'load','D:\\ASSR_oddball\\12666\\12666_done_40hz_std.set','subject','S04','condition','40hz std'},...
    {'index',22,'load','D:\\ASSR_oddball\\12675\\12675_done_40hz_std.set','subject','S05','condition','40hz std'},...
    {'index',7,'load','D:\\ASSR_oddball\\12377\\12377_done_40hz_dev.set','subject','S01','condition','40hz dev'},...
    {'index',11,'load','D:\\ASSR_oddball\\12494\\12494_done_40hz_dev.set','subject','S02','condition','40hz dev'},...
    {'index',15,'load','D:\\ASSR_oddball\\12565\\12565_done_40hz_dev.set','subject','S03','condition','40hz dev'},...
    {'index',19,'load','D:\\ASSR_oddball\\12666\\12666_done_40hz_dev.set','subject','S04','condition','40hz dev'},...
    {'index',23,'load','D:\\ASSR_oddball\\12675\\12675_done_40hz_dev.set','subject','S05','condition','40hz dev'}});
[STUDY ALLEEG] = std_precomp(STUDY, ALLEEG, 'channels', 'interpolate', 'on', 'recompute','on','erp','on');
tmpchanlocs = ALLEEG(1).chanlocs; STUDY = std_erpplot(STUDY, ALLEEG, 'channels', { tmpchanlocs.labels }, 'plotconditions', 'together');

CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
EEG = eeg_checkset( EEG );
[STUDY EEG] = pop_savestudy( STUDY, EEG, 'filename','ASSR.study','filepath','D:\\ASSR_oddball\\');
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];

%% erps
STUDY = std_erpplot(STUDY, ALLEEG, 'channels', {'Tp8'});

%% frequency

% Compute newtimef on first dataset for channel 1
options = {'freqscale', 'linear', 'freqs', [4 25], 'nfreqs', 20, 'ntimesout', 60, 'padratio', 1,'winsize',64,'baseline', 0};
TMPEEG = eeg_checkset(ALLEEG(2), 'loaddata');
figure; X = pop_newtimef( TMPEEG, 1, 1, [TMPEEG.xmin TMPEEG.xmax]*1000, [3 0.8] , 'topovec', 1, 'elocs', TMPEEG.chanlocs, 'chaninfo', TMPEEG.chaninfo, 'plotphase', 'off', options{:},'title',TMPEEG.setname, 'erspmax ',6.6);

[STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, 'components','savetrials','on','recompute','on','erp','on','spec','on','specparams',{'specmode','fft','logtrials','off'},'erpim','on','erpimparams',{'nlines',10,'smoothing',10},'ersp','on','erspparams',{'cycles',[3 0.8] ,'nfreqs',100,'ntimesout',200},'itc','on');
%% spectra
[STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, 'components','savetrials','on','recompute','on','erp','on','spec','on','specparams',{'specmode','fft','logtrials','off'},'erpim','on','erpimparams',{'nlines',10,'smoothing',10},'ersp','on','erspparams',{'cycles',[3 0.8] ,'nfreqs',100,'ntimesout',200},'itc','on');