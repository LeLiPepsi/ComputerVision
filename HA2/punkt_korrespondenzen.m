function [Korrespondenzen] = punkt_korrespondenzen(I1,I2,Mpt1,Mpt2,varargin)

% In dieser Funktion sollen die extrahierten Merkmalspunkte aus einer
% Stereo-Aufnahme mittels NCC verglichen werden um Korrespondenzpunktpaare
% zu ermitteln.
%% Inuputpauser
P = inputParser;
% Liste der optionalen Parameter
% Laenge des quadratischen Fensters && mod(x,2)?????
P.addOptional('window_length', 15, @isnumeric )
% Minimaler Wert von NCC
P.addOptional('min_corr', 0.6, @isnumeric);
% Plot ein/aus
P.addOptional('do_plot', false, @islogical);
% Lese den Input
P.parse(varargin{:});
% Extrahiere die Variablen aus dem Input-Parser
window_length   = P.Results.window_length;
min_corr        = P.Results.min_corr;
do_plot         = P.Results.do_plot;
%% Vorbereitung
Id1 = im2double(I1);
Id2 = im2double(I2);
Korrespondenzen = [];
[r1 c1] = size(Mpt1);
[r2 c2] = size(Mpt2);
bild_segm_1 = zeros(window_length);% Bildsegment in Bild 1
bild_segm_2 = zeros(window_length);% Bildsegment in Bild 2
NCC_vec = zeros(c2,1);
%% Fuer jeder p1 aus Mpt1, suche p2 aus Mpt2
% Ergebnisse werden in Korrespondenzen gespeichert.
for i = 1 : c1   
    % Behandlung von Punkten am Rand des Bildes 1 
    x1 = Mpt1(1,i);
    y1 = Mpt1(2,i);
    if ( x1 <= (0.5*(window_length - 1)) )||( y1 <= (0.5*(window_length - 1)) ) ...
            || ( x1 > (size(I1,2)-0.5*(window_length - 1))) || (y1 > (size(I1,1)-0.5*(window_length - 1)))
        continue;
    end
    bild_segm_1 = Id1(y1-0.5*(window_length-1):y1+0.5*(window_length-1),x1-0.5*(window_length-1):x1+0.5*(window_length-1));
    ein = ones(window_length,1);
    % Normierung des Bildsegments in Bild 1
    mean_1 = ein * ein'* bild_segm_1 * ein * ein' / window_length^2;
    %mean_11 = ein * mean2(bild_segm_1) * ein';
    bild_zero_mean_1 = bild_segm_1 - mean_1;
    sigma_1 = sqrt(trace(bild_zero_mean_1' * bild_zero_mean_1) / (window_length^2 - 1));
    %sigm1_11 = std2(bild_zero_mean_1);
    bild_segm_1_norm = (bild_zero_mean_1) / sigma_1;
    for j = 1 : c2
    % Behandlung von Punkten am Rand des Bildes 2    
        x2 = Mpt2(1,j);
        y2 = Mpt2(2,j);
        if ( x2 <= (0.5*(window_length - 1)) )||( y2 <= (0.5*(window_length - 1)) ) ...
            || ( x2 > (size(I2,2)-0.5*(window_length - 1))) || (y2 > (size(I2,1)-0.5*(window_length - 1)))
        continue;
        end
        bild_segm_2 = Id2(y2-0.5*(window_length-1):y2+0.5*(window_length-1),x2-0.5*(window_length-1):x2+0.5*(window_length-1));
    % Normierung des Bildsegments in Bild 2 
        mean_2 = ein * ein'* bild_segm_2 * ein * ein' / window_length^2;
        bild_zero_mean_2 = bild_segm_2 - mean_2;
        sigma_2 = sqrt(trace(bild_zero_mean_2' * bild_zero_mean_2) / (window_length^2 - 1));
        bild_segm_2_norm = (bild_zero_mean_2) / sigma_2;
    % Berechnung der NCC der beiden Bildsegmente
        As = reshape(bild_segm_1_norm,[],1);
        Bs = reshape(bild_segm_2_norm,[],1);
        tr = As' * Bs;
        NCC_vec(j) = tr / (window_length^2 -1);
    end
    % Finden den p2, der NCC maximiert
    [M, I] = max(NCC_vec(:));
    % Vergleichen mit min_corr, gefundene Punktpaare wird gespeichert
    if M <= min_corr
        ;
    else
        Korrespondenzen = [Korrespondenzen [x1;y1;Mpt2(1,I);Mpt2(2,I)]];
    end
end
%% Visualisierung
    if do_plot
%         figure  
%         colormap('gray')
%         subplot(1,2,1);
%         imagesc(I1);
%         hold on;
%         plot(Korrespondenzen(1,:), Korrespondenzen(2,:), 'gs');
%         axis('off');
%         subplot(1,2,2);
%         imagesc(I2);
%         hold on;
%         plot(Korrespondenzen(3,:), Korrespondenzen(4,:), 'rs');
%         axis('off');
%         figure;
%         ax = axes;
        matchedPoints1 = Korrespondenzen(1:2,:)';
        matchedPoints2 = Korrespondenzen(3:4,:)';
        showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2,'montage','PlotOptions',{'ro','gx','--y'});
    end
    
end


