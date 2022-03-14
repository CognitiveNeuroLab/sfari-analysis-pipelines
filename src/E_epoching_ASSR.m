% EEGLAB and ERPlab epoching script by Douwe Horsthuis on 6/21/2020
% This script epochs the data
% it deletes the noisy epochs.
% it creates ERPs
% It creates a matrix with how much data it deletes at the end.
% it can also record the RTs and put them in and excel, but it needs folder after the homepath called \All RT files\
clear variables
eeglab
%% Subject info for each script
% This defines the set of subjects
subject_list = {'12377' '12494' '12565' '12666' '12675'};
% Path to the parent folder, which contains the data folders for all subjects
home_path  = 'D:\ASSR_oddball\';
%% info needed for this script specific
paradigm_name  = 'ASSR';
%participant_info_temp = []; % needed for creating matrix at the end
binlist_location = 'C:\Users\douwe\OneDrive\Documents\Github\EEG_to_ERP_pipeline_stats_R\testing\scripts\'; %binlist should be named binlist.txt
epoch_time = [-100 800];
baseline_time = [-50 0];
n_bins=4;% enter here the number of bins in your binlist
name_epoch= {'27hz_std' '40hz_std' '27hz_dev' '40hz_dev'};
participant_info=[];
participant_info_temp = string(zeros(length(subject_list), 2)); %prealocationg space for speed
%% Loop through all subjects
for bin_n=1:n_bins
    for s=1:length(subject_list)
        
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        clear data_subj
        % Path to the folder containing the current subject's data
        data_path  = [home_path subject_list{s} '\\'];
        
        % Load original dataset
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        EEG = pop_loadset('filename', [subject_list{s} '_excom.set'], 'filepath', data_path);
        % adding info to the .set file
        T_1=table(mean(EEG.data(33,:)), mean(EEG.data(48,:)), mean(EEG.data(28,:)), EEG.xmax, {{EEG.chanlocs.labels}},  'VariableNames',{'Avg Ampl FPz', 'Avg Ampl Cz', 'Avg Ampl Iz', 'full amount of time in sec', 'channels'},'RowNames',{'After pre-processing'});
        T_2=EEG.info;
        EEG.info = [T_2; T_1];
        %epoching
        EEG = eeg_checkset( EEG );
        EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
        EEG = eeg_checkset( EEG );
        EEG  = pop_binlister( EEG , 'BDF', [binlist_location '\binlist_assr_' num2str(bin_n) '.txt'], 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
        EEG = eeg_checkset( EEG );
        EEG = pop_epochbin( EEG , epoch_time,  baseline_time); %epoch size and baseline size
        EEG = eeg_checkset( EEG );
        %deleting bad epochs (need erplab plugin for this)
        EEG= pop_artmwppth( EEG , 'Channel', 1:EEG.nbchan, 'Flag',  1, 'Threshold',  120, 'Twindow', epoch_time, 'Windowsize',  200, 'Windowstep',  200 );% to flag bad epochs
        percent_deleted = (length(nonzeros(EEG.reject.rejmanual))/(length(EEG.reject.rejmanual)))*100; %looks for the length of all the epochs that should be deleted / length of all epochs * 100
        EEG = pop_rejepoch( EEG, [EEG.reject.rejmanual] ,0);%this deletes the flaged epoches
        %creating ERPS and saving files
        ERP = pop_averager( EEG , 'Criterion', 1, 'DSindex',1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_epoched_' name_epoch{bin_n} '.set'],'filepath', data_path);
       % ERP = pop_savemyerp(ERP, 'erpname', [subject_list{s} '_' name_epoch{bin_n} '.erp'], 'filename', [subject_list{s} '.erp'], 'filepath', data_path); %saving a.ERP file
        %the following line creates an excel with RTs. For this to be possible make sure you have the right events in your eventlist.
        %values = pop_rt2text(ERP, 'eventlist',1, 'filename', [home_path '\All RT files\' subject_list{s} '_rt.xls'], 'header', 'on', 'listformat', 'basic' );
        
        ID                         = string(subject_list{s});
        data_subj                  = [percent_deleted, ERP.ntrials.accepted  ]; %ERP.ntrials.accepted  gives all the trials per bin
        participant_info_temp(s,:) = data_subj;
    end
    colNames                   = [strcat('%data deleted for-',ERP.bindescr), strcat('Amount of trials-',ERP.bindescr)]; %adding names for columns [ERP.bindescr] adds all the name of the bins
    participant_info_b = array2table( participant_info_temp,'VariableNames',colNames); %creating table with column names
    participant_info= [participant_info, participant_info_b]
end
%adding some final info to the table
total_deleted = str2double(participant_info{:,1:2:end}); participant_info.subject=subject_list';  participant_info.total_deleted = sum(total_deleted,2);
save([home_path paradigm_name '_participant_epoching_cleaning'], 'participant_info');