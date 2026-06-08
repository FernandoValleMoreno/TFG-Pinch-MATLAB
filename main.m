%================================================================================= 
% SCRIPT PRINCIPAL: IMPORTACIÓN, EXTRACCIÓN DE DATOS Y EJECUCIÓN DEL DISEÑO DE RED
%=================================================================================

% 1. LIMPIEZA Y PARÁMETROS INICIALES
clear; close all; clc

deltaT = 68.5;

% 2. INTERACCIÓN CON EL USUARIO EN LA VENTANA DE COMANDO
% Se solicita el nombre de los archivos (se usa 's' para leer el texto sin necesidad de comillas)
name_in = input('Introduzca el nombre del archivo de entrada (ej. datos): ', 's');
name_out = input('Introduzca el nombre del archivo de exportacion (ej. resultados): ', 's');

% Se añade automáticamente la extensión .xlsx a los nombres introducidos
filenameimport = [name_in, '.xlsx'];
filenameexport = [name_out, '.xlsx'];

% 3. ARCHIVOS DE IMPORTACIÓN Y EXPORTACIÓN
% Lectura de la tabla preservando los nombres originales de las columnas
try
    Tabl = readtable(filenameimport, "VariableNamingRule","preserve");
catch
% Si este método falla se usa el método clásico para versiones antiguas de MATLAB)
    Tabl = readtable(filenameimport); 
end

% 4. EXTRACCIÓN DE LAS CORRIENTES CALIENTES
i = 1;
% El bucle lee fila por fila hasta encontrar una celda vacía (NaN) en la columna 2
while ~isnan(Tabl{i,2})
    IDh(i) = Tabl{i,1};   % ID de la corriente caliente
    Tinh(i)  = Tabl{i,2}; % Temperatura de entrada
    Touth(i) = Tabl{i,3}; % Temperatura de salida
    cph(i)   = Tabl{i,4}; % Capacidad calorífica (FCp)
    i = i+1;
end

% 5. EXTRACCIÓN DE LAS CORRIENTES FRÍAS
% Se inicia la lectura desde la fila posterior a la vacía ('i+1') hasta el final del archivo.
% Se emplea el apóstrofe (') para transponer los datos de vectores columna a vectores fila.
IDc = Tabl{i+1:end,1}';
Tinc = Tabl{i+1:end,2}';
Toutc = Tabl{i+1:end,3}';
cpc = Tabl{i+1:end,4}';

% 6. EJECUCIÓN Y EXPORTACIÓN
% Se llama a la función principal introduciendo los datos clasificados como argumentos
Tablexport = networkdesign(IDh, Tinh, Touth, cph, IDc, Tinc, Toutc, cpc, deltaT)

% Se exporta la tabla de resultados al archivo especificado en el punto 2
writetable(Tablexport,filenameexport)