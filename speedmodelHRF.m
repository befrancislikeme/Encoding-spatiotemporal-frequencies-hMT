function speedmodelHRF (subCode,erAnalNameSplit1,erAnalNameSplit2, pValue, ROIname,saveddate)
%Model fitting 
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


hrfInput.loadNameSplit1          = ['sub-', subCode, '_hrf_',erAnalNameSplit1,'-',pValueOut,'_',ROIname,'_',saveddate,'.mat'];
hrfInput.loadNameSplit2          = ['sub-', subCode, '_hrf_',erAnalNameSplit2,'-',pValueOut,'_',ROIname,'_',saveddate,'.mat'];

hrfInput.loadPath          = [fmrihmt_RootPath,'/',subCode,'/deconv/Extracted_HRF/'];

smOutput.saveName  = ['sub-', subCode, '_smQ0_',erAnalNameSplit1,'_',ROIname,'_',datestr(now,30)];
smOutput.savePath  = [fmrihmt_RootPath,'/',subCode,'/deconv/Extracted_HRF/'];

load(sprintf('%s%s',hrfInput.loadPath, hrfInput.loadNameSplit1), 'deconvHRF');


   for vox = 1: size(deconvHRF.Max,2)
%            MT_max_sig_half1{vox} = [nan deconvHRF.Maxsig(5,vox) nan; deconvHRF.Maxsig(3,vox) deconvHRF.Maxsig(2,vox)  deconvHRF.Maxsig(1,vox); nan deconvHRF.Maxsig(4,vox) nan];
            MT_max_half1{vox} = [nan deconvHRF.Max(5,vox) nan; deconvHRF.Max(3,vox) deconvHRF.Max(2,vox)  deconvHRF.Max(1,vox); nan deconvHRF.Max(4,vox) nan];
   end  
clear deconvHRF
   
load(sprintf('%s%s',hrfInput.loadPath, hrfInput.loadNameSplit2), 'deconvHRF');


   for vox = 1: size(deconvHRF.Max,2)
%            MT_max_sig_half2{vox} = [nan deconvHRF.Maxsig(5,vox) nan; deconvHRF.Maxsig(3,vox) deconvHRF.Maxsig(2,vox)  deconvHRF.Maxsig(1,vox); nan deconvHRF.Maxsig(4,vox) nan];
            MT_max_half2{vox} = [nan deconvHRF.Max(5,vox) nan; deconvHRF.Max(3,vox) deconvHRF.Max(2,vox)  deconvHRF.Max(1,vox); nan deconvHRF.Max(4,vox) nan];
   end  
clear deconvHRF

%%
sf = [0.2 0.33 1];
tf = [1 3 5];

xdata = sort([linspace(0.05,1.2,20) sf]);
ydata = (sort([logspace(-0.3,1.2,20) tf]));
lower_point = [ 0.25; 0.2;  0.1; 0.2 ];
upper_point = [10   ;  10  ;  1.2  ; 2  ];

nsteps = 10;
FittedCurveQ0 = cell(1,size(deconvHRF.Max,2));
estimatesQ0 = zeros(size(deconvHRF.Max,2),6);
varexp = zeros(size(deconvHRF.Max,2),1);

for j = 1:size(deconvHRF.Max,2)
     j
     [estimatesQ0(j,:)] = fitcurveSfTfAllTraining(sf, tf,MT_max_half1{j},lower_point,upper_point,0,nsteps);
     estimatesQ0(j,:)

     if sum(estimatesQ0(j,:)) ~= 0 
     [varexp(j,1), FittedCurveQ0{j}] = fitcurveSfTfAllValidation(xdata, ydata,MT_max_half2{j},estimatesQ0(j,:));
      varexp(j,1)

     end
end


save(sprintf('%s%s',smOutput.savePath, smOutput.saveName), 'estimatesQ0', 'varexp', 'FittedCurveQ0', '-v7.3');
fprintf('\nThe estimated speed model was saved to the path:\n%s\n\n Under the Name:\n%s\n',hrfOutput.savePath,hrfOutput.saveName);

return