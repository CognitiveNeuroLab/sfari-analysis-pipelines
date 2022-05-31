# sfari-analysis-pipelines
pipelines to do the frequency analyses for all the SFARI project's paradigms (pre-processing and frequency domain)

![Logo](https://github.com/CognitiveNeuroLab/sfari-analysis-pipelines/blob/main/images/CNL_logo.jpeg)


# Sfari Project
This is a project in which we will collect data from children 8-12 on the spectrum, siblings of people on the spectrum and controls. They will do several paradigms that we will analyse together. 

# Beep-Flash pipeline explained

**scripts**
  
1. [A_merge_sets](#a_merge_sets)

2. [B_downs_filter_chaninfo_exclchan](#b_downs_filter_chaninfo_exclchan)
3. [C_manual_check](#c_manual_check)
4. [D_reref_exclextrn_interp_avgref_ica_autoexcom](#d_reref_exclextrn_interp_avgref_ica_autoexcom)
5. [E_epoching_fast](#e_epoching_fast)
6. [F_all_analysis_fast](#f_all_analysis_fast)  
    - [Frequency spectrum](#frequency-spectrum)
    - [Time Frequency](#time-frequency) 
7. [I_behavioral_bf](#b_behavioral_bf) 
8. [results](#results)


## A_merge_sets
This script simply takes the .bdf files and creates .set files (EEGlab structure). 
  
## B_downs_filter_chaninfo_exclchan  
  
To understand the data we first run it through the pipeline with some fairly strict filtering. This is done to get some idea of the paradigm.  
In this script we are downfiltering to 256hz to keep the data manageable in size and for optimizing the ICA.  
We filter using a 1hz highpass filter and a 200hz lowpass filter. These can be changed in line 16 to 18. 
We add channel info and use the pop_clean_rawdata function to delete bad channels (using the functions standard setting).  
**We did not use externals during the piloting part, we will during the collection of the rest of the data, you can and maybe should re-reference to externals** However, if you do so, you need to check FIRST that non of the channels are flat. If you fail to do this, the channels will have re-referenced data in them an thus not look flat. To use the current (better) cleaning function `pop_clean_rawdata` you need to delete externals. [However, EEGLAB is updating this, so you can select in the function to ignore these channels.](https://github.com/sccn/clean_rawdata/issues/28). Check if this works before, like that you can re-reference after this step. 

## C_manual_check  
  
Here we manually delete channels that still are too noisy  
  
## D_reref_exclextrn_interp_avgref_ica_autoexcom  
  
We interpolate the bad channels, re-reference to the average and do an ICA.
We delete components if the eye components contain over 80% eye and less then 10% brain. This can be changed in line 81 and 82. In line 81, you can add more types of noise components so that you delete them if they as a sum reach over 80%. Howerver this is not a conservative approach and not suggested by some senior lab members (Ana Francisco, Filip DeSanctis 2022).
Whatever we delete and keep gets plotted and all figures are saved. 
  
## E_epoching_bf

We epoch the data -500 2000 with a baseline from -50 to 0. This is big because we want as much time as we can for the Frequency analysis. After this we delete all the epochs that have 120uV. We use the `binlist_bf.txt` that creates 2 types of epochs. 1 that has 0 at onset of the visual cue, the other that has 0 at the onset of the auditory cue. 
This also will show us how many trials everyone has left. This should dictate how many trials you want to use for the next script.  
  
## F_all_analysis  
  
The previous script should create a variable that shows how many trials there are for each Bin (type of epoch). The lowest number can be used to make sure everyone has equal amount of trials. This can be changed in line 18. This will mean that for every participant that has more trials than the selected amount, a random sub-set will be chosen to work with from here.  

## I_behavioral_bf  
This is unique for this paradigm this is why there are 2 B scripts. 
It should be ran early on, because you would want to know how people did to see if you can include them in your study. 
This script takes the logfiles from the UDTR and from the real paradigm and looks at how they did and plots it. After that it looks at the BDF file, `ID#.set'. This file should be created after script `A_merge_sets`.  
This will plot the progression of UDTR scores, to see how the participant did across the UDTR. It will plot the accuracy per block. But to focus better on types of False alarms, it looks at the BDF file, uses the `binlist_bf_behv_2.txt` `binlist_bf_behv_3.txt` and `binlist_bf_behv_4.txt` to create bins and see what type of responses there where (Hit/Miss/False Alarm(FA)/Correct Rejection (CR)). After that it use a different binlist to look more into what type of FA happened. This should give a good indication of the preformance of the participant.

