clc
clear
close all

%% Start: Sender
disp('Demo start...');

Image = imread("Goldhill.tif");
Messlength = 128;
QS = 30;

[H,W]=size(Image);
Center=[H/2,W/2];
[Maxorder,Capacity]=getMaxorder(Messlength);

SIFTPoints=detectSIFTFeatures(Image,"ContrastThreshold",0.04);

for i=1:size(SIFTPoints)
    P{i,1}=SIFTPoints(i).Scale;
    P{i,2}=SIFTPoints(i).Location;
    P{i,3}=SIFTPoints(i).Metric;
    P{i,4}=norm(P{i,2}-Center);
end

alpha=0.8;
for i=1:size(SIFTPoints)
    temp1(i,1)=P{i,3};
    temp2(i,1)=P{i,4};
    stdtemp1=temp1./max(temp1);% score of metric
    stdtemp2=1-temp2/Center(1);
    P{i,5}=1-stdtemp2(i);% score of distance
    P{i,6}=(1-alpha)*stdtemp1(i)+alpha*stdtemp2(i);% integrated score
end

for i=1:size(SIFTPoints)
    if P{i,5}<0.25
        P{i,7}=96;
    elseif (0.25<=P{i,5})&&(P{i,5}<0.5)
        P{i,7}=80;
    elseif (0.5<=P{i,5})&&(P{i,5}<0.75)
        P{i,7}=64;
    else
        P{i,7}=0;
    end
end

P_o=sortrows(P,6,'descend');

for i=1:size(P_o,1)
    sturctP(i).scale=P_o{i,1};
    sturctP(i).location=P_o{i,2};
    sturctP(i).metric=P_o{i,3};
    sturctP(i).dis2ori=P_o{i,4};
    sturctP(i).score4dis=P_o{i,5};
    sturctP(i).score=P_o{i,6};
    sturctP(i).radius=P_o{i,7};
end

sturctP_e=getNOP(sturctP);% select non overlapped area

for i=1:length(sturctP_e)
    temp4(i,1:2)=sturctP_e(i).location;
    temp5(i,1)=sturctP_e(i).radius;
end

[~,~,idx]=intersect(temp4,SIFTPoints.Location,'rows');
SIFTPoints_e=SIFTPoints(idx);

figure; % figure1
imshow(Image);
hold on;
plot(SIFTPoints_e,"ShowScale",false);
hold off;

int_loc=round(temp4);
int_rad=round(temp5);

Image_e=Image;
Mask=ones(size(Image));

for i=1:length(sturctP_e)

    temp7=Image_e(int_loc(i,2)-int_rad(i)+1:int_loc(i,2)+int_rad(i),...
        int_loc(i,1)-int_rad(i)+1:int_loc(i,1)+int_rad(i));% select the square of the circle area

    plate=Mask(int_loc(i,2)-int_rad(i)+1:int_loc(i,2)+int_rad(i),...
        int_loc(i,1)-int_rad(i)+1:int_loc(i,1)+int_rad(i));

    [temp8,mess,dq]=CoreEmbed(temp7,Maxorder,QS);
    [temp9,data,dr]=CoreExtract(temp7,temp8,Maxorder,QS,dq);

    plate=plateindicator(plate);

    Image_e(int_loc(i,2)-int_rad(i)+1:int_loc(i,2)+int_rad(i),...
        int_loc(i,1)-int_rad(i)+1:int_loc(i,1)+int_rad(i))=temp8;

    Mask(int_loc(i,2)-int_rad(i)+1:int_loc(i,2)+int_rad(i),...
        int_loc(i,1)-int_rad(i)+1:int_loc(i,1)+int_rad(i))=plate;

    structE(i).ori=temp7;
    structE(i).emd=temp8;
    structE(i).mes=mess; % embeded message
    structE(i).errq=dq; % eq

    structE(i).ext=temp9;
    structE(i).dat=data; % extracted message
    structE(i).errr=dr; % er

    structE(i).warning=abs(structE(i).dat-structE(i).mes);

end

% recover (also called pre-reconstruct)
Image_r=Image_e;
l=length(sturctP_e);
for i=1:length(sturctP_e)

    Image_r(int_loc(l-i+1,2)-int_rad(l-i+1)+1:int_loc(l-i+1,2)+int_rad(l-i+1),...
        int_loc(l-i+1,1)-int_rad(l-i+1)+1:int_loc(l-i+1,1)+int_rad(l-i+1))=...
        structE(l-i+1).ext-structE(l-i+1).errr;
end

% demonstrate embeded image
figure % figure2
subplot 131;imshow(Image);
subplot 132;imshow(Image_r);
subplot 133;imshow(25*(Image_e-Image));

% demoenstrate recovered image
figure % figure4
subplot 131;imshow(Image);
subplot 132;imshow(Image_r);
subplot 133;imshow(25*(Image_r-Image));

% obtain side info (feature_w)
SIFTPoints_w=detectSIFTFeatures(Image_e,"ContrastThreshold",0.04);
[feature_w,validpoint_w]=extractFeatures(Image_e,SIFTPoints_w);

%% Start: Receiver (Suppose Croptype 8 in paper happens)

I=imread("Goldhill_Crop_8.png");

SIFTPoints=detectSIFTFeatures(I,"ContrastThreshold",0.04);
[feature,validpoint]=extractFeatures(I,SIFTPoints);
[matchidx,matchscore]=matchFeatures(feature_w,feature,'MatchThreshold',1);
M_SIFTPoints_w=validpoint_w(matchidx(:,1));
M_SIFTPoints=validpoint(matchidx(:,2));

[T,inlieridx]=estimateGeometricTransform2D(M_SIFTPoints,M_SIFTPoints_w,"affine");
outputView=imref2d([512,512]);
I_f=imwarp(I,T,'bicubic','OutputView',outputView);

for i=1:length(int_loc)

    temp10=I_f(int_loc(i,2)-int_rad(i)+1:int_loc(i,2)+int_rad(i),...
        int_loc(i,1)-int_rad(i)+1:int_loc(i,1)+int_rad(i));

    [data_s]=RobustExtract(temp10,Maxorder,QS);

    structS(i).dat=data_s; % extracted message
    structS(i).warning=abs(structE(1).mes-structS(i).dat);
    structS(i).sum=sum(structS(i).warning);
    structS(i).BER=sum(structS(i).warning)/length(structE(1).mes);
end

fprintf('%s\n', sprintf('BER = %s', num2str(min([structS.BER]))));



