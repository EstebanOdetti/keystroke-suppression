function [Ft] = keystroke_detect(S, t_m)
  
  % INPUT
  % S = matriz de valores de STFT
  % t_m = vecindad de t (e.g. [-2,2])
  
  % OUTPUT
  % Ft = vector con picos negativos en lugares donde hay teclas

  n_t = size(S,2); % cantidad de ventanas de tiempo de S
  S = abs(S); % rectifico S
  Ft = zeros(1,n_t); % inicializo Ft
  t_ext = max(abs(t_m))+1; % extremos a evitar de t
  for t=t_ext:n_t-t_ext
    M = length(t_m); % cantidad de vecinos a cada lado del frame
    a = 1/M; % peso de vecinos
    sum_k = 0;
    for k=1:length(S(:,t)) % recorre frecuencias en tiempo t
      sum_M = sum(a*S(k,t-t_m));
      std = (1/M)*(sum(S(k,t-t_m)))^2;
      sum_k += (1/std)*(S(k,t)-sum_M)^2;
    endfor
    Ft(t) = (-1/2)*sum_k;
  end
  
endfunction