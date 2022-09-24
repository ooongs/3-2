function mask = cluster2mask(idx,n,m,skin,bg,fg)

mask = reshape(idx,m,n)';
mask(mask==skin)=255;
mask(mask==bg)=0;
mask(mask==fg)=60;
mask = uint8(mask);
end

