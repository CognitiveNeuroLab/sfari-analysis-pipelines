% This script allows you to look at the behavioral data for the Beep-flash paradigm
% It first focuses on the UDTR level and how people preformed across blocks
% the last part focuses on the bdf file and looks more into false alarms
% all figures get printed, to change where update line 22 (save_path)
% to add more people, add ID numbers to group. 
% groups were defined during piloting, but can be updated always
% created on 4/13/2022 by Douwe Horsthuis

clear variables
close all
eeglab
%% Subject info for each script
% This defines the set of subjects
group='kid';%'only_bi' 'bi_and_uni' 'kid'


if strcmp(group, 'only_bi')
    subject_list = {'12354' '12377' '12494' '12565' '12666' '12675'};%people that did the first pilot with EEG data
elseif strcmp(group, 'bi_and_uni')
    subject_list = {'12354-second' '12675-second' '12666-second'};
elseif strcmp(group, 'kid')
    subject_list = {'10520' '10876'};
end
% Path to the parent folder, which contains the data folders for all subjects
home_path  ='G:\Beep-Flash_sfari\';
save_path  ='G:\Beep-Flash_sfari\behavioral figures\';

%% UDTR
figure(); 
if length(subject_list)==2
    tiledlayout(1,2)
else
    tiledlayout(ceil(length(subject_list)/2),ceil(length(subject_list)/2));
