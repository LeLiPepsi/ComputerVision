function [Fx,Fy] = sobel_xy(Image)
% In dieser Funktion soll das Sobel-Filter implementiert werden, welches
% ein Graustufenbild einliest und den Bildgradienten in x- sowie in
% y-Richtung zurueckgibt.
[sz_x,sz_y]=size(Image);
temp=zeros(sz_x+2,sz_y+2);
Image = double(Image);
sx=1/8*log(2)*([1 0 -1;2 0 -2;1 0 -1]);% horizontaler Sobel-Filter
sy=1/8*log(2)*([1 2 1;0 0 0;-1 -2 -1]);% vertikaler Sobel-Filter
% Behandlung von Randpixedln
temp1=[Image(1,:);Image;Image(sz_x,:)];
temp=[temp1(:,1) temp1 temp1(:,sz_y)];
% Konvolution
tempx = (conv2(temp,sx,'same'));
tempy = (conv2(temp,sy,'same'));
Fx = tempx(2:sz_x+1,2:sz_y+1);
Fy = tempy(2:sz_x+1,2:sz_y+1);
end

