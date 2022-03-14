# sfari-analysis-pipelines
pipelines to do the frequency analyses for all the SFARI project's paradigms (pre-processing and frequency domain)

![Logo](https://github.com/CognitiveNeuroLab/sfari-analysis-pipelines/blob/main/images/CNL_logo.jpeg)


# Sfari Project
This is a project in which we will collect data from children 8-12 on the spectrum, siblings of people on the spectrum and controls. They will do several paradigms that we will analyse together. 

# ASSR pipeline explained

**scripts**
  
1. [A_merge_sets](#a_merge_sets)
2. [B_downs_filter_chaninfo_exclchan](#b_downs_filter_chaninfo_exclchan)
3. [C_manual_check](#c_manual_check)
4. [D_reref_exclextrn_interp_avgref_ica_autoexcom](#d_reref_exclextrn_interp_avgref_ica_autoexcom)
5. [E_epoching_ASSR](#e_epoching_ASSR)
6. [F_all_analysis](#f_all_analysis)  
    - [Frequency spectrum](#frequency-spectrum)
    - [Time Frequency](#time-frequency)
7. [H_Gamma_preprocess](#H_Gamma_preprocess)

## A_merge_sets
This script simply takes the .bdf files and creates .set files (EEGlab structure).  
  
  
## B_downs_filter_chaninfo_exclchan  
  
To understand the data we first run it through the pipeline with some fairly strick filtering. This is done to get some idea of the paradigm.  
In this script we are downfiltering to 256hz to keep the data manageble in size and for optimizing the ICA.  
We filter using a 1hz highpass filter and a 50hz lowpass filter.
We add channel info and use the pop_clean_rawdata function to delete bad channels (using the functions standard setting).

## C_manual_check  
  
Here we load data and manually delete channels that still are too   
  
## D_reref_exclextrn_interp_avgref_ica_autoexcom  
  
We interpolate the bad channels, re-reference to the average and do an ICA.
We delete components if the eye components contain over 80% eye and less then 10% brain. 
  
## E_epoching_ASSR  

We epoch the data -100 800 with a baseline from -100 to 0. After this we delete all the epochs that have 120uV. 
This also will show us how many trials everyone has left. This should dictate how many trials you want to use for the next script.  
  
## F_all_analysis  
  
We use 270 randomly selected trials for both standard streams (27hz and 40hz). After that we do 3 main analysis 

### Frequency spectrum  
  
For this analysis we use matlab's pwelch function, slightly adapted by [Shlomit Beker](https://github.com/Shlomit-Beker).  
We use all the standard settings except that we set the sampling rate to that of the data (256) and we only go up to 50hz. After that we plot a logtransfomation of the data.
  
### Time Frequency
  
For this we use [EEGlabs newtimef function](https://github.com/sccn/eeglab/blob/develop/functions/timefreqfunc/newtimef.m). We run this on concatenated data (all the trials of e). We use the following settings that are different from the default settings:  
frames: amount of data points for an epoch (EEG.points)  
epoch time: the full epoch as we define it in E_epoching_ASSR (-100 to 800) ([EEG_40_std.xmin EEG_40_std.xmax]*1000 )  
sampling rate: 512 (EEG_40_std.srate)  
cycles= FFT instead (0)  
frequencies: 1-50hz (time_freq_frequencies_range)  
alpha: 0.05  
commonbase: on
mcorrect: using FDR to correct for multiple comparisons
pcontour: on ,puts a contour around the plot for what is significant  

### ERP  
  
To assess the strength of evoked activity we first have to filter more. For the 27hz stream we use a 22hz highpass and a 32hz lowpass. For the 40hz stream we do a 35hz highpass and a 45hz lowpass. 

After that we use the EEGLAB study to plot averages.  
  
## H_Gamma_preprocess  
  
We run the same pipeline again, but this time we have some changes in the settings:  
- we do a lowpass filter of 200hz. We chose 200hz because the data is collected at 512hz, so we need to be a little lower than half of that (nyquist filter). 
- We do not downsample  
- we delete ICA components if they have more than 60% eye and less than 10% brain

## Run the F_all_analysis script again  
We run this again to get the results with the correct data.  