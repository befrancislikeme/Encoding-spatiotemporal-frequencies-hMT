function [varexp PredictedResponse] = fitcurveSfTfAllValidation(xdata, ydata,zdata,params)
%
    
        varY = nanvar(zdata(:));
        %varY = 10^6;
        tfopt = params(1);
        stdtf = params(2);
        sfopt = params(3);
        stdsf = params(4);
        Q =  params(5);      

   
        %NEW STEP. Predict responses including harmonics
        harmonics=1 ; %[1:2:15];
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
        sf = [0.2 0.33 1];
        indx(1) = find(xdata == sf(1));
        indx(2) = find(xdata == sf(2));
        indx(3) = find(xdata == sf(3));
        %FittedCurve = A .* exp(-lambda * xdata);

        tf = [1 3 5];
        indy(1) = find(ydata == tf(1));
        indy(2) = find(ydata == tf(2));
        indy(3) = find(ydata == tf(3));
        
        FittedCurve = FittedCurve(indx,indy);
        
        
        %NEW STEP: Calculate amplitude scaling mathematically, rather than
        %using fmincon to search for the best amplitude. It's faster, and
        %more accurate.
        A= pinv(FittedCurve)'*zdata';
        FittedCurve=FittedCurve.*A;
        PredictedResponse = PredictedResponse.*mean(A(:));
        ErrorVector = (FittedCurve - (zdata)).^2;
        %ErrorTotVector = (zdataNew- mean(mean(zdataNew))).^2;
        %ErrorTotVector = (zdataNew).^2;
        %ssetot = (sum(ErrorTotVector(:)));
        %U = (sum(ErrorVector(:)));
        tmp = zdata - FittedCurve;
        U = nanvar(tmp(:));
        varexp = 1 - (U./varY);

        
        
        
        
        
        
        
        
        
        %ErrorVector = ( (zdataNew) - FittedCurveNew ).^2;
        %ErrorTotVector = (zdataNew - mean(mean(zdataNew))).^2;
        %ErrorTotVector = zdataNew.^2;
        %ssetot = (sum(ErrorTotVector(:)));
        %sse = (sum(ErrorVector(:)));
        
    end




