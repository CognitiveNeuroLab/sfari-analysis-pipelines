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
home_path  = 'G:\Beep-Flash_sfari\';
%% info needed for this script specific
paradigm_name  = 'fast';
binlist_location = 'C:\Users\dohorsth\Documents\GitHub\sfari-analysis-pipelines\src\'; %needed if using 160channel data
epoch_time = [-500 2000];
baseline_time = [-50 0];
n_bins=2;% enter here the number of bins in your binlist
name_epoch= {'Auditory Cue' 'Visual Cue'};
participant_info_temp = string(zeros(length(subject_list), 1 +n_bins)); %prealocationg space for speed
%% Loop through all subjects
for s=1:length(subject_list)
    
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    clear data_subj
    % Path to the folder containing the current subject's data
    data_path  = [home_path subject_list{s} '\\'];
    
    % Load original dataset
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_reref.set'], 'filepath', data_path);
    % adding info to the .set file
    T_1=table(mean(EEG.data(33,:)), mean(EEG.data(48,:)), mean(EEG.data(28,:)), EEG.xmax, {{EEG.chanlocs.labels}},  'VariableNames',{'Avg Ampl FPz', 'Avg Ampl Cz', 'Avg Ampl Iz', 'full amount of time in sec', 'channels'},'RowNames',{'After pre-processing'});
    T_2=EEG.info;
    EEG.info = [T_2; T_1];
    %epoching
    EEG = eeg_checkset( EEG );
    
    %% epoching (need erplab plugin for this)
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
    EEG  = pop_binlister( EEG , 'BDF', [binlist_location '\binlist_fast.txt'], 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
    EEG = pop_epochbin( EEG , epoch_time,  baseline_time); %epoch size and baseline size
    %deleting bad epochs
    EEG= pop_artmwppth( EEG , 'Channel', 1:EEG.nbchan, 'Flag',  1, 'Threshold',  120, 'Twindow', epoch_time, 'Windowsize',  200, 'Windowstep',  200 );% to flag bad epochs
    percent_deleted = (length(nonzeros(EEG.reject.rejmanual))/(length(EEG.reject.rejmanual)))*100; %looks for the length of all the epochs that should be deleted / length of all epochs * 100
    EEG = pop_rejepoch( EEG, [EEG.reject.rejmanual] ,0);%this deletes the flaged epoches
    ERP = pop_averager( EEG , 'Criterion', 1, 'DSindex',1, 'ExcludeBoundary', 'on', 'SEM', 'on' ); % need this to see how many trials are left
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_epoched.set'],'filepath', data_path);%save
    
    ID                         = string(subject_list{s});
    data_subj                  = [percent_deleted, ERP.ntrials.accepted  ]; %ERP.ntrials.accepted  gives all the trials per bin
    participant_info_temp(s,:) = data_subj;
end
colNames                   = ['%data deleted', strcat('Amount of trials-',ERP.bindescr)]; %adding names for columns [ERP.bindescr] adds all the name of the bins
participant_info = array2table( participant_info_temp,'VariableNames',colNames); %creating table with column names
save([home_path paradigm_name '_participant_epoching_cleaning'], 'participant_info');