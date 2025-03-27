function [Img_embeded,message,err_q]=CoreEmbed(Img,K,Step)
plate=Img;
[N, M]=size(plate);
x= -1+1/M:2/M:1-1/M;
y = 1-1/N:-2/N:-1+1/N;
[xx,yy]= meshgrid(x,y);
[~, r]=cart2pol(xx, yy);
plate(r>1)=0;

[moment_original,~]=ZernikemomentsDe(plate,K);

[moment_modified,~,message,err_q]=embedding(moment_original,K,Step);

[Img_embeded]=embeddingresult(plate,moment_original,moment_modified,K);

Img_embeded(r>1)=Img(r>1);

end