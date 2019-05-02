function deconvHRF (subCode,pValue,mrtoolsGroupName,erAnalName,erCutoffName)
% Function to extract the HRF for all the voxels on the field of view
% of all the runs for a specific patient.
% The HRF, the HRF maximum, the HRF maximum when significant and the standard
% deviation for every voxel are saved to a .mat file for further use.
% The function is converting the ROI in its .nii file to its .mat conterpart
% while remaining in the correct spatial placement. The correct ROI.mat files
% can then be used in mrTools for the HRF extraction.
%
%HRFsvMaxsm = max(HRF1Dsm,[],2);
% Usage: deconvHRF('subCode', 'mrtoolsGroupName', 'erAnalName', 'erCutoffErName' ,pValue)
%
% subCode               - a char variable that describes the subject code as
%                       defined in the /Library folder of RIBS.
%
% pValue                - an integer variable that represents the choise of
%                       p-value for the cutoff used in the HRF extraction.
%                       pValue - 1 = 0.001;
%                       pValue - 2 = 0.005;
%                       pValue - 3 = 0.01;
%                       pValue - 5 = 0.05;
%
% mrtoolsGroupName      - a char variable that describes the given name to
%                       the mrTools group with processed data
%
% erAnalName            - a char variable of the error values of the analysis.
%                       Comes from mrTools.
%
% erCutoffErName        - a char variable of the mrTools calculated cutoff.
%                       If it wasn't calculated it will be saved under this given name.
%
% - Francisco Fernandes (F.GuerreiroFernandes-2@umcutrecht.nl)
% - Anna Gaglianese     (A.Gaglianese-2@umcutrecht.nl)
if ~exist('subCode','var')
    error('Usage: deconvHRF (subCode,pValue,mrtoolsGroupName,erAnalName,erCutoffName)');
end

if ~exist('pValue','var')
    error('Usage: deconvHRF (subCode,pValue,mrtoolsGroupName,erAnalName,erCutoffName)');
end

if ~exist('mrtoolsGroupName','var') || isempty(mrtoolsGroupName)
    mrtoolsGroupName = 'PreProc';
    fprintf('\nInput mrtoolsGroupName was not stated. As such mrtoolsGroupName was defined as "%s".\n\n',mrtoolsGroupName);
end

if ~exist('erAnalName','var') || isempty(erAnalName)
    erAnalName = 'erAnal';
    fprintf('\nInput erAnalName was not stated. As such erAnalName was defined as "%s".\n\n',erAnalName);
end

if ~exist('erCutoffName','var') || isempty(erCutoffName)
    erCutoffName = 'cutoffER';
    fprintf('\nInput erCutoffName was not stated. As such erCutoffName was defined as "%s".\n\n',erCutoffName);
end

if ~ischar(subCode)
    error('Error. \nInput subCode must be a char, not a %s.',class(subCode));
end

if ~ischar(mrtoolsGroupName)
    error('Error. \nInput mrtoolsGroupName must be a char, not a %s.',class(mrtoolsGroupName));
end

if ~ischar(erAnalName)
    error('Error. \nInput erAnalName must be a char, not a %s.',class(erAnalName));
end

if ~ischar(erCutoffName)
    error('Error. \nInput erCutoffName must be a char, not a %s.',class(erCutoffName));
end

if ~isinteger(int8(pValue)) || (~isequal(pValue,1) && ~isequal(pValue,2) && ~isequal(pValue,3) && ~isequal(pValue,5))
    error('Error. \nInput pValue must be either the integer 1 (for p-value < 0.001), 2 (for p-value < 0.005), 3 (for p-value < 0.01), 5 (for p-value < 0.05),  not a %s variable.',class(pValue));
end

switch pValue
    % cutoff(1)= p<0.001; cutoff(2)= p<0.005; cutoff(3)= p<0.01; cutoff(5)= p<0.05
    case 1
        pValueOut = '0001';
    case 2
        pValueOut = '0005';
    case 3
        pValueOut = '001';
    case 5
        pValueOut = '005';
end
%% Setting up loading and saving Paths
% Setting up complete paths for the /erAnal.mat and /erCutoffER.mat
hrfInput.erAnal.Path        = [fmrihmt_RootPath(), '/analysis/', subCode, '/deconv/',mrtoolsGroupName,'/erAnal/',erAnalName,'.mat'];
hrfInput.erCutoff.Path      = [fmrihmt_RootPath(), '/analysis/', subCode, '/deconv/',mrtoolsGroupName,'/erAnal/',erCutoffName,'.mat'];

% Setting up complete paths for the extracted HRF
hrfOutput.saveName          = ['sub-', subCode, '_hrf_',pValueOut,'_',datestr(now,30)];
hrfOutput.savePath          = [fmrihmt_RootPath,'/analysis/',subCode,'/deconv/Extracted HRF/'];

% Setting up complete paths for mrTools required structures
mrSession.Path              = [fmrihmt_RootPath, '/analysis/', subCode, '/deconv/'];
hrfInput.BrainLocMask.Path  = [fmrihmt_RootPath, '/analysis/', subCode, '/deconv/ROIs/'];
hrfInput.BrainLocMask.Name  = ['sub-',subCode,'_loc-BrainMask.mat'];

