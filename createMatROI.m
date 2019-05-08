function createMatROI (subCode,roiName, hemName, corrName)
% Function to create the ROIs in the same space as the Locatizers (now 
% serving as anatomy) and Runs be loaded in mrTools. 
% This function creates both left hemisphere ROI and right hemisphere ROI,
% merges them if chosen and saves them in the ROI folder.
% The function is converting the ROI in its .nii file to its .mat conterpart
% while remaining in the correct spatial placement. The correct ROI.mat files
% can then be used in mrTools for the HRF extraction.
% 
%
% Usage: createMatROI('subCode', 'roiName', 'outputPath', 'hemName', 'corrName')
%  
% subCode       - a char variable that describes the subject code as 
%               defined in the /Library folder of RIBS.
%
% roiName       - a char variable that describes the name of the resampled 
%               ROI inside the ROI folder of the specified subCode subject
%
% hemName       - a char variable that can be either 'left' or 'right'
%               depending on the hemisphere of the ROI loaded in 'roiName'
%
% corrName      - a char variable that defines the correction performed
%               when creating the ROI. Reccomended 'BON' for Bonferroni
%               and 'FDR' for False Discovery Rate. p-value should be
%               reported without decimal representation (i.e.: p = 0.01 
%               is represented as 001).
%
% - Francisco Fernandes (F.GuerreiroFernandes-2@umcutrecht.nl)
%
if ~exist('subCode','var')
   error('Usage: createMatROI(subCode, roiName, outputPath)');
end

if ~exist('roiName','var')
   error('Usage: createMatROI(subCode, roiName, outputPath)');
end

if ~exist('hemName','var')
   error('Usage: createMatROI(subCode, roiName, outputPath)');
end

if ~exist('corrName','var')
   error('Usage: createMatROI(subCode, roiName, outputPath)');
end
    
if ~ischar(subCode)
   error('Error. \nInput subCode must be a char, not a %s.',class(subCode));
end

if ~ischar(roiName)
   error('Error. \nInput roiName must be a char, not a %s.',class(roiName));
end

if ~ischar(hemName)
   error('Error. \nInput roiName must be a char, not a %s.',class(hemName));
end

if ~ischar(corrName)
   error('Error. \nInput roiName must be a char, not a %s.',class(corrName));
end

roiOutput.savePath  = [fmrihmt_RootPath, '/analysis/', subCode, '/deconv/ROIs/'];
roiOutput.saveName  = ['sub-', subCode, '_roi-', hemName, 'MT_',corrName];
%output_ROI dir 
roiInput.loadPath   = [fmrihmt_RootPath,'/analysis/',subCode,'/output_dir/ROI_alignment/',roiName,'.nii'];
% Allows for other path to be added in to the conversion function. 
% roiInput.loadPath   = [fmrihmt_RootPath,'/analysis/',subCode,'/output_dir/',roiName,'.nii'];


roiInput = load_nii(roiInput.loadPath);
% Find coords of MT ROI where value = 1
[i,j,z] = ind2sub(size(roiInput.img), find(roiInput.img == 1));
roiCoords = [i j z ones(size(i,1),1)]';

% Load sub-{subCode}_roi-test.mat as the model of the ROIs to create
roiTemplate = load(sprintf('%s/dataset/sub-%s/sub-%s_roi-test.mat',fmrihmt_RootPath(),subCode,subCode));
roiTemplate = roiTemplate.(char(fieldnames(roiTemplate)));

if ~isempty(strfind(hemName,'right')) || ~isempty(strfind(hemName,'left'))
    roiTemplate.coords  = roiCoords;
    roiTemplate.name    = roiOutput.saveName;
    save(sprintf('%s%s',roiOutput.savePath, roiOutput.saveName), 'roiTemplate')
    fprintf('\nYour ROI was saved to the path:\n%s\n\nUnder the name:\n%s\n',roiOutput.savePath,roiOutput.saveName); 
else
    error(sprintf('Such hemisphere option is invalid! \nPlease use "right" or "left" as valid options.'));
end    
end

