function [Img_embed]=embeddingresult(Img,mnt_original,mnt_modified,K)

moment_diff = mnt_modified - mnt_original;
[I_diff,~]=ZernikemomentsRe(Img,moment_diff,K);
I_diff=real(I_diff);
Img_embed=double(Img)+I_diff;
Img_embed(Img_embed<0)=0;
Img_embed(Img_embed>255)=255;
Img_embed=round(Img_embed);

end