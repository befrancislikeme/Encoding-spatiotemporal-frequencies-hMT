% The script gets all the Event Related Analysis information from the
% subjects after they've been analysed in the mrToolbox via mrInitRet and
% mrLoadRet.

%%GATHERING DATA 
% Collecting .PAR .REC format data from the RIBS LIBRARY converting it into 
% Nifti format and organizing in the /dataset folder structure.
gatherData()

%%PREPOCESSING 
% Processing Localizer and Run Niftis and generating ROIs in Nifti format 
% on the location where the HRF will be extracted

%%PREPARATION FOR HRF EXTRACTION
% Converting the ROIs done in AFNI to .mat to get ready for mrTools

createMatROI('V4493','roi_RMT_resampled','right','BON001');

%%HRF EXTRACTION
% Extract the HRFs for all runs and store them into a .mat file

deconvHRF ('V4493',5,'PreProc','erAnal','cutoffER')

%%Testing deconvHRF

subCode             = 'V4493';
mrtoolsGroupName    = 'PreProc';
erAnalName          = 'erAnal';
erCutoffName        = 'cutoffER';
pValueOut = '005';



%%MODEL FITTING
% 


%%CREATE NIFTI MAP
% 
