function [S_r] = recons_spec_interp(S_e, t_idx, a, p)
  
  % INPUT
  % S_e = matriz de STFT con ceros en columnas donde habia teclas
  % t_idx = indices de tiempo t donde hay picos
  % a = ancho del pulso (cantidad de corrimientos a eliminar)
  % p = valores anteriores y posteriores para calcular la media
  
  % OUTPUT
  % S_r = matriz STFT regenerada
  
  % Nota: En caso de que suceda que la cantidad de muestras
  % faltantes no es de tamanio 'a', por ejemplo si justo detecto 2 pulsos
  % muy cercanos y trabaja con un mayor numero de ventanas con
  % valor 0), los indices k1 y k2 devuelven el tamanio del vector de
  % muestras faltantes y de esa manera se obtiene un mejor calculo

  S_r = S_e;

  for i=1:length(t_idx)    #Recorro las ventanas que tienen pulso

    for j=1:length(S_e(:,1))  #Recorro en frecuencias

    w1 = 0;
    k1 = -1;
    while (w1 == 0) % si el valor de w1=0 se itera hacia atras hasta encontrar uno que no lo sea
      w1 = S_e(j,t_idx(i)+k1);
      k1--;
    end

    k2 = 0;
    w2 = 0;
    while (w2 == 0) % si el valor de w2=0 se itera hacia adelante hasta encontrar uno que no lo sea
      w2 = S_e(j,t_idx(i)+a+k2);
      k2++;
    end

    % ----------------- INTERPOLACION ----------------- %     
    
    wr = linspace(w1,w2,a+k2+abs(k1)+1); % se interpola para obtener los valores que reemplazan la ventana del pulso
    S_r(j,t_idx(i)+k1:t_idx(i)+a+k2) = wr; 
    
    end
  end

end