hrfInput.BrainLocMask.BrainLocMask = load(sprintf('%s%s', hrfInput.BrainLocMask.Path, hrfInput.BrainLocMask.Name ));
hrfInput.BrainLocMask.BrainLocMask = hrfInput.BrainLocMask.BrainLocMask.(char(fieldnames(hrfInput.BrainLocMask.BrainLocMask)));

% mrSession    = load(sprintf('%s', mrTools.mrSession.Path ));
% mrTools.mrSession.mrSession     = load(sprintf('%s', mrTools.mrSession.Path ));
cd(mrSession.Path)
v = newView;
%% Calculating/Loading efCutoff and erAnal
erCutoffChoice = input(sprintf('Do you want to recalculate the R2 cutoff for subject %s subsampled data? [Y/n]\n', subCode),'s');

if isequal(erCutoffChoice,'Y');
    
    hrfInput.erCutoff.erCutoff = erCutoff(1:5,mrtoolsGroupName,erAnalName,'saveEhdr=0','saveAnalysis=0','numRepeats=10','saveDist=1');
    erCutoffER = hrfInput.erCutoff.erCutoff;
    save(sprintf('%s',hrfInput.erCutoff.Path), 'erCutoffER')
    fprintf('\nYour R2 Cutoff file was saved to the path:\n%s\n\n',hrfInput.erCutoff.Path);
    
elseif isequal(erCutoffChoice,'n');
    
    hrfInput.erCutoff.erCutoff = load(sprintf('%s', hrfInput.erCutoff.Path ));
    hrfInput.erCutoff.erCutoff = hrfInput.erCutoff.erCutoff.(char(fieldnames(hrfInput.erCutoff.erCutoff)));
    
elseif ~isequal(erCutoffChoice,'Y') && ~isequal(erCutoffChoice,'n')
    
    error(sprintf('Answer the question with "Y" or "n".'));
    
end

hrfInput.erAnal.erAnal = load(sprintf('%s', hrfInput.erAnal.Path));
hrfInput.erAnal.erAnal = hrfInput.erAnal.erAnal.(char(fieldnames(hrfInput.erAnal.erAnal)));
%% HRF Extraction
hrfExtraction.Raw = loadROITSeries(v,hrfInput.BrainLocMask.Name,1:5,2);

for run = 1:5
    ind = 1;
    for vox = 1 :  size(hrfExtraction.Raw{run}.tSeries)
        hrfExtraction.scanCoords(:,vox)       = hrfExtraction.Raw{run}.scanCoords(1:3,vox);
        hrfAnalysis{run}.scanCoords(ind,:)    = hrfExtraction.scanCoords(:,vox);
        hrfAnalysis{run}.tSeries(ind,:)       = hrfExtraction.Raw{run}.tSeries(vox,:);
        hrfOutput.hrf.scanCoords{run}(:,ind)  = hrfExtraction.scanCoords(:,vox);
        hrfOutput.hrf.Raw{run}(ind,:) = eventRelatedTSeries(...
            hrfAnalysis{run}.tSeries(ind,:),...
            hrfInput.erAnal.erAnal.d{run}.nhdr,...
            hrfInput.erAnal.erAnal.d{run}.hdrlen,...
            hrfInput.erAnal.erAnal.d{run}.scm );
        hrfOutput.hrf.Max(run,ind)          = max(smooth(hrfOutput.hrf.Raw{run}(ind,:).ehdr));
        %
        hrfOutput.hrf.tmp{run}(ind,:)       = hrfOutput.hrf.Raw{run}(ind,:).ehdr;
        %
        hrfOutput.hrf.ste{run}(ind,:)   = hrfOutput.hrf.Raw{run}(ind,:).ehdrste;
        hrfOutput.hrf.Maxsigvalue(run,ind)  = hrfInput.erAnal.erAnal.overlays.data{run}(...
            hrfExtraction.scanCoords(1,vox),...
            hrfExtraction.scanCoords(2,vox),...
            hrfExtraction.scanCoords(3,vox));
        
        if  (hrfInput.erAnal.erAnal.overlays.data{run}(...
                hrfExtraction.scanCoords(1,vox),...
                hrfExtraction.scanCoords(2,vox),...
                hrfExtraction.scanCoords(3,vox))...
                >= hrfInput.erCutoff.erCutoff{run}.r2cutoff.cutoffs(pValue)) && (hrfOutput.hrf.Max(run,ind) < 6)
            hrfAnalysis{run}.Significance(ind) = 1;
            hrfOutput.hrf.Maxsig(run,ind) = hrfOutput.hrf.Max(run,ind);
            
        else
            hrfAnalysis{run}.Significance(ind) = 0;
            hrfOutput.hrf.Maxsig(run,ind) = 0;
        end
        ind = ind+1;
        %vox_total(sub,run) = ind;
    end
end
%% Saving HRF Matrix
cd(fmrihmt_RootPath)
mrQuit

deconvHRF = hrfOutput.hrf;
save(sprintf('%s%s',hrfOutput.savePath, hrfOutput.saveName), 'deconvHRF')
fprintf('\nThe extracted HRF was saved to the path:\n%s\n\n Under the Name:\n%s\n',hrfOutput.savePath,hrfOutput.saveName);

return