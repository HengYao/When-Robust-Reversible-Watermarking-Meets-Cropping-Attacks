function [plate]=plateindicator(Img)

plate=ones(size(Img));
[N, M]=size(plate);
x= -1+1/M:2/M:1-1/M;
y = 1-1/N:-2/N:-1+1/N;
[xx,yy]= meshgrid(x,y);
[~, r]=cart2pol(xx, yy);
plate(r<=1)=0;
plate(r>1)=Img(r>1);

end