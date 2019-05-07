clear all 
close all
%%
load ../results_v7_half1.mat

for sub = 1:5
    for hem =1:2
        
           for vox = 1: size(HRFsvMax{sub}{hem},2)
                    MT_max_sig_half1{sub}{hem}{vox} = [nan HRFsvMaxsig{sub}{hem}(5,vox) nan; HRFsvMaxsig{sub}{hem}(3,vox) HRFsvMaxsig{sub}{hem}(2,vox)  HRFsvMaxsig{sub}{hem}(1,vox); nan HRFsvMaxsig{sub}{hem}(4,vox) nan];
                    MT_max_half1{sub}{hem}{vox} = [nan HRFsvMax{sub}{hem}(5,vox) nan; HRFsvMax{sub}{hem}(3,vox) HRFsvMax{sub}{hem}(2,vox)  HRFsvMax{sub}{hem}(1,vox); nan HRFsvMax{sub}{hem}(4,vox) nan];
           end
   end
end

clear HRFsvMax HRFsvMaxsig


load ../results_v7_half2.mat
for sub = 1:5
    for hem =1:2
           for vox = 1: size(HRFsvMax{sub}{hem},2)
                    MT_max_sig_half2{sub}{hem}{vox} = [nan HRFsvMaxsig{sub}{hem}(5,vox) nan; HRFsvMaxsig{sub}{hem}(3,vox) HRFsvMaxsig{sub}{hem}(2,vox)  HRFsvMaxsig{sub}{hem}(1,vox); nan HRFsvMaxsig{sub}{hem}(4,vox) nan];
                    MT_max_half2{sub}{hem}{vox} = [nan HRFsvMax{sub}{hem}(5,vox) nan; HRFsvMax{sub}{hem}(3,vox) HRFsvMax{sub}{hem}(2,vox)  HRFsvMax{sub}{hem}(1,vox); nan HRFsvMax{sub}{hem}(4,vox) nan];
           end
   end
end

save test_split

%%
sf = [0.2 0.33 1];
tf = [1 3 5];

xdata = sort([linspace(0.05,1.2,20) sf]);
ydata = (sort([logspace(-0.3,1.2,20) tf]));

%
nsteps = 20;
% load test_split.mat
bstr = 1
% FittedCurveQvar = cell(1,100);
% FittedCurveQ1 = cell(1,100);
% FittedCurveQ0 = cell(1,100);
% estimatesQ0 = zeros(bstr,6);
% estimatesQ1 = zeros(bstr,6);
% estimatesQvar = zeros(bstr,6);
% varexp = zeros(bstr,3);
for sub = 1:5
  for hem =1:2

    for j = 1:size(MT_max_half1{sub}{hem},2)
    lower_point = [ 0.25; 0.2;  0.1; 0.2 ];
    upper_point = [10   ;  10  ;  1.2  ; 2  ];
        
     %Q = 0
     [estimatesQ0{sub}{hem}(j,:)] = fitcurveSfTfAllTraining(sf, tf,MT_max_half1{sub}{hem}{j},lower_point,upper_point,0,nsteps);
     estimatesQ0{sub}{hem}(j,:)

     if sum(estimatesQ0{sub}{hem}(j,:)) ~= 0 
          [varexp{sub}{hem}(j,1) FittedCurveQ0{j}] = fitcurveSfTfAllValidation(xdata, ydata,MT_max_half2{sub}{hem}{j},estimatesQ0{sub}{hem}(j,:));
          varexp{sub}{hem}(j,1)

     end
     
%      %Q = 1
%      [estimatesQ1(j,:)] = fitcurveSfTfAllTraining(sf, tf,areazscallTrain{1}{j},lower_point,upper_point,1,nsteps);
%      [varexp(j,2) FittedCurveQ1{j}] = fitcurveSfTfAllValidation(xdata, ydata,areazscallVal{1}{j},estimatesQ1(j,:));
%      %Q var
%      [estimatesQvar(j,:)] = fitcurveSfTfVarTraining(sf, tf,areazscallTrain{j},lower_point,upper_point,nsteps);
%      [varexp(j,3) FittedCurveQvar{j}] = fitcurveSfTfAllValidation(xdata, ydata,areazscallVal{j},estimatesQvar(j,:));

    end


  end


end


save(['fitting_half'])
%%
close all
xpos = [.5, 1.5, 2.5, 3.5 , 4.5];

for spatfreq = 1:5
    figure;
    rectangle('Position',[xpos(spatfreq),-.5,.75,6],'FaceColor',[0.5 .5 .5],'LineWidth',0.1),hold on
    for sub = 1:5
    temp = HRFsvMax{sub}{1}(:,pref_speed{sub}{1} == spatfreq);
    errorbar(1:5, mean(temp,2),std(temp,0,2)/size(temp,2),'Color',[0 0 0]+0.1*sub), hold on, axis([0 6 -.5 4.5])
    ylabel('HRF max')
    set(gca,'XTick',1:5)
%    xticklabels({'0','3deg 1Hz','3deg 3Hz','3deg 5Hz','1deg 3Hz','5deg 3Hz'})
    set(gca, 'XTickLabel', {'3deg 1Hz','3deg 3Hz','3deg 5Hz','1deg 3Hz','5deg 3Hz'})
    end
    legend('S1','S2','S3','S4','S5')
end

%%
for j = 1: 10
h1 = figure;
imagesc(xdata,(ydata), (FittedCurveQ0{j}')), axis square, colormap(gray),colorbar%title(['el' num2str(elnum(1))])
%set(gca,'yScale','log'), 
% currentlabel = get(gca,'xTick');
% x = 10.^[log10(0.2) log10(0.33) log10(1) log10(1.4) ];
 set(gca,'FontSize',20)
 %currentlabel = get(gca,'yTick');
 %y = 10.^[log10(1) log10(3) log10(5) log10(10) ];
 % y = [1 3 5];
 set(gca,'FontSize',20)
set(gca,'yDir','normal')
end

 
 
