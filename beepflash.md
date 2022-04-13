# sfari-analysis-pipelines
pipelines to do the frequency analyses for all the SFARI project's paradigms (pre-processing and frequency domain)

![Logo](https://github.com/CognitiveNeuroLab/sfari-analysis-pipelines/blob/main/images/CNL_logo.jpeg)


# Sfari Project
This is a project in which we will collect data from children 8-12 on the spectrum, siblings of people on the spectrum and controls. They will do several paradigms that we will analyse together. 

# Illusory Contours pipeline explained

**scripts**
  
1. [A_merge_sets](#a_merge_sets)
2. [B_downs_filter_chaninfo_exclchan](#b_downs_filter_chaninfo_exclchan)
3. [C_manual_check](#c_manual_check)
4. [D_reref_exclextrn_interp_avgref_ica_autoexcom](#d_reref_exclextrn_interp_avgref_ica_autoexcom)
5. [E_epoching_fast](#e_epoching_fast)
6. [F_all_analysis_fast](#f_all_analysis_fast)  
    - [Frequency spectrum](#frequency-spectrum)
    - [Time Frequency](#time-frequency)
7. [results](#results)
# under construction
<!--
## A_merge_sets
This script simply takes the .bdf files and creates .set files (EEGlab structure).  
  
  
## B_downs_filter_chaninfo_exclchan  
  
To understand the data we first run it through the pipeline with some fairly strict filtering. This is done to get some idea of the paradigm.  
In this script we are downfiltering to 256hz to keep the data manageable in size and for optimizing the ICA.  
We filter using a 1hz highpass filter and a 50hz lowpass filter.
We add channel info and use the pop_clean_rawdata function to delete bad channels (using the functions standard setting).

## C_manual_check  
  
Here we manually delete channels that still are too noisy  
  
## D_reref_exclextrn_interp_avgref_ica_autoexcom  
  
We interpolate the bad channels, re-reference to the average and do an ICA.
We delete components if the eye components contain over 80% eye and less then 10% brain. 
  
## E_epoching_IC 

We epoch the data -100 500 with a baseline from -50 to 0. After this we delete all the epochs that have 120uV. 
This also will show us how many trials everyone has left. This should dictate how many trials you want to use for the next script.  
  
## F_all_analysis  
  
We use 240 randomly selected trials for both the conditions. After that we do 3 main analysis 

### Frequency spectrum  
  
For this analysis we use matlab's pwelch function, slightly adapted by [Shlomit Beker](https://github.com/Shlomit-Beker).  
We use all the standard settings except that we set the sampling rate to that of the data (256) and we only go up to 50hz. After that we plot a logtransfomation of the data.
  
### Time Frequency
  
For this we use [EEGlabs newtimef function](https://github.com/sccn/eeglab/blob/develop/functions/timefreqfunc/newtimef.m). We run this on concatenated data (all the trials of e). We use the following settings that are different from the default settings:  
frames: amount of data points for an epoch (EEG.points)  
epoch time: the full epoch as we define it in E_epoching_ASSR (-100 to 500) ([EEG.xmin EEG.xmax]*1000 )  
sampling rate: 512 (EEG.srate)  
cycles= FFT instead (0)  
frequencies: 1-50hz (time_freq_frequencies_range)  
alpha: 0.05  
commonbase: on
mcorrect: using FDR to correct for multiple comparisons
pcontour: off ,puts a contour around the plot for what is significant  

We plot the conditions by themselves and we compare the condtions, but for this second part it is not possible to correct for multiple comparisons. 

### ERP  
  
We use the EEGLAB study to plot averages, of all the conditions for multiple channels.   

## Results  
  
We are expecting a difference in alpha and theta. We are also expecting a more positive P1 amplitude to faces compared to objects, and a difference in P1 between faces (that should not be there when we have an ASD group). We also expect the N170 to be more negative in amplitude and faster in latency for Faces vs objects and also to be more negative and slower between for inverted faces compared to upright faces.

### ERPs  
  
![ERPs](https://github.com/CognitiveNeuroLab/sfari-analysis-pipelines/blob/main/images/ERPs_fast.jpg)  
  
### Power spectrum
  
![Power spectrum](https://github.com/CognitiveNeuroLab/sfari-analysis-pipelines/blob/main/images/Pwelch_fast.png)  
  
### Time Frequency  
  
In this case we can only correct for multiple comparisons when plotting one condition. So the first 4 plots have the correction. The last 2, comparing conditions, do not.  
  
![Face normal](https://github.com/CognitiveNeuroLab/sfari-analysis-pipelines/blob/main/images/ERSP_face_nrm_oz.png)  
  
![Face up-side-down](https://github.com/CognitiveNeuroLab/sfari-analysis-pipelines/blob/main/images/ERSP_face_upsdwn_oz.png)  
  
![Object normal](https://github.com/CognitiveNeuroLab/sfari-analysis-pipelines/blob/main/images/ERSP_obj_nrm_oz.png)  
  
![Object up-side-down](https://github.com/CognitiveNeuroLab/sfari-analysis-pipelines/blob/main/images/ERSP_obj_upsdwn_oz.png)  
  
![Comparing faces](https://github.com/CognitiveNeuroLab/sfari-analysis-pipelines/blob/main/images/ERSP_face_oz.png)  
  
![Comparing objects](https://github.com/CognitiveNeuroLab/sfari-analysis-pipelines/blob/main/images/ERSP_obj_oz.png)  
  
![Comparing face vs objects (both right-side-up)](https://github.com/CognitiveNeuroLab/sfari-analysis-pipelines/blob/main/images/ERSP_face_obj_oz.png)


  
  