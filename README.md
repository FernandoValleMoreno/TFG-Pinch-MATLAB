-----------------------------------
DISEÑO DE DIAGRAMAS PINCH EN MATLAB
-----------------------------------

Este repositorio contiene el código en MATLAB desarrollado para automatización del cálculo termodinámico y representaciones gráfica de la tecnología Pinch, como parte del Trabajo de Fin de Grado (TFG) de Fernando Valle Moreno.

📁 Estructura del Proyecto

--> `main.m`: 		Script principal o ejecutable. Se encarga de la interacción con el usuario, lectura de datos desde Excel y exportación de resultados.

--> `thermocascade.m`: 	Motor termodinámico. Ejecuta el balance en cascada, calcula las temperaturas Pinch y genera la Gran Curva Compuesta y el Diagrama Temperatura-Entalpía (Figuras 1 y 2).

--> `networkdesign.m`: 	Función de validación de datos, estructuración y generación del Diagrama de Malla de la red (Figura 3).

--> `datos/`: 		Carpeta destinada a almacenar los archivos de Excel con las corrientes de entrada.

--> `resultados/`: 	Carpeta donde se exportarán automáticamente las tablas de resultados.

🚀 Instrucciones de Uso

1. Colocar el archivo Excel con los datos de las corrientes en la carpeta `datos/` (directorio raíz).
2. Ejecutar el script `main.m` en MATLAB.
3. Introducir por consola en la ventana de comando el nombre del archivo de entrada (ej: `datos.xlsx`) y el nombre deseado para el archivo de salida.
4. El programa validará la información, realizará los cálculos y generará automáticamente 3 figuras clave del diseño de la red térmica.

⚙️ Requisitos
MATLAB (Compatible con versiones recientes. Se incluye manejo de excepciones para versiones antiguas en la lectura de tablas).

✒️ Créditos y Autoría
El núcleo lógico y de cálculo de este proyecto está basado en la obra original de D. Aslanis* El código presente en este repositorio ha sido adaptado y ampliado por Fernando Valle Moreno para satisfacer las necesidades de diseño gráfico (escalas, formato técnico de diagramas y resolución de solapamientos) exigidas en el marco del Trabajo de Fin de Grado.



Referencia del código base:
> D. Aslanis, «Process Integration», 2021, MATLAB Central File Exchange. Accedido: 8 de mayo de 2026. [En línea]. Disponible en: [MathWorks File Exchange](https://es.mathworks.com/matlabcentral/fileexchange/92528-process-integration?s_tid=srchtitle)
