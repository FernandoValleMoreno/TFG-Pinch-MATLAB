%=================================================================================
% FUNCIÓN 'thermocascade': ANÁLISIS DE ENTALPÍAS, TEMPERATURA PINCH Y GRÁFICOS
%=================================================================================

function [Tph, Tpc, enth, Tempssort] = thermocascade(Tinh, Touth, cph, Tinc, Toutc, cpc, deltaT)
% Tph: Temperatura Pinch de las corrientes calientes (oC)
% Tpc: Temperatura Pinch de las corrientes frías (oC)
% enth: Valores de entalpía para la Curva Gran Compuesta (kJ/h)
% Tempssort: Valores de temperatura ordenados para la Curva Gran Compuesta (oC)
% Temperaturas en grados Celsius
% Capacidades caloríficas (FCp) en kJ/(h*oC)

% 1. VALIDACIÓN DE DATOS (MENSAJES DE ERROR)
if (length(Tinh) ~= length(Touth)) || (length(Tinh) ~= length(cph))
    error('La longitud de los vectores de corrientes calientes debe ser la misma')
end
if (length(Tinc) ~= length(Toutc))  || (length(Tinc) ~= length(cpc))
    error('La longitud de los vectores de corrientes frías debe ser la misma')
end
if sum(Tinh<Touth) ~= 0
    error('Se ha encontrado una corriente fría clasificada como caliente')
end
if sum(Tinc>Toutc) ~= 0
    error('Se ha encontrado una corriente caliente clasificada como fría')
end
if (sum(cph < 0) ~= 0) || (sum(cpc < 0) ~= 0)
    error('Los valores de FCp no pueden ser negativos')
end


% 2. DESPLAZAMIENTO Y ORDENACIÓN DE TEMPERATURAS
% Tinh: Temperatura de entrada de las corrientes calientes
Tinhd = Tinh - deltaT/2;  % Temperatura de entrada desplazada
% Touth: Temperatura de salida de las corrientes calientes
Touthd = Touth - deltaT/2;  % Temperatura de salida desplazada

% Tinc: Temperatura de entrada de las corrientes frías
Tincd = Tinc + deltaT/2;  % Temperatura de entrada desplazada
% Toutc: Temperatura de salida de las corrientes frías
Toutcd = Toutc + deltaT/2;  % Temperatura de salida desplazada

Nh = length(Tinhd); % Número de corrientes calientes
Nc = length(Tincd); % Número de corrientes frías

Tin = [Tinhd, Tincd];   % Vector unificado de entradas (primero calientes, luego frías)
Tout = [Touthd, Toutcd]; % Vector unificado de salidas (primero calientes, luego frías)

