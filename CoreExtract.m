function [Img_precover,message_extracted,err_r]=CoreExtract(Img,Img_embeded,K,Step,err_q)
plate=Img_embeded;
[N, M]=size(plate);
x= -1+1/M:2/M:1-1/M;
y = 1-1/N:-2/N:-1+1/N;
[xx,yy]= meshgrid(x,y);
[~, r]=cart2pol(xx, yy);
plate(r>1)=0;

[moment_modified,~]=ZernikemomentsDe(plate,K);

[moment_extracted,message_extracted]=extracting(moment_modified,K,Step,err_q);

[Img_precover]=extractingresult(plate,moment_modified,moment_extracted,K);

err_r=Img_precover-double(Img);
err_r(r>1)=0;

Img_precover(r>1)=uint8(Img_embeded(r>1));

end