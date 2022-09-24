function [res] = skinSeg(img,mode)
[n,m,~] = size(img);
dimg = double(img);
R = dimg(:,:,1);
G = dimg(:,:,2);
B = dimg(:,:,3);

if mode == "NormRGB" || mode == "Proposed"
    sumRGB = R+G+B;
    normR = R ./ sumRGB;
    normG = G ./ sumRGB;
    
    mask4 = zeros(n,m); mask4((normR./normG)>1.185) = 1;
    if mode == "NormRGB"
        mask5 = zeros(n,m); mask5((R.*G)./(sumRGB.*sumRGB)>0.112) = 1;
        mask6 = zeros(n,m); mask6((R.*B)./(sumRGB.*sumRGB)>0.107) = 1;
    end
end

if mode == "HS-CbCr" || mode == "HS" || mode == "Proposed"
    HSV = rgb2hsv(img);
    H = HSV(:,:,1);
    S = HSV(:,:,2);
    
    mask12 = zeros(n,m); mask12(S>=0.0754 & S<=0.6093)=1;
    mask13 = zeros(n,m); mask13(H<=0.1 & 0.01<=H) = 1;
end

if mode == "CbCr" || mode == "Proposed" || mode == "HS-CbCr"
    YCbCr = rgb2ycbcr(img);
    Cb = double(YCbCr(:,:,2));
    Cr = double(YCbCr(:,:,3));
    mask17 = zeros(n,m); mask17(Cb>77&Cb<127) = 1;
    mask18 = zeros(n,m); mask18(Cr>133&Cr<173) = 1;
end

if mode == "CbCr"
    mask = mask17 & mask18;
elseif mode == "NormRGB"
    mask = mask4 & mask5 & mask6;
elseif mode == "HS"
    mask = mask12 & mask13;
elseif mode == "HS-CbCr"
    mask = mask12 & mask13 & mask17 & mask18;
elseif mode == "Proposed"
    mask = mask4 & mask12 & mask13 & mask17 & mask18 ;
end

res = 255 * uint8(mask);
end
