# Keystroke suppression 

![Generic badge](https://img.shields.io/badge/made%20with-octave%206.2.0-blue) 

Supresión de ruidos impulsivos en audio de voz utilizando la Transformada de Fourier de Tiempo Corto (STFT). Trabajo presentado como proyecto final para la materia Procesamiento Digital de Señales junto a mis compañeros Sebastian Scioli y Catriel Bartezaghi.

## Resumen 
La pandemia por COVID-19 acentuó el uso de la virtualidad haciendo que ésta se introduzca en casi todos los aspectos de la vida. Muchos trabajos e incluso clases comenzaron necesariamente a realizarse de manera virtual, lo cual trajo aparejado algunos problemas como ruidos molestos de fondo, entre los que se destaca el de las teclas. En este trabajo se propone eliminar el ruido impulsivo de un teclado presente en las videoconferencias. Los pasos básicos son detectar la presencia de teclas en el audio, eliminarlas y, por último, reconstruir el tramo eliminado. La mayor parte del tiempo se trabaja en el dominio tiempo-frecuencia. La salida del sistema es una señal en el dominio del tiempo sin la presencia del ruido producido por el tecleo.

## Programacion 
- Octave 6.2.0 

## Dataset 
Los dataset están conformados por un conjunto de audios grabados por los autores. 

## Algunos resultados: [PESQ](https://en.wikipedia.org/wiki/Perceptual_Evaluation_of_Speech_Quality)

| SNR (dB) | Metodo 1 | Metodo 2 | Metodo 3|
| ------ | ------ | ------ | ------ |
| -20  | 0.391 |0.399 |0.407|
| 0 | 0.667 | 0.664 |0.670 |
| 20 | 0.718 |0.707 |0.763 |

