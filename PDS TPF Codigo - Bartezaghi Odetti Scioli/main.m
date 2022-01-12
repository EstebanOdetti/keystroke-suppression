close all; clear all; format short; pkg load signal; clc; tic;

voices = [1]; % seniales de voz a probar (1 a 7)
keystrokes = [1]; % seniales de teclas a probar (1 a 7)
metodos = [1 2 3]; % metodos a probar (1 a 3)
snr_db = linspace(-20, 20, 3); % cantidades de decibelios
thresholds = linspace(-40, -80, 3); % umbrales de Ft
win_size_t = 20; % tamanio ventana [ms]
perc_shift = 0.50; % porcentaje de solapamiento de ventanas
win_type = 1; % ventana para stft (1 = hanning)
a = 3; % cantidad de corrimientos a eliminar
c_w = 6; % cantidad de vecinos de afuera a promediar
alpha = 0.50; % peso del promediado calculado
op_e = 1; % tipo de eliminacion en espectograma (1 = asimetrica | 2 = simetrica)

graf = 0; % graficar (0 = no | 1 = si)
listen = 0; % escuchar resultado (0 = no | 1 = si)

stoi = zeros(3, length(snr_db), length(thresholds));

for i_v=1:length(voices) % seniales de voces
  for i_k=1:length(keystrokes) % seniales de teclas
    for i_r=1:length(metodos) % metodos de regeneracion
      for i_snr=1:length(snr_db) % cantidades de decibelios
        for i_th=1:length(thresholds) % umbrales de Ft
          
          idx_v = voices(i_v); % indice de senial de voz
          idx_k = keystrokes(i_k); % indice de senial de teclas
          
          [s_v, f_m] = audioread(['dataset/trn/voice_h_',num2str(idx_v),'.wav']); % voz
          [s_k, ~] = audioread(['dataset/trn/keystrokes',num2str(idx_k),'.wav']); % teclas
          gt_k = load(['dataset/trn/gt_keystrokes',num2str(idx_k),'.txt']); % ground truth (tiempo exacto de teclas)

          s_v = s_v(1:f_m*5, 1); % corto a los 5 segundos
          s_k = s_k(1:f_m*5, 1); % corto a los 5 segundos

          db = snr_db(i_snr); % cantidad de decibelios para 'ensuciar' la senial de voz
          % ref: https://bit.ly/2UZZvfr
          % >40 dB: excelente senial (sin ruido) -> w_k ~ 0.01
          % 25-40 dB: muy buena senial -> w_k ~ 0.02
          % 15-25 dB: senial baja -> w_k ~ 0.15 
          % 10-15 dB: senial muy baja -> w_k ~ 0.25 
          % 5-10 dB: senial ruidosa -> w_k ~ 0.45 
          % 0 dB: senial muy ruidosa -> w_k ~ 1.01

          threshold = thresholds(i_th); % umbral de Ft
          op_r = metodos(i_r); % regeneracion (1 = prom. pond. | 2 = interp. | 3 = media movil)

          disp(['Voz ',num2str(idx_v),' - Teclas ',num2str(idx_k),' - SNR ',num2str(db), ' db - Metodo ',num2str(op_r),' - Umbral Ft ',num2str(threshold)]);
          
          [s, w_k] = merge_signals(s_v, s_k, db);
          [s_r, S_out] = keystrokes_suppression(s, f_m, win_size_t, perc_shift, win_type, a, threshold, c_w, alpha, op_e, op_r);
          
          if (graf)
%            figure('name','Senial en tiempo');
%            hold on; plot(s);
%            hold on; plot(s_k, 'm');
%            gt_m = round(gt_k*f_m); % ground truth (muestra exacta de teclas)
%            for i=1:length(gt_m)
%              hold on; plot([gt_m(i) gt_m(i)], [-1 1],'Linewidth',2,'ro--');
%            end
%            title('Original'); xlabel('Tiempo en muestras'); ylabel('Amplitud');
%            axis([1,length(s),-1,1]);
%            set(gca,'FontSize',20);
          end

          if (listen)
            sound(s, f_m);
            pause(1)
            sound(s_r, f_m);
          end
          
          s = s(1:length(s_r));
          stoi_value = stoi_bis(s, s_r, f_m);
          stoi(i_r, i_snr, i_th) = stoi_value;          
          disp(['stoi = ', num2str(stoi_value)]); disp('');
          
          % guardar senial
          f_m_save = 16000;
          s_r_resampled = resample(s_r, f_m_save, f_m);
          
          mkdir 'records';
          name_file = ['records/v',num2str(idx_v),'_k',num2str(idx_k),'_',num2str(db),'db','_u',num2str(threshold),'_m',num2str(op_r),'_stoi',sprintf('%.2f',stoi_value),'.wav'];
          audiowrite(name_file, s_r_resampled, f_m_save);
          
        end
      end
    end
  end
end

figure('name','Comparacion de metodos');
subplot(131);
for i=1:length(thresholds)
  hold on; plot(snr_db, stoi(1,:,i),'Linewidth',2);
end
legend('F_t = -55','F_t = -65','F_t = -75');
title('Metodo 1: weight avg'); xlabel('Decibelios'); ylabel('STOI value');
axis([snr_db(1),snr_db(end),0,1]);
set(gca,'FontSize',20);

subplot(132);
for i=1:length(thresholds)
  hold on; plot(snr_db, stoi(2,:,i),'Linewidth',2);
end
legend('F_t = -55','F_t = -65','F_t = -75');
title('Metodo 2: interp.'); xlabel('Decibelios'); ylabel('STOI value');
axis([snr_db(1),snr_db(end),0,1]);
set(gca,'FontSize',20);

subplot(133);
for i=1:length(thresholds)
  hold on; plot(snr_db, stoi(3,:,i),'Linewidth',2);
end
legend('F_t = -55','F_t = -65','F_t = -75');
title('Metodo 3: moving avg'); xlabel('Decibelios'); ylabel('STOI value');
axis([snr_db(1),snr_db(end),0,1]);
set(gca,'FontSize',20);

disp(''); toc;