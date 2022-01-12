function [S_r] = recons_spec_moving_avg(S_e, t_idx, a, p)
  
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
  t_idx = intersect(t_idx(t_idx>(a+p)), t_idx(t_idx<(length(S_e(1,:))-(a+p))));

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

    % ----------------- MEDIA MOVIL ----------------- %
    S1 = [];
    S2 = [];
    for m=t_idx(i)+k1+1:t_idx(i)+a+k2-1
      vantz = S_r(j,m:-1:m-p); % valores anteriores (incluyendo 0 si los hay)
      vant = vantz(vantz!=0); % se descartan los valores distintos de 0
      if (isempty(vant))
        vant = 0;
      end
      m = mean(vant); % media
      S1 = [S1 m];      
    end

    for m=t_idx(i)+a+k2-1:-1:t_idx(i)+k1+1
      vantz = S_r(j,m:m+p); % valores anteriores (incluyendo 0 si los hay)
      vant = vantz(vantz!=0); % se descartan los valores distintos de 0
      if (isempty(vant))
        vant = 0;
      end
      m = mean(vant); % media
      S2 = [m S2];      
    end
    
    S_r(j,t_idx(i)+k1+1:t_idx(i)+a+k2-1) = (S1+S2)./2;
    
    end
  end

end