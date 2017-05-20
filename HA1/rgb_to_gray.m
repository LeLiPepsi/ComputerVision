function [Gray_image] = rgb_to_gray(Image)
% Diese Funktion soll ein RGB-Bild in ein Graustufenbild umwandeln. Falls
% das Bild bereits in Graustufen vorliegt, soll es direkt zurueckgegeben werden.
    
% ob das Bild ein Graustufenbild ist.
[rows columns channels]=size(Image);
    
    % Das Bild ist nicht ein Graustufenbild.
    if (channels == 3)
        Gray_image=0.299*Image(:,:,1)+0.587*Image(:,:,2)+0.114*Image(:,:,3);
        
    % Das Bild ist bereits ein Graustufenbild.
    else
        Gray_image=Image;
               
    end
end
