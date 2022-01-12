function [t, f] = plot_spec(S, n_s, win_size, win_shift, f_m)
  
  % INPUT
  % S = matriz de valores de STFT
  % n = longitud de la senial temporal [muestras]
  % win_size = tamanio ventana [muestras]
  % win_size = corrimiento ventana [muestras]
  % f_m = frecuencia de la senial [Hz]
  
  % OUTPUT
  % t =
  % f =
  
  solap = win_size-win_shift;
  nvent = floor((n_s-solap)/win_shift);
  dt = 1/f_m;
  % t = linspace(0,(n_s-1)*dt,nvent);
  t = 1:nvent;
  df = f_m/n_s;
  f = 0:df:f_m/2;
  S_out = abs(S(1:win_size/2+1,:)).^2;
  imagesc(t, f, 10*log10(S_out));
  axis xy;
  
end