% This script pre_processes the data again, this is so that different
% filters can be applied
% decreasing eye components to be deleted at 60% instead of 80%
% and after this one can re-run the previous script to re-analyise the data.
clear variables
eeglab
%% Subject info for each script
% This defines the set of subjects
subject_list = {'12377' '12494' '12565' '12675'};
% Path to the parent folder, which contains the data folders for all subjects
home_path  = {'D:\IllusoryContours_sfari\'};
paradigm_name  = {'IC' };
figure_path = 'D:\ica_figures\';
binlist_location = 'C:\Users\douwe\OneDrive\Documents\Github\sfari-analysis-pipelines\src\';
components = num2cell(zeros(length(subject_list), 8)); %prealocationg space for speed
refchan = { }; %if you want to re-ref to a channel add the name of the channel here, if empty won't re-ref to any specific channel (for example {'EXG3' 'EXG4'} or {'Cz'})
epoch_time = [-100 500];
baseline_time = [-50 0];
n_bins=2;% enter here the number of bins in your binlist
%name_epoch= {'27hz_std' '40hz_std' '27hz_dev' '40hz_dev'};
%participant_info = string(zeros(length(subject_list), 3+n_bins)); %prealocationg space for speed
%% info needed for this script specific
%locations
eeglab_location = 'C:\Users\douwe\OneDrive\Documents\MATLAB\eeglab2021.1\'; %needed if using a 10-20
scripts_location = 'C:\Users\douwe\OneDrive\Documents\Github\EEG_to_ERP_pipeline_stats_R\testing\scripts\'; %needed if using 160channel data
% filter info
%downsample_to=256; % what is the sample rate you want to downsample to
lowpass_filter_hz=200; %45hz filter
highpass_filter_hz=1; %1hz filter
%loading bad channels

%% looping through all paradigms
for paradigm=1%1:length(home_path)
    %load([home_path{paradigm} paradigm_name{paradigm} '_participant_interpolation_info.mat'])
    % Loop through all subjects
    for s=1:length(subject_list)
        if paradigm==2 && strcmp(subject_list{s},'12666') %illusionary contours
            disp("skipping 12666")
            continue
        end
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        data_path  = [home_path{paradigm} subject_list{s} '\\'];
        % Load original dataset (created by previous script)
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        EEG = pop_loadset('filename', [subject_list{s} '.set'], 'filepath', data_path);
        EEG = eeg_checkset( EEG );
        %% filtering
        EEG.filter=table(lowpass_filter_hz,highpass_filter_hz); %adding it to subject EEG file
        EEG = pop_eegfiltnew(EEG, 'locutoff',highpass_filter_hz);
        EEG = eeg_checkset( EEG );
        EEG = pop_eegfiltnew(EEG, 'hicutoff',lowpass_filter_hz);
        EEG = eeg_checkset( EEG );
        %% channel location
        EEG=pop_chanedit(EEG, 'lookup',[eeglab_location 'plugins\dipfit\standard_BEM\elec\standard_1005.elc'],'eval','chans = pop_chancenter( chans, [],[]);'); %make sure you put here the location of this file for your computer and recenteres the head
        %% deleting bad channels
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_info_2.set'],'filepath', data_path);
        EEG = pop_select( EEG, 'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8'});
        EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_bad_chan.set'],'filepath', data_path);%save
    end
    
    for s=1:length(subject_list)
        if paradigm==2 && strcmp(subject_list{s},'12666') %illusionary contours
            disp("skipping 12666")
            continue
        end
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        data_path  = [home_path{paradigm} subject_list{s} '\\'];
        % Load original dataset (created by previous script)
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        EEG = pop_loadset('filename', [subject_list{s} '_exchn.set'], 'filepath', data_path);
        EEG = eeg_checkset( EEG );
        
        %% getting some basic info before pre-processing (avg ampl 3x, length in sec, channels
        EEG.info=table(mean(EEG.data(33,:)), mean(EEG.data(48,:)), mean(EEG.data(28,:)), EEG.xmax, {{EEG.chanlocs.labels}},  'VariableNames',{'Avg Ampl FPz', 'Avg Ampl Cz', 'Avg Ampl Iz', 'full amount of time in sec', 'channels'},'RowNames',{'Before pre-processing'}); %creating table with column names);
        EEG.subject = subject_list{s};
        %% Interpolation
        pca = EEG.nbchan-1; %the PCA part of the ICA needs stops the rank-deficiency
        EEG_inter = pop_loadset('filename', [subject_list{s} '_info.set'], 'filepath', data_path);%loading participant file with all channels
        EEG_inter = pop_select( EEG_inter,'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8' 'GSR1' 'GSR2' 'Erg1' 'Erg2' 'Resp' 'Plet' 'Temp'});
        labels_all = {EEG_inter.chanlocs.labels}.'; %stores all the labels in a new matrix
        labels_good = {EEG.chanlocs.labels}.'; %saves all the channels that are in the excom file
        disp(EEG.nbchan); %writes down how many channels are there
        EEG = pop_interp(EEG, EEG_inter.chanlocs, 'spherical');%interpolates the data
        EEG = eeg_checkset( EEG );
        disp(EEG.nbchan) %should print full amount of channels
        clear EEG_inter
        %% averages ref
        EEG = pop_reref( EEG, []);
        EEG = eeg_checkset( EEG );
        %% Independent Component Analysis
        EEG = eeg_checkset( EEG );
        EEG = pop_runica(EEG, 'extended',1,'interupt','on','pca',pca); %using runica function, with the PCA part
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_ica_3.set'],'filepath', data_path);
    end
    
    for s=1:length(subject_list)
        if paradigm==2 && strcmp(subject_list{s},'12666') %illusionary contours
            disp("skipping 12666")
            continue
        end
         fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        data_path  = [home_path{paradigm} subject_list{s} '\\'];
        EEG = pop_loadset('filename', [subject_list{s} '_ica_3.set'], 'filepath', data_path);
        %% get rid of line noise
        EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:64] ,'computepower',1,'linefreqs',60,'newversion',0,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',0,'sigtype','Channels','taperbandwidth',2,'tau',100,'verb',1,'winsize',4,'winstep',1);
        %% choosing and deleting bad components
        clear bad_components brain_ic muscle_ic eye_ic hearth_ic line_noise_ic channel_ic other_ic
        EEG = iclabel(EEG); %does ICLable function
        ICA_components = EEG.etc.ic_classification.ICLabel.classifications ; %creates a new matrix with ICA components
        %Only the eyecomponent will be deleted, thus only components 3 will be put into the 8 component
        ICA_components(:,8) = ICA_components(:,3); %row 1 = Brain row 2 = muscle row 3= eye row 4 = Heart Row 5 = Line Noise row 6 = channel noise row 7 = other, combining this makes sure that the component also gets deleted if its a combination of all.
        bad_components = find(ICA_components(:,8)>0.60 & ICA_components(:,1)<0.10); %if the new row is over 80% of the component and the component has less the 5% brain
        %Still labeling all the other components so they get saved in the end
        brain_ic = length(find(ICA_components(:,1)>0.80));
        muscle_ic = length(find(ICA_components(:,2)>0.80 & ICA_components(:,1)<0.05));
        eye_ic = length(find(ICA_components(:,3)>0.80 & ICA_components(:,1)<0.05));
        hearth_ic = length(find(ICA_components(:,4)>0.80 & ICA_components(:,1)<0.05));
        line_noise_ic = length(find(ICA_components(:,5)>0.80 & ICA_components(:,1)<0.05));
        channel_ic = length(find(ICA_components(:,6)>0.80 & ICA_components(:,1)<0.05));
        other_ic = length(find(ICA_components(:,7)>0.80 & ICA_components(:,1)<0.05));
        %Plotting all eye componentes and all remaining components
        if isempty(bad_components)~= 1 %script would stop if people lack bad components
            if ceil(sqrt(length(bad_components))) == 1
                pop_topoplot(EEG, 0, [bad_components bad_components] ,subject_list{s} ,0,'electrodes','on');
            else
                pop_topoplot(EEG, 0, [bad_components] ,subject_list{s},[ceil(sqrt(length(bad_components))) ceil(sqrt(length(bad_components)))] ,0,'electrodes','on');
            end
            title(subject_list{s});
            print([figure_path paradigm_name{paradigm} '_' subject_list{s} '_Bad_ICs_topos'], '-dpng' ,'-r300');
            EEG = pop_subcomp( EEG, [bad_components], 0); %excluding the bad components
            close all
        else %instead of only plotting bad components it will plot all components
            title(subject_list{s}); text( 0.2,0.5, 'there are no eye-components found')
            print([figure_path paradigm_name{paradigm} '_' subject_list{s} '_Bad_ICs_topos'], '-dpng' ,'-r300');
        end
        title(subject_list{s});
        pop_topoplot(EEG, 0, 1:size(EEG.icaweights,1) ,subject_list{s},[ceil(sqrt(size(EEG.icaweights,1))) ceil(sqrt(size(EEG.icaweights,1)))] ,0,'electrodes','on');
        print([figure_path paradigm_name{paradigm} '_' subject_list{s} '_remaining_ICs_topos'], '-dpng' ,'-r300');
        close all
        %putting both figures in 1 plot saving it, deleting the other 2.
        figure('units','normalized','outerposition',[0 0 1 1])
        if EEG.nbchan<65
            subplot(1,5,1);
        else
            subplot(1,10,1);
        end
        imshow([figure_path paradigm_name{paradigm} '_' subject_list{s} '_Bad_ICs_topos.png']);
        title('Deleted components')
        if EEG.nbchan<65
            subplot(1,5,2:5);
        else
            subplot(1,10,2:10);
        end
        imshow([figure_path paradigm_name{paradigm} '_' subject_list{s} '_remaining_ICs_topos.png']);
        title('Remaining components')
        print([figure_path paradigm_name{paradigm} '_' subject_list{s} '_ICs_topos'], '-dpng' ,'-r300');
        %deleting two original files
        delete([figure_path paradigm_name{paradigm} '_' subject_list{s} '_Bad_ICs_topos.png'])
        delete([figure_path paradigm_name{paradigm} '_' subject_list{s} '_remaining_ICs_topos.png'])
        close all
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_excom_3.set'],'filepath', data_path);%save
        %% epoching (need erplab plugin for this)
        EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
        EEG  = pop_binlister( EEG , 'BDF', [binlist_location '\binlist_ic.txt'], 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
        EEG = pop_epochbin( EEG , epoch_time,  baseline_time); %epoch size and baseline size
        %deleting bad epochs
        EEG= pop_artmwppth( EEG , 'Channel', 1:EEG.nbchan, 'Flag',  1, 'Threshold',  120, 'Twindow', epoch_time, 'Windowsize',  200, 'Windowstep',  200 );% to flag bad epochs
        percent_deleted = (length(nonzeros(EEG.reject.rejmanual))/(length(EEG.reject.rejmanual)))*100; %looks for the length of all the epochs that should be deleted / length of all epochs * 100
        EEG = pop_rejepoch( EEG, [EEG.reject.rejmanual] ,0);%this deletes the flaged epoches
        ERP = pop_averager( EEG , 'Criterion', 1, 'DSindex',1, 'ExcludeBoundary', 'on', 'SEM', 'on' ); % need this to see how many trials are left
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_epoched.set'],'filepath', data_path);%save
        subj_comps=[subject_list(s), num2cell(brain_ic), num2cell(muscle_ic), num2cell(eye_ic), num2cell(hearth_ic), num2cell(line_noise_ic), num2cell(channel_ic), num2cell(other_ic)];
        components(s,:)=[subj_comps];
        %this part saves all the bad channels + ID numbers
               lables_del = setdiff(labels_all,labels_good); %only stores the deleted channels
               All_bad_chan               = strjoin(lables_del); %puts them in one string rather than individual strings
               EEG.info.Deleted_channels  = All_bad_chan;
               ID                         = string(subject_list{s});%keeps all the IDs
               data_subj                  = [ID, All_bad_chan, percent_deleted, ERP.ntrials.accepted]; %combines IDs and Bad channels
               participant_info(s,:) = data_subj;
    end
    save([home_path{paradigm} 'components_4nd_time'], 'components');
    % save([home_path{paradigm} paradigm_name{paradigm} '_participant_interpolation_info_3nd_time'], 'participant_info');
    
end


