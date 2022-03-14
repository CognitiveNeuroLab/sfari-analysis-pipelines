% Plotting the raw data to see if there are remaining bad or flat channels
% Created by Douwe Horsthuis last update 3/1/2022
% ------------------------------------------------
eeglab
subject_list = {'12377' '12494' '12565' '12666' '12675'};
home_path  = {'D:\OpticalFlow_sfari\' 'D:\ASSR_oddball\' 'D:\Beep-Flash_sfari\' 'D:\F.A.S.T. Response task\' 'D:\IllusoryContours_sfari\' 'D:\Restingstate_eyetracking\' };
for paradigm=2%1:length(home_path)
for s=1:length(subject_list)
    clear bad_chan;
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    data_path  = [home_path{paradigm} subject_list{s} '\'];
    EEG = pop_loadset('filename', [subject_list{s} '_bad_chan.set'], 'filepath', data_path);
    pop_eegplot( EEG, 1, 1, 1);
    prompt = 'Delete channels? If yes, input them all as strings inside {}. If none hit enter ';
    bad_chan = input(prompt); %
    if isempty(bad_chan) ~=1
    EEG = pop_select( EEG, 'nochannel',bad_chan);
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_exchn.set'],'filepath', data_path);
    end
    close all
end
end
