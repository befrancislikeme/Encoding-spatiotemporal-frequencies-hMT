%Main script
% The script gets all the Event Related Analysis information from the
% subjects after they've been analysed in the mrToolbox via mrInitRet and
% mrLoadRet.
clear all
close all
addpath(genpath('/Fridge/users/anna/fMRI_MT/MT_Exp2/'))
%%GATHERING DATA 
% Collecting .PAR .REC format data from the RIBS LIBRARY converting it into 
% Nifti format and organizing in the /dataset folder structure.
%gatherData()

%%PREPOCESSING 
% Processing Localizer and Run Niftis and generating ROIs in Nifti format 
% on the location where the HRF will be extracted

%%PREPARATION FOR HRF EXTRACTION
% Converting the ROIs done in AFNI to .mat to get ready for mrTools

%createMatROI('V4493','roi_RMT_resampled','right','BON001');

%%HRF EXTRACTION
% Extract the HRFs for all runs and store them into a .mat file

deconvHRF('V8714',5,'PreProc','erAnal_half1_24s','cutoffER_half1_24s','Mask');
deconvHRF('V8714',5,'PreProc','erAnal_half2_24s','cutoffER_half2_24s','Mask');

%%MODEL FITTING

% saveddateSplit1 = '20190503T152900';
% saveddateSplit2 = '20190506T144738';

%change savedate and see if it works
% speedmodelHRFv2 ('V4493','erAnal_half1_24s','erAnal_half2_24s', 5, 'MTL',saveddateSplit1,saveddateSplit2)



%%CREATE NIFTI MAP
% 
