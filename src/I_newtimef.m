%% ERSP corrected for multiple comparisons
% clear variables
% eeglab
% close all
%% Subject info for each script
% This defines the set of subjects
subject_list = {'12377' '12494' '12565' '12666' '12675'};
% Path to the parent folder, which contains the data folders for all subjects
home_path  = 'D:\ASSR_oddball\';
study_save = 'D:\ASSR_oddball\study\';
trials_num_reduced=270; 
concat_40 = [];concat_27 = [];
for s = 1:length(subject_list)


    % power_40_std= zeros(64,257); power_27_std= zeros(64,257);
    data_path  = [home_path subject_list{s} '\'];
    %loading data (one stream)
    EEG_40_std = pop_loadset('filename',[subject_list{s} '_40_std.set'],'filepath', study_save );
    %reducing trials to be same between participants
    EEG_40_std = pop_select(EEG_40_std, 'trial', randsample(1:size(EEG_40_std.data,3), trials_num_reduced));
    %doing the same for the other stream
    EEG_27_std = pop_loadset('filename',[subject_list{s} '_27_std.set'],'filepath', study_save );
    EEG_27_std = pop_select(EEG_27_std, 'trial', randsample(1:size(EEG_27_std.data,3), trials_num_reduced));
%  all_40(:,:,:,s)=EEG_40_std.data;
%   all_27(:,:,:,s)=EEG_27_std.data;
  concat_40 = cat(3, concat_40, EEG_40_std.data);
  concat_27 = cat(3, concat_27, EEG_27_std.data);
end
  
% %% averaging 
% grand_avg_40= mean(all_40(:,:,:,:),4);
% grand_avg_27= mean(all_27(:,:,:,:),4);

 time_freq_frequencies_range = [1 60];
%channel={37, 38};% FCz = 47 %Fc=38 % can add as many as you want

        figure();[ersp,itc,powbaseCommon,times,freqs,erspboot,itcboot, tfdata] =  newtimef(concat_40(48,:,:) ,...
            EEG_40_std.pnts,...%frames (uses the total amount of sample points in the data
            [EEG_40_std.xmin EEG_40_std.xmax]*1000,... %using the epoch times of the data *1000 to go from s to ms
            EEG_40_std.srate,... %finds the sampling rate in the data
            0,... % if 0,use FFTs and Hanning window tapering see "varwin" in the newtimef help file
            'freqs', time_freq_frequencies_range,...
            'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
            'commonbase', 'on',... %this is default, not sure how/why to set the baseline
            'mcorrect', 'fdr',... %correcting for multiple comparisons
            'pcontour', 'on',... % puts a contour around the plot for what is significant
            'title', '100 trials 40hz Cz');%
        
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
       % save([data_path  'ERSP_SingleTrial\ERSP_low_multiplcor_' type_of_bin '_' EEG_low.chanlocs(channel{i}).labels  '.mat'], 'powbaseCommon', 'tfdata', 'times', 'freqs',  '-v7.3')
       % print([figure_path 'ERSP_low_multiplcor_' type_of_bin '_' EEG_low.chanlocs(channel{i}).labels], '-dpng' ,'-r300');
       % close all