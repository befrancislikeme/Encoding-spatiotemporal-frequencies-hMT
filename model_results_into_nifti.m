function create_nifti(subCode,erAnalNameSplit1, ROIname, ROInamenii)

smInput.loadName  = ['sub-', subCode, '_smQ0_',erAnalNameSplit1,'_',ROIname,'_',datestr(now,30)];
smInput.loadPath          = [fmrihmt_RootPath,'/',subCode,'/deconv/Extracted_HRF/'];

smInput.results = load(sprintf('%s%s',hrfInput.loadPath, hrfInput.loadNameSplit1), 'deconvHRF');
varexp((varexp<0))= 0;

[vol info] = BrikLoad([fmrihmt_RootPath,'/',subCode, '/output_dir/' ROInamenii]);

MTpref = zeros( [ size(vol(:,:,:,1)) 3 ] );
for vox = 1: size(smInput.results.deconvHRF.ScanCoords,2)
MTpref(smInput.results.deconvHRF.ScanCoords(1,vox),smInput.results.deconvHRF.ScanCoords(2,vox),smInput.results.deconvHRF.ScanCoords(3,vox),1) = smInput.results.estimatesQ0(vox,1);
MTpref(smInput.results.deconvHRF.ScanCoords(1,vox),smInput.results.deconvHRF.ScanCoords(2,vox),smInput.results.deconvHRF.ScanCoords(3,vox),2) = smInput.results.estimatesQ0(vox,3);
MTpref(smInput.results.deconvHRF.ScanCoords(1,vox),smInput.results.deconvHRF.ScanCoords(2,vox),smInput.results.deconvHRF.ScanCoords(3,vox),3) = smInput.results.varexp(vox);

end
info.DATASET_DIMENSIONS = [ size(vol(:,:,:,1)) 3  0 ];
info.BRICK_LABS = 'sf[0]~tf[1]~varexp[2]';

Opt.prefix = [fmrihmt_RootPath,'/anatomies/Anatomies/' sub_no 'coreg/' output_name];
WriteBrik(MTpref, info, Opt)
clear vol info 

