%  Gruppennummer:
%  Gruppenmitglieder:

%% Hausaufgabe 1
%  Einlesen und Konvertieren von Bildern sowie Bestimmung von 
%  Merkmalen mittels Harris-Detektor. 

%  Fuer die letztendliche Abgabe bitte die Kommentare in den folgenden Zeilen
%  enfernen und sicherstellen, dass alle optionalen Parameter fuer den
%  entsprechenden Funktionsaufruf fun('var',value) modifiziert werden koennen.

%% Bild laden
  Image = imread('szene.jpg');
  IGray = rgb_to_gray(Image);
%% Harris-Merkmale berechnen
%  tic;
%  Merkmale = harris_detektor(IGray,'do_plot',true);
Merkmale = harris_detektor(IGray,'Segment_length',5,'K',0.06,'Tau',3,'Min_dist',10,'Tile_size',[200 300],'N',50);
points = cornerPoints(Merkmale');        
%  die Bilde zu zeigen und Merkmalspunkte zu markieren 
figure;
imshow(IGray);
hold on;
plot(points);
title('harris_detektor');
%  toc;