end
set(gcf, 'Position',  [100, 100, 2000, 2000])
for s=1:length(subject_list)
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    data_path  = [home_path subject_list{s} '\'];
    Auditory = importdata([data_path subject_list{s} '_Beep-Flash_UDTR_A_levels.txt']);
    Visual = importdata([data_path subject_list{s} '_Beep-Flash_UDTR_V_levels.txt']); %importing logfile
    maxaud=152; %max audio level, would be easiest level
    maxvis= 47; %max visual level, would be easiest level
    minboth=0;
    nexttile
    plot(Auditory, 'LineWidth',2, 'Color', 'b'); hold on;
    plot(Visual, 'LineWidth',2, 'Color', 'r'); hold on;
    yline(maxaud,':','Color', 'b', 'LineWidth',2)
    yline(maxvis, ':','Color', 'r', 'LineWidth',2)
    yline(minboth, '--','Color', 'k', 'LineWidth',2)
    ylim( [-10 160]);
    title([subject_list{s} ' ' group]);
    xlabel('Trial');
    ylabel('Stimulus level');
    set(gca,'fontsize', 16);
    legend('Auditory', 'Visual','Easiest Audio', 'Easiest Visual', 'hardest both', 'Orientation','horizontal', 'Location', 'northwest');
    hold on
end
print([save_path group '_UDTR_Results'], '-dpng' ,'-r300');
close all

clear Auditory Visual maxaud maxvis minboth
%% Main paradigm
close all
figure(); tiledlayout(ceil(length(subject_list)/2),4);
set(gcf, 'Position',  [100, 100, 2000, 2000]);

for s=1:length(subject_list)
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    data_path  = [home_path subject_list{s} '\'];
    folder=dir(data_path);
    aud_acc=[];vis_acc=[];
    for i=3:length(folder)
        if strcmp(folder(i).name(end-6:end), 'acc.txt')
            logfile= importdata([data_path folder(i).name]);
            aud_acc=[aud_acc;logfile.data(1)];
            vis_acc=[vis_acc;logfile.data(2)];
        end
    end
    
    nexttile ;
    boxplot([aud_acc, vis_acc],'Labels',{'Audio','Visual'});
    ylim( [0 110]);
    yticks(0:20:100);
    title([subject_list{s} ' accuracy']);
    nexttile ;
    plot(aud_acc,'LineWidth',2, 'color', 'b'); hold on
    plot(vis_acc,'LineWidth',2, 'Color', 'r'); hold on
    max=100;
    yline(max,':','Color', 'k')
    ylim( [0 110]);
    yticks(0:20:100);
    title([subject_list{s} ' ' group ' accuracy per block']);
    xlabel('Block');
    ylabel('Accuracy %');
    legend('Auditory', 'Visual', 'Max', 'Orientation','horizontal', 'Location', 'southeast');
end
print([save_path group '_behav_Results'], '-dpng' ,'-r300');
close all
%% Combined
for s=1:length(subject_list)
    figure(); tiledlayout(3,1);
    set(gcf, 'Position',  [100, 100, 800, 1000])
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    data_path  = [home_path subject_list{s} '\'];
    Auditory = importdata([data_path subject_list{s} '_Beep-Flash_UDTR_A_levels.txt']);
    Visual = importdata([data_path subject_list{s} '_Beep-Flash_UDTR_V_levels.txt']); %importing logfile
    maxaud=152;
    maxvis= 47;
    minboth=0;
    nexttile
    plot(Auditory, 'LineWidth',2, 'Color', 'b'); hold on;
    plot(Visual, 'LineWidth',2, 'Color', 'r'); hold on;
    yline(maxaud,':','Color', 'b', 'LineWidth',2)
    yline(maxvis, ':','Color', 'r', 'LineWidth',2)
    yline(minboth, '--','Color', 'k', 'LineWidth',2)
    ylim( [-10 160]);
    title([subject_list{s} ' UDTR']);
    xlabel('Trial');
    ylabel('Stimulus level');
    legend('Auditory', 'Visual','Easiest Audio', 'Easiest Visual', 'hardest both', 'Orientation','horizontal', 'Location', 'southoutside');
    hold on
    
    
    
    
    
    folder=dir(data_path);
    aud_acc=[];vis_acc=[];
    for i=3:length(folder)
        if strcmp(folder(i).name(end-6:end), 'acc.txt')
            logfile= importdata([data_path folder(i).name]);
            aud_acc=[aud_acc;logfile.data(1)];
            vis_acc=[vis_acc;logfile.data(2)];
        end
    end
    
    nexttile ;
    boxplot([aud_acc, vis_acc],'Labels',{'Audio','Visual'});
    ylim( [0 110]);
    yticks(0:20:100);
    title([subject_list{s} ' accuracy']);
    nexttile ;
    plot(aud_acc,'LineWidth',2, 'color', 'b'); hold on
    plot(vis_acc,'LineWidth',2, 'Color', 'r'); hold on
    max=100;
    yline(max,':','Color', 'k')
    ylim( [0 110]);
    yticks(0:20:100);
    title([subject_list{s} ' accuracy per block']);
    xlabel('Block');
    ylabel('Accuracy %');
    legend('Auditory', 'Visual', 'Max', 'Orientation','horizontal', 'Location', 'southeast');
    print([save_path subject_list{s} '_behav_Results_log'], '-dpng' ,'-r300');
    savefig([save_path subject_list{s} '_behav_Results_log'])
    close all
end

%% Looking at the EEG files instead of logfiles
binlist_location = 'C:\Users\dohorsth\Documents\GitHub\sfari-analysis-pipelines\src\';
epoch_time = [-200 3000];
baseline_time = [-50 0];
%participant_info_temp = zeros(length(subject_list), n_bins); %prealocationg space for speed
%% Loop through all subjects
for s=1:length(subject_list)
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    % Path to the folder containing the current subject's data
    data_path  = [home_path subject_list{s} '\\'];
    % Load original dataset
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_info.set'], 'filepath', data_path);
    %% epoching (need erplab plugin for this)
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
    EEG  = pop_binlister( EEG , 'BDF', [binlist_location '\binlist_bf_behv_2.txt'], 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
    EEG = pop_epochbin( EEG , epoch_time,  baseline_time); %epoch size and baseline size
    ERP = pop_averager( EEG , 'Criterion', 1, 'DSindex',1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
    
    figure();
    tiledlayout(1,2);
    nexttile
    maxcr=160;
    maxhit=40;
    % bar(participant_info_temp,'DisplayName','participant_info_temp')
    barp=bar(categorical(subject_list(s)),ERP.ntrials.accepted);
    yline(maxhit,':','Color', 'b', 'LineWidth',2)
    yline(maxcr, ':','Color', 'r', 'LineWidth',2)
    ylim( [0 165]);
    set(gca,'fontsize', 20);
    set(gcf, 'Position',  [100, 100, 1500, 1000])
    legend('Hit Audio', 'Hit Visual', 'FA Audio all', 'FA Visual all', 'Miss Audio', 'Miss Visual', 'CR Audio', 'CR Visual', 'Hit Max', 'Cr Max', 'Orientation','vertical', 'Location', 'northeastoutside');
    barp(1).FaceColor= [.2 .1 .2]; %making sure that the last one doesn't also turn blue
    barp(2).FaceColor= [.2 .4 .2]; %making sure that the last one doesn't also turn blue
    barp(3).FaceColor= [.5 .1 .1]; %making sure that the last one doesn't also turn blue
    barp(4).FaceColor= [.4 .6 .9]; %making sure that the last one doesn't also turn blue
    barp(5).FaceColor= [.5 .4 .6]; %making sure that the last one doesn't also turn blue
    barp(6).FaceColor= [.9 .6 .3]; %making sure that the last one doesn't also turn blue
    barp(7).FaceColor= [.5 .5 .5]; %making sure that the last one doesn't also turn blue
    barp(8).FaceColor= [.2 .1 .8]; %making sure that the last one doesn't also turn blue
    
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_info.set'], 'filepath', data_path);
    
    if strcmp(group, 'only_bi')
        %% epoching (need erplab plugin for this)
        EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
        EEG  = pop_binlister( EEG , 'BDF', [binlist_location '\binlist_bf_behv_3.txt'], 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
        EEG = pop_epochbin( EEG , epoch_time,  baseline_time); %epoch size and baseline size
        ERP = pop_averager( EEG , 'Criterion', 1, 'DSindex',1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
        
        nexttile
        maxcr=160;
        maxhit=40;
        % bar(participant_info_temp,'DisplayName','participant_info_temp')
        barp=bar(categorical(subject_list(s)),ERP.ntrials.accepted);
        ylim( [0 40]);
        set(gca,'fontsize', 20);
        set(gcf, 'Position',  [100, 100, 1500, 1000])
        legend('Auditory Uni', 'Auditory BI pure', 'Auditory BI not pure','Visual Uni', 'Visual BI pure', 'Visual BI not pure', 'Hit Max', 'Cr Max', 'Orientation','vertical', 'Location', 'northeastoutside');
        print([save_path subject_list{s} '_behav_Results'], '-dpng' ,'-r300');
        savefig([save_path subject_list{s} '_behav_Results'])
        close all
    else
        %% epoching (need erplab plugin for this)
        EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
        EEG  = pop_binlister( EEG , 'BDF', [binlist_location '\binlist_bf_behv_4.txt'], 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
        EEG = pop_epochbin( EEG , epoch_time,  baseline_time); %epoch size and baseline size
        ERP = pop_averager( EEG , 'Criterion', 1, 'DSindex',1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
        
        nexttile
        maxcr=160;
        maxhit=40;
        % bar(participant_info_temp,'DisplayName','participant_info_temp')
        barp=bar(categorical(subject_list(s)),ERP.ntrials.accepted);
        ylim( [0 40]);
        set(gca,'fontsize', 20);
        set(gcf, 'Position',  [100, 100, 1500, 1000])
        legend('Auditory Uni', 'Auditory BI pure', 'Auditory BI not pure','Visual Uni', 'Visual BI pure', 'Visual BI not pure', 'Hit Max', 'Cr Max', 'Orientation','vertical', 'Location', 'northeastoutside');
        print([save_path subject_list{s} '_behav_Results'], '-dpng' ,'-r300');
        savefig([save_path subject_list{s} '_behav_Results'])
        close all
    end
end