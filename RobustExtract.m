function [message_extracted_robust]=RobustExtract(Img_warp,K,Step)
plate=Img_warp;
[N, M]=size(plate);
x= -1+1/M:2/M:1-1/M;
y = 1-1/N:-2/N:-1+1/N;
[xx,yy]= meshgrid(x,y);
[~, r]=cart2pol(xx, yy);
plate(r>1)=0;

[moment_modified,~]=ZernikemomentsDe(plate,K);

[~,message_extracted_robust]=robustextracting(moment_modified,K,Step);

end