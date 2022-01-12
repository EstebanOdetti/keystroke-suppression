function [S_r] = recons_spec_weight_avg(S_e, t_idx, c_w, alpha=1)
  
  % INPUT
  % S_e = matriz de STFT con ceros en columnas donde habia teclas
  % t_idx = indices de tiempo t donde hay picos
  % c_w = cantidad de vecinos de afuera a promediar
  % alpha = peso del promediado calculado
  
  % OUTPUT
  % S_r = matriz STFT regenerada
  
  S_r = S_e;
  t_idx = intersect(t_idx(t_idx>c_w), t_idx(t_idx<(length(S_e(1,:))-c_w)));
  
  for i=1:length(t_idx)
    c_f = 3; % cantidad de vecinos a eliminar
    w = alpha*[linspace(0,0.50,c_w) zeros(1,c_f) linspace(0.50,0,c_w)];
    n_w = length(w);
    v = [];
    for j=-round(n_w/2)+1:round(n_w/2)-mod(n_w,2)
      v = [v S_e(:,t_idx(i)+j)]; 
    end
    r = sum(v.*w,2); % columna a copiar
    % prom = sum(r)/length(r);
    % random=randn(1,length(r)); % media cero y varianza 1 
    % wn =random'.*prom; % Ruido
    for j=-round(c_f/2):round(c_f/2)-mod(c_f,2)
      S_r(:,t_idx(i)+j) = r;
    end
  end
end