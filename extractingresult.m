function [Img_precover]=extractingresult(Img_embed,mnt_modified,mnt_extracted,Maxorder)

moment_diff=mnt_extracted-mnt_modified;
[I_diff,~]=ZernikemomentsRe(Img_embed,moment_diff,Maxorder);
I_diff=real(I_diff);
Img_precover=double(Img_embed)+I_diff;
Img_precover(Img_precover<0)=0;
Img_precover(Img_precover>255)=255;
Img_precover=round(Img_precover);

end