function  Merkmale = harris_detektor(Image,varargin) 
% In dieser Funktion soll der Harris-Detektor implementiert werden, der
% Merkmalspunkte aus dem Bild extrahiert
%   Überprüfen, ob das Bilde im richtigen Format vorliegt
[rows columns channels]=size(Image);
Merkmale = [];
%% Input parser
P = inputParser;
% default
defaultSegment_length = 3;
defaultK = 0.05;
defaultTau  = 7;
defaultMin_dist = 20;
defaultTile_size = [200 300];
defaultN = 50;
% Liste der notwendigen Parameter
% Ein Bild als Input ist zwingend notwendig
P.addRequired('Image', @(x)isnumeric(x));
% Liste der optionalen Parameter
% Die Seitenlaenge fuer Bildsegment 
P.addOptional('Segment_length', defaultSegment_length, @(x) x >= 3 && mod(x,2))
% Das K % (default) 
P.addOptional('K', defaultK, @(x)isnumeric(x));
% Schwellenwert Tau 
P.addOptional('Tau', defaultTau, @(x) x>= 0);
% Der minimal Pixelabstand zweier Merkmale Min_dist 
P.addOptional('Min_dist',defaultMin_dist, @(x) x >= 1);
% Kachelgroesse Tile_size 
P.addOptional('Tile_size',defaultTile_size, @(x)(isscalar(x)&&min(rows,columns)>=x>0) || (isvector(x)&&rows>=x(1)>0&&0<x(2)<=columns) );
% Die maximale Anzahl der Merkmalen innerhalb einer Kachel N
P.addOptional('N',defaultN, @(x) x >= 1);% N tile_size 

% Lese den Input
P.parse(Image,varargin{:});
% Extrahiere die Variablen aus dem Input-Parser
Img     = P.Results.Image;
% Img     = Bild;    % Auch moeglich, da die Variable Bild der Funtion direkt uebergeben wurde
segment_length   = P.Results.Segment_length;
k   = P.Results.K;
tau = P.Results.Tau;
min_dist = P.Results.Min_dist;
tile_size = P.Results.Tile_size;
N = P.Results.N;
switch isvector(tile_size)
    case 1
        k_rows = tile_size(1);
        k_columns = tile_size(2);
    case 0
        k_rows = tile_size;
        k_columns = tile_size;
end

%%  Das Bild ist im falschen Format.
if channels == 3
    fprintf('Das Bild liegt im falschen Format vor.');         

else
%%  Gradiente zu berechnen
    [Fx,Fy] = sobel_xy(Img);
    Fxx = Fx .* Fx;
    Fyy = Fy .* Fy;
    Fxy = Fx .* Fy;
    % Fenster W zu berechnen
    % Fenster ist Gaussian Filter
    w = fspecial('gaussian',segment_length,4);
    Fxx_w = 1/segment_length^2*filter2(w,Fxx);
    Fyy_w = 1/segment_length^2*filter2(w,Fyy);
    Fxy_w = 1/segment_length^2*filter2(w,Fxy);
%     switch segment_length
%         case 3
%             w = [0.5 0.75 0.5;0.75 1 0.75;0.5 0.75 0.5];
%         case 5
%             w = [0.3 0.5 0.8 0.5 0.3;
%                  0.5 0.5 0.8 0.5 0.5;
%                  0.8 0.8 1   0.8 0.8;
%                  0.5 0.5 0.8 0.5 0.5;
%                  0.3 0.5 0.8 0.5 0.3];
%     end
%     w = 0.5*ones(segment_length);
%     w(segment_length*0.5+0.5,:) = 0.25*ones(1,segment_length); 
%     w(:,segment_length*0.5+0.5) = 0.25*ones(segment_length,1);
%     %Konvolution 
%     Fxx_w = 1/segment_length^2*conv2(Fxx,w,'same');
%     Fxy_w = 1/segment_length^2*conv2(Fxy,w,'same');
%     Fyy_w = 1/segment_length^2*conv2(Fyy,w,'same');
    % Determinante und Spur
    D =  Fxx_w .* Fyy_w - Fxy_w.^2;
    Tr2 = (Fxx_w + Fyy_w).^2;
    H = (D - k * Tr2);
%%   Suboptimale Methode
%     for i = 1:rows
%         for j = 1:columns
%             if H(i,j) >= tau
%                 Merkmale = [Merkmale [j i]'];
%             end
%         end
%     end
%%   in kleinere Kacheln unterteilen , maximale Anzahl von Merkmalen
    p = ceil(rows / k_rows);
    q = ceil(columns / k_columns);
    strongest = [];
    H_a = H;
    % Fuer jede Kachel, die N staerkeste Merkmale werden gespeichert
    for s = 1:p
       for r = 1:q
           Kachel = [];
           sz_kr = [];
           kr = [];kc = []; kv = [];B = [];
           Kachel = H((s-1)*k_rows+1:s*k_rows,(r-1)*k_columns+1:r*k_columns);
           %% Alle Merkmale in dieser Kachel zu berechnen
           % Die x/y-Koordinaten aller Merkmale in dieser Kachel 
           % und H-Wert von entsprechenden Merkmalen zu berechnen
           [kr kc kv] = find((Kachel >= tau) .* Kachel); 
           %% Die x/y-Koordinaten in gesamtem Bild werden umgerechnet
           kr = kr + (s-1) * k_rows;
           kc = kc + (r-1) * k_columns;
           sz_kr = length(kr);
           %% Alle Merkmale werden sortiert und N staerksten Merkmalen davon
           %  werden im Matrix 'strongest' gespeichert 
           B = sortrows([kr kc kv],3,'descend');          
           if sz_kr >= N
               strongest = [strongest B(1:N,:)'];               
           else
               strongest = [strongest B(1:sz_kr,:)'];
           end           
       end
    end
%% Abstand halten
    % Alle staerkste Merkmale sortieren 
%     str_sort = sortrows(strongest',3,'descend');
%     str_sort = str_sort'; % Dimension: 3*M [y;x;H]
    str_sort = strongest;
    min_str_sort = str_sort(3,end);
    H_b = zeros(rows,columns);    
    for q = 1:length(str_sort)
        H_b(str_sort(1,q),str_sort(2,q)) = H(str_sort(1,q),str_sort(2,q));
    end
    % Abstand
    l = min_dist * 2 + 1;
    H_c = ordfilt2(H_b,l^2, ones(l));
    H_d = (H_c == H_b) & (H_c >= min_str_sort); 
    [x y] = find(H_d);
    
end

Merkmale = [y';x'];

end