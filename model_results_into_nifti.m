function model_results_into_nifti(subCode,subCode2, erAnalNameSplit1, ROIname, ROInamenii)

smInput.loadName  = ['sub-', subCode, '_smQ0_',erAnalNameSplit1,'_',ROIname '.mat'];
smInput.loadPath          = [fmrihmt_RootPath,'/',subCode,'/deconv/Extracted_HRF/'];

smInput.results = load(sprintf('%s%s',smInput.loadPath, smInput.loadName));
smInput.results.varexp((smInput.results.varexp<0))= 0;

[vol info] = BrikLoad([fmrihmt_RootPath,'/',subCode, '/output_dir/' ROInamenii]);
output_name = ['fit_model_params_' erAnalNameSplit1 '_' ROIname ]
MTpref = zeros( [ size(vol(:,:,:,1)) 3 ] );
for vox = 1: size(smInput.results.scanCoords,2)
MTpref(smInput.results.scanCoords(1,vox),smInput.results.scanCoords(2,vox),smInput.results.scanCoords(3,vox),1) = smInput.results.estimatesQ0(vox,1)*10;
MTpref(smInput.results.scanCoords(1,vox),smInput.results.scanCoords(2,vox),smInput.results.scanCoords(3,vox),2) = smInput.results.estimatesQ0(vox,3);
MTpref(smInput.results.scanCoords(1,vox),smInput.results.scanCoords(2,vox),smInput.results.scanCoords(3,vox),3) = smInput.results.varexp(vox)*10;

end
info.DATASET_DIMENSIONS = [ size(vol(:,:,:,1)) 3  0 ];
info.BRICK_LABS = 'sf[0]~tf[1]~varexp[2]';

Opt.prefix = [fmrihmt_RootPath,'/anatomies/Anatomies/' subCode2 'coreg/' output_name];
WriteBrik(MTpref, info, Opt)
clear vol info 

