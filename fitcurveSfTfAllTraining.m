function [p, prediction] = fitcurveSfTfAllTraining(xdata, ydata,zdata,lower_point, upper_point,Q,nstep )
%
varY = nanvar((zdata(:)));
%varY = 10^6;

%nstep = 20;
err = varY;
p = zeros(6,1);
tic
for tfopt = linspace(lower_point(1),upper_point(1),nstep)
    for stdtf = linspace(lower_point(2),upper_point(2),nstep)
        for sfopt = linspace(lower_point(3),upper_point(3),nstep)
            for stdsf = linspace(lower_point(4),upper_point(4),nstep)

   
        %NEW STEP. Predict responses including harmonics
        harmonics=1; %[1:2:15];
        PredictedResponse=zeros([size(xdata,2) size(ydata,2)]);
        for sfs=1:size(xdata,2)
            for tfs=1:size(ydata, 2)
                SF = exp((-(log2(xdata(sfs).*harmonics)-log2(sfopt)).^2)./(2*stdsf^2));
                SF = SF./harmonics;
                varsftf = Q.*(log2(xdata(sfs).*harmonics) - log2(sfopt))+log2(tfopt);
                num = (-(log2(ydata(tfs).*harmonics)-varsftf).^2);
                den = 2*(stdtf.^2);
                TF = exp(num./den);
                TF = TF./harmonics;
                PredictedResponse(sfs, tfs)=sum(sum(SF'*TF));
            end
        end
        FittedCurve=PredictedResponse;

        %NEW STEP: Calculate amplitude scaling mathematically, rather than
        %using fmincon to search for the best amplitude. It's faster, and
        %more accurate.
        A= pinv(FittedCurve)'*zdata';
        FittedCurve=FittedCurve.*A;
        
        ErrorVector = (FittedCurve - (zdata)).^2;
        %ErrorTotVector = (zdataNew- mean(mean(zdataNew))).^2;
        %ErrorTotVector = (zdataNew).^2;
        %ssetot = (sum(ErrorTotVector(:)));
        %U = (sum(ErrorVector(:)));
        tmp = zdata - FittedCurve;
        U = nanvar(tmp(:));
        varexp = 1 - (U./varY);
 
                    if U<err
                spatiotemporal_profile = PredictedResponse;
                prediction = FittedCurve;
                p(1) = tfopt;
                p(2) = stdtf;
                p(3) = sfopt;
                p(4) = stdsf;
                p(5) = Q;
                p(6) = varexp;
                err = U;
                    end
        
            end
        end
    end
end
toc