% Todas las temperaturas desplazadas se ordenan de mayor a menor para definir los intervalos
Tempssort = sort([Tinhd, Touthd, Tincd, Toutcd]','descend'); 

N = length(Tin);
Nsort = length(Tempssort);

% 3. EJECUCIÓN DEL CÁLCULO EN CASCADA
% Se genera la matriz lógica para determinar qué corrientes actúan en cada intervalo
temp_segm = logmatr(); 

% Se calculan las entalpías de la cascada
enth = enthalpycalc(temp_segm);

% Se determinan las temperaturas Pinch
[Tph, Tpc] = Pinch_Temp(enth);

disp(['Tph = ', num2str(Tph(1))])
disp(['Tpc = ', num2str(Tpc(1))])

% 4. REPRESENTACIÓN GRÁFICA: 
% FIGURA 1 (GRAN CURVA COMPUESTA)
figure(1)
plot(enth,Tempssort,'k-','LineWidth',5)
set(gca,'FontSize',15)
set(gca,'TickLabelInterpreter','latex')
set(gca, 'YTick', round(min(Tempssort)-5) ...
    :(round(max(Tempssort)+5)-round(min(Tempssort)-5))/10:round(max(Tempssort)+5))
grid on
xlim([min(enth),max(enth)])
ylim([min(Tempssort)-5,max(Tempssort)+5])
title('Gran Curva Compuesta','Fontsize',20,'interpreter','latex')
xlabel('$$ \Delta H \, (kJ/h) $$','Fontsize',15,'interpreter','latex')
ylabel('$$ T^{\ast} \, ( ^{\circ} C) $$','Fontsize',15,'interpreter','latex')

% Invocación de la función para trazar la Figura 2 (Diagrama T-H)
THdiagr(temp_segm) 

% 5. FUNCIONES ANIDADAS DE CÁLCULO

    % Creación de matriz lógica para segmentos de temperatura
    function temp_segm = logmatr()
        temp_segm = false(Nsort-1,N);
        
        for i = 1:Nsort-1
            Ti = Tempssort(i);
            Tim1 = Tempssort(i+1);
            for j = 1:Nh
                if (Tin(j) >= Ti) && (Tout(j) <= Tim1)
                    temp_segm(i,j) = true;
                end
            end
            for j = Nh+1:N
                if (Tin(j) <= Tim1) && (Tout(j) >= Ti)
                    temp_segm(i,j) = true;
                end
            end
        end
    end

    % Cálculo de la cascada de entalpías
    function enth = enthalpycalc(temp_segm)
        enth = zeros(Nsort,1); % Preasignación del vector de entalpías
        
        for i = 1:Nsort-1
            nop = temp_segm(i,1:end); % Vector lógico para un intervalo de temperatura dado
            cphtot = sum(cph(nop(1:Nh)));
            cpctot = sum(cpc(nop(Nh+1:N)));
            enth(i+1) = enth(i) - (cpctot-cphtot)*(Tempssort(i)-Tempssort(i+1));
        end
        
        % Se identifica el déficit máximo de entalpía y se repite el proceso para evitar valores negativos
        enth(1) = -min(enth);
        for i = 1:Nsort-1
            nop = temp_segm(i,1:end); 
            cphtot = sum(cph(nop(1:Nh)));
            cpctot = sum(cpc(nop(Nh+1:N)));
            enth(i+1) = enth(i) - (cpctot-cphtot)*(Tempssort(i)-Tempssort(i+1));
        end
        % Se corrigen posibles errores de redondeo de la máquina
        enth(abs(enth)<10^-10) = 0; 
    end

    % Determinación de la temperatura Pinch
    function [Tph, Tpc] = Pinch_Temp(enth)
        % El Pinch se localiza donde la entalpía de la cascada es cero
        Tp = Tempssort(abs(enth)<10^-10);
        Tph = Tp + deltaT/2;
        Tpc = Tp - deltaT/2;
    end

    % Cálculo y representación del diagrama Temperatura-Entalpía)
    function [Tdiag,Hdiag] = THdiagr(temp_segm)
        enthcold(1) = 0;
        enthhot(1) = 0;
        ihot = 1;
        icold = 1;
        
        for i = 1:Nsort-1
            nop = temp_segm(i,1:end); 
            
            if isempty(cpc(nop(Nh+1:N))) == 0
                cpctot = sum(cpc(nop(Nh+1:N)));
                Tcold(icold) = Tempssort(i) - deltaT/2;
                Tcold(icold+1) = Tempssort(i+1) - deltaT/2;
                enthcold(icold+1) = enthcold(icold) - cpctot*(Tempssort(i)-Tempssort(i+1));
                icold = icold + 1;
            end
            
            if isempty(cph(nop(1:Nh))) == 0
                cphtot = sum(cph(nop(1:Nh)));
                Thot(ihot) = Tempssort(i) + deltaT/2;
                Thot(ihot+1) = Tempssort(i+1) + deltaT/2;
                enthhot(ihot+1) = enthhot(ihot) - cphtot*(Tempssort(i)-Tempssort(i+1));
                ihot = ihot + 1;
            end
        end
        enthhot = enthhot + max(abs(enthhot));
        enthcold = enthcold + max(abs(enthcold));
       
        % FIGURA 2: DIAGRAMA TEMPERATURA-ENTALPÍA
        figure(2)
        plot(enthhot,Thot,'r','LineWidth',4)
        hold on
        plot(enthcold + enth(end),Tcold,'b','LineWidth',4)
        grid on
        ylabel('$$ T \, ( ^{\circ} C) $$','Fontsize',15,'interpreter','latex')
        set(gca,'FontSize',15)
        set(gca,'TickLabelInterpreter','latex')
        title('Diagrama Temperatura-Entalpia','Fontsize',20,'interpreter','latex')
        xlabel('$$ \Delta H \, (kJ/h) $$','Fontsize',15,'interpreter','latex')
    end
end