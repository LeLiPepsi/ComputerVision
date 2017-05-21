%  Gruppennummer: M17
%  Gruppenmitglieder: Ye, Jiaojiao
%                     Li, Le

%% Hausaufgabe 1
%  Einlesen und Konvertieren von Bildern sowie Bestimmung von 
%  Merkmalen mittels Harris-Detektor. 
%% Bild laden
  Image = imread('szene.jpg');
  IGray = rgb_to_gray(Image);
%% Harris-Merkmale berechnen
%  tic;
Merkmale = harris_detektor(IGray,'Segment_length',5,'K',0.06,'Tau',3,'Min_dist',10,'Tile_size',[200 300],'N',50);
points = cornerPoints(Merkmale');        
figure;
imshow(IGray);
hold on;
plot(points);
title('harris_detektor');
%  toc;
