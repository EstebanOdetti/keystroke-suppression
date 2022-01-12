function [s_out, S_out] = keystrokes_suppression(...
  s_in, f_m, win_size_t = 20, perc_shift = 0.50, win_type = 1, ...
  a = 3, threshold = -30, c_w = 8, alpha = 0.50, op_e = 1, op_r = 1, graf = 0)

  % INPUT:
  % s_in = senial de entrada
  % f_m = frecuencia de la senial [Hz]
  % win_size_t = tamanio ventana [ms]
  % perc_shift = porcentaje de solapamiento de ventanas
  % win_type = ventana para stft (1 = hanning)
  % a = cantidad de corrimientos a eliminar
  % threshold = umbral de Ft
  % c_w = cantidad de vecinos de afuera a promediar
  % alpha = peso del promediado calculado
  % op_r = regeneracion (1 = prom. pond. | 2 = interp. | 3 = media movil)
  % graf = graficar (0 = no | 1 = si)

  % OUTPUT:
  % s_out = senial de salida

  % ******************************************
  
  disp('Paso 1: Preprocesado de la senial (filtro PB)...');

  f_c = 8000; % frecuencia de corte [Hz]
  orden_filt = 40;
  [coef_b, coef_a] = butter(orden_filt, f_c/(f_m/2)); % filtro Butterworth
  s = filter(coef_b, coef_a, s_in);
  
  win_size = f_m*(win_size_t/1000); % tamanio ventana [muestras]
  win_shift = win_size*perc_shift; % corrimiento ventana [muestras]

  [S_in, ~] = stft(s_in, win_size, inc = win_shift, num_coef = win_shift, win_type);
  [S, ~] = stft(s, win_size, inc, num_coef, win_type);

  if (graf)
    figure('name','Espectogramas antes y despues del preprocesado');
    subplot(121);
    plot_spec(S_in, length(s), win_size, win_shift, f_m);
    title('Senial original'); xlabel('Tiempo [ventanas]'); ylabel('Frecuencias [Hz]');
    set(gca,'FontSize',20);
    subplot(122);
    plot_spec(S, length(s), win_size, win_shift, f_m);
    title('Senial filtrada con PB Butterworth'); xlabel('Tiempo [ventanas]'); ylabel('Frecuencias [Hz]');
    set(gca,'FontSize',20);
  end  
  
  % ******************************************
  
  disp('Paso 2: Deteccion y supresión de teclas...');

  t_m = [-2:2]; % ventanas a analizar alrededor de t

  [S, c] = stft(s, win_size, inc = win_shift, num_coef = win_shift, win_type);
  Ft = keystroke_detect(S, t_m);

  t_idx = find(Ft<threshold); % indices de tiempo t donde hay picos
  
  T = [0:win_shift-1:length(s)-1]; % ventanas temporales en espectrograma
  [S_e, ~] = delete_peaks(S, t_idx, Ft, threshold, a, T, op_e);

  if (graf)
    figure('name','F_t');
    hold on; stem(Ft);
    hold on; plot(1:length(Ft),threshold*ones(size(Ft)),'Linewidth',2,'m--');
    title('F_t'); xlabel('Ventanas'); ylabel('Magnitud');
    set(gca,'FontSize',20);
  end
  
  % ******************************************
  
  disp('Paso 3: Regeneracion de audio sin teclas...');

  t_idx = intersect(t_idx(t_idx>(a+2)), t_idx(t_idx<(length(S_e(1,:))-(a+2))));

  S_out = [];
  switch (op_r)
    case 1
      S_out = recons_spec_weight_avg(S_e, t_idx, c_w, alpha);
    case 2
      S_out = recons_spec_interp(S_e, t_idx, a);
    case 3
      p = 3; % valores anteriores y posteriores para calcular la media
      S_out = recons_spec_moving_avg(S_e, t_idx, a, p);
  end
  
  if (graf)
    figure('name','Dominio tiempo-frecuecia: espectrograma sin keystrokes y regeneracion');
    subplot(121);
    plot_spec(S_e, length(s), win_size, win_shift, f_m);
    title('Modificado con ceros en picos'); xlabel('Tiempo [ventanas]'); ylabel('Frecuencias [Hz]');
    set(gca,'FontSize',20);  
    subplot(122);
    plot_spec(S_out, length(s), win_size, win_shift, f_m);
    title('Reconstruccion'); xlabel('Tiempo [ventanas]'); ylabel('Frecuencias [Hz]');
    set(gca,'FontSize',20);
  end
  
  % ******************************************
  
  s_out = synthesis(S_out, c); % pasaje de T-F al dominio temporal
  
end