%  Gruppennummer:
%  Gruppenmitglieder:

%% Hausaufgabe 2
%  Bestimmung von Punktkorrespondenzen zwischen Merkmalspunkten einer Stereo
%  Aufnahme.

%  F�r die letztendliche Abgabe bitte die Kommentare in den folgenden Zeilen
%  enfernen und sicherstellen, dass alle optionalen Parameter �ber den
%  entsprechenden Funktionsaufruf fun('var',value) modifiziert werden k�nnen.


%% Bilder laden
Image1 = imread('szeneL.jpg');
IGray1 = rgb_to_gray(Image1);

Image2 = imread('szeneR.jpg');
IGray2 = rgb_to_gray(Image2);

%% Harris-Merkmale berechnen
Merkmale1 = harris_detektor(IGray1,'segment_length',9,'k',0.05,'min_dist',50,'N',20,'do_plot',false);
Merkmale2 = harris_detektor(IGray2,'segment_length',9,'k',0.05,'min_dist',50,'N',20,'do_plot',false);



%% Korrespondenzsch�tzung
 Korrespondenzen = punkt_korrespondenzen(IGray1,IGray2,Merkmale1,Merkmale2,'min_corr',0.99,'do_plot',true);