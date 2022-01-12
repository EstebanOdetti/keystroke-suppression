function [S_e, t] = delete_peaks(S, t_idx, Ft, threshold, a, T, op_e = 1)
  
  % INPUT
  % S = matriz de valores de STFT
  % t_idx = indices de tiempo t donde hay picos
  % Ft = vector con picos negativos en lugares donde hay teclas
  % threshold = umbral de Ft
  % a = ancho del pulso (cantidad de corrimientos a eliminar)
  % T = ventanas temporales en espectrograma
  % op_e = tipo de eliminacion en espectograma (1 = asimetrica | 2 = simetrica)
  
  % OUTPUT
  % S_e = matriz de STFT con ceros en columnas donde habia teclas
  % t = muestra de tiempo en donde estan los pulsos
  
  S_e = S;
  
  if (op_e == 1) % eliminacion asimetrica
    
    t = [];
    I = [];
    for i=4:length(S_e(1,:))-4
      if (Ft(i)<threshold) % es un pulso
        I = [I i];
        i--;
        for j=i:i+a-1
         S_e(:,j) = 0;
        endfor
        i = j;
        endif
    endfor
    t = T(I);
    
  else  % eliminacion simetrica
    
    for i=1:length(t_idx) % recorro solo picos encontrados
      for j=-round(a/2):round(a/2)-mod(a,2)
        if (t_idx(i)+j > 0 && t_idx(i)+j < size(S,2))
          S_e(:,t_idx(i)+j) = 0;
        end
      endfor
    endfor
    
  end
  
end