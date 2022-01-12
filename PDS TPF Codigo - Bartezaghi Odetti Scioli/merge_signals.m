function [s, w_k] = merge_signals(s_v, s_k, db)
  
  % INPUT
  % s_v = senial de voz limpia
  % s_k = sonido de teclas
  % db = cantidad de decibelios para 'ensuciar' la senial de voz
  
  % OUTPUT
  % s = senial de salida generada

  % pot_s = norm(s_v, 2)^2;
  % pot_n = norm(s_k, 2)^2;
  pot_s = sum(s_v.*s_v);
  pot_n = sum(s_k.*s_k);
  
  % SNR_db = 10*log10(pot_s/pot_n);
  % w_k = pot_s / (pot_n * 10^(SNR_db/10))
  w_k = sqrt(pot_s / (pot_n * 10^(db/10)));
  
  s = s_v + w_k*s_k;
  
endfunction