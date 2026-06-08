%=================================================================================
% FUNCIÓN 'networkdesign': VALIDACIÓN DE DATOS, CÁLCULO PINCH Y DIAGRAMA DE MALLA
%=================================================================================
function Tablexport = networkdesign(IDh, Tinh, Touth, cph, IDc, Tinc, Toutc, cpc, deltaT)
% Temperaturas en grados Celsius
% Capacidades caloríficas (FCp) en kJ/(h*oC)

% Elimina celdas vacías (NaN) leídas accidentalmente del Excel
valid_h = ~isnan(Tinh);
IDh = IDh(valid_h); Tinh = Tinh(valid_h); Touth = Touth(valid_h); cph = cph(valid_h);

valid_c = ~isnan(Tinc);
IDc = IDc(valid_c); Tinc = Tinc(valid_c); Toutc = Toutc(valid_c); cpc = cpc(valid_c);

% 1. VALIDACIÓN DE DATOS (MENSAJES DE ERROR)
if (length(IDh) ~= length(Tinh)) || (length(IDh) ~= length(Touth)) || (length(IDh) ~= length(cph))
    error('La longitud de los vectores de calientes debe ser la misma')
end
if (length(IDc) ~= length(Tinc)) || (length(IDc) ~= length(Toutc))  || (length(IDc) ~= length(cpc))
    error('La longitud de los vectores de frías debe ser la misma')
end
if sum(Tinh<Touth) ~= 0
    error('Corriente fría clasificada como caliente')
end
if sum(Tinc>Toutc) ~= 0
    error('Corriente caliente clasificada como fría')
end
if (sum(cph < 0) ~= 0) || (sum(cpc < 0) ~= 0)
    error('Los valores de FCp no pueden ser negativos')
end

% 2. CÁLCULOS TERMODINÁMICOS Y ORDENACIÓN
[Tph, Tpc] = thermocascade(Tinh, Touth, cph, Tinc, Toutc, cpc, deltaT);

[Tinh,indh] = sort(Tinh,'descend');
Touth = Touth(indh);
cph = cph(indh);
deltahh = (Tinh-Touth).*cph; 
IDh = IDh(indh);

[Toutc,indc] = sort(Toutc,'descend');
Tinc = Tinc(indc);
cpc = cpc(indc);
deltahc = (Toutc-Tinc).*cpc; 
IDc = IDc(indc);

% 3. AGRUPACIÓN DE DATOS Y GENERACIÓN DE TABLA DE EXPORTACIÓN
griddiagrhot = [Tinh(:),Touth(:),cph(:),deltahh(:)];
griddiagrcold = [Tinc(:),Toutc(:),cpc(:),deltahc(:)];
griddiagr = [griddiagrhot;griddiagrcold];
ID = string([IDh, IDc]);

Tablexport = table([string(IDh), "COLD STREAMS", string(IDc)]', [Tinh, nan, Tinc]', [Touth, nan, Toutc]', ...
    [cph, nan, cpc]','VariableNames',{'ID', 'Tin_oC', 'Tout_oC', 'cp_kJperhoC'});

plotter()

% 4. FUNCIÓN ANIDADA DE REPRESENTACIÓN GRÁFICA
    function plotter()       
        
        % ***************************
        % FIGURA 3: DIAGRAMA DE MALLA
        % ***************************
        figure(3)
        clf
        set(gcf, 'Position', [100, 100, 1400, 800], 'Color', 'w') 
        ax = gca;
        
        set(ax, 'Position', [0.05, 0.15, 0.9, 0.7]); 
        hold on;
        
        shift = deltaT / 2;
        Yh_in = Tinh - shift;
        Yh_out = Touth - shift;
        Yc_in = Tinc + shift;
        Yc_out = Toutc + shift;
        
        Y_max = max([Yh_in(:); Yc_out(:)]);
        Y_min = min([Yh_out(:); Yc_in(:)]);
        Y_range = Y_max - Y_min;
        margin = Y_range * 0.05; 
        
        x_spacing = 3.5; 
        max_X = length(griddiagr(:,1)) * x_spacing;
        
        v_push = margin * 0.5; 
        
        % Márgenes para recuadro negro de la figura
        box_left = -x_spacing * 0.5;
        box_right = max_X + 5;
        
        y_grid_bottom = Y_min - margin * 2.0; 
        y_grid_top = Y_max + margin * 2.5;    
        
        % DIBUJO DE LA CUADRÍCULA
        % Se traza una línea vertical por cada corriente. La coordenada X se mantiene constante
        % mientras que la coordenada Y viaja desde el margen inferior hasta el superior.
        for X_grid = x_spacing : x_spacing : max_X
            plot([X_grid X_grid], [y_grid_bottom y_grid_top], '-', 'Color', [0.9 0.9 0.9], 'LineWidth', 0.5)
        end
        
        % DIBUJO DEL MARCO EXTERIOR NEGRO
        % Se define un polígono cerrado uniendo vértices. Empieza en la esquina inferior izquierda,
        % viaja a la inferior derecha, sube a la superior derecha, va a la superior izquierda y 
        % finalmente cierra volviendo al origen.
        plot([box_left, box_right, box_right, box_left, box_left], ...
             [y_grid_bottom, y_grid_bottom, y_grid_top, y_grid_top, y_grid_bottom], ...
             'k-', 'LineWidth', 1);
             
        % DIBUJO DE LA LÍNEA PINCH
        % Se traza una línea horizontal que cruza todo el marco (desde box_left hasta box_right).
        % La coordenada Y es constante y se sitúa en la temperatura Pinch desplazada (T_pinch_star).
        T_pinch_star = Tph(1) - shift; 
        plot([box_left, box_right], [T_pinch_star, T_pinch_star], 'k--', 'LineWidth', 2)
        
        txttick_h = ['$$T_{p,h} = ', num2str(Tph(1)),'^{\circ}C$$'];
        txttick_c = ['$$T_{p,c} = ', num2str(Tpc(1)),'^{\circ}C$$'];
        
        text(box_left + 0.5, T_pinch_star + margin*0.4, txttick_h, 'HorizontalAlignment', 'left', 'VerticalAlignment','bottom', 'FontSize', 12, 'interpreter', 'latex', 'Color', 'r', 'BackgroundColor', 'w');
        text(box_right - 0.5, T_pinch_star - margin*0.4, txttick_c, 'HorizontalAlignment', 'right', 'VerticalAlignment','top', 'FontSize', 12, 'interpreter', 'latex', 'Color', 'b', 'BackgroundColor', 'w');
        
        % DIBUJO DE CORRIENTES CALIENTES (Izquierda)
        for ih = 1:length(Tinh)
            X = ih * x_spacing;
            
            % 1. Cuerpo de la flecha: Línea vertical ('r-') desde la temperatura de entrada hasta la de salida.
            plot([X X], [Yh_in(ih) Yh_out(ih)], 'r-', 'LineWidth', 1.5)
            
            % 2. Punta de la flecha: Dibuja un marcador con forma de triángulo apuntando hacia abajo ('rv')
            % exactamente en la coordenada de salida para simular el sentido del enfriamiento.
            plot(X, Yh_out(ih), 'rv', 'MarkerFaceColor','w', 'MarkerSize', 7, 'LineWidth', 1.2)
            
            txt_in = ['$$', num2str(griddiagr(ih,1)), '^{\circ}C$$'];
            txt_out = ['$$', num2str(griddiagr(ih,2)), '^{\circ}C$$'];
            
            y_in_text = Yh_in(ih);
            align_in = 'middle';
            if abs(Yh_in(ih) - Yh_out(ih)) < margin * 1.5
                y_in_text = Yh_in(ih) + v_push;
                align_in = 'bottom';
            end
            
            text(X - 0.3, y_in_text, txt_in, 'HorizontalAlignment','right', 'VerticalAlignment',align_in, 'interpreter','latex', 'fontsize', 11, 'BackgroundColor', 'w');
            text(X - 0.3, Yh_out(ih) - v_push, txt_out, 'HorizontalAlignment','right', 'VerticalAlignment','top', 'interpreter','latex', 'fontsize', 11, 'BackgroundColor', 'w');
            
            if mod(ih, 2) == 0 
                y_fcp = y_grid_bottom - margin * 2.2; 
            else 
                y_fcp = y_grid_bottom - margin * 0.8; 
            end
            
            txt_data = ['$$FCp: ', num2str(griddiagr(ih,3), '%.2E'), '$$'];
            text(X, y_fcp, txt_data, 'interpreter','latex', 'fontsize', 11, 'HorizontalAlignment','center', 'VerticalAlignment','top');
        end
        
        % DIBUJO DE CORRIENTES FRÍAS (Derecha)
        for ic = ih+1:length(griddiagr(:,1))
            X = ic * x_spacing;
            idx_c = ic - ih;
            
            % 1. Cuerpo de la flecha: Línea vertical ('b-') desde la temperatura de entrada hasta la de salida.
            plot([X X], [Yc_in(idx_c) Yc_out(idx_c)], 'b-', 'LineWidth', 1.5)
            
            % 2. Punta de la flecha: Dibuja un marcador con forma de triángulo apuntando hacia arriba ('b^')
            % exactamente en la coordenada de salida para simular el sentido del calentamiento.
            plot(X, Yc_out(idx_c), 'b^', 'MarkerFaceColor','w', 'MarkerSize', 7, 'LineWidth', 1.2)
            
            txt_in = ['$$', num2str(griddiagr(ic,1)), '^{\circ}C$$'];
            txt_out = ['$$', num2str(griddiagr(ic,2)), '^{\circ}C$$'];
            
            y_in_text = Yc_in(idx_c);
            align_in = 'middle';
            if abs(Yc_in(idx_c) - Yc_out(idx_c)) < margin * 1.5
                y_in_text = Yc_in(idx_c) - v_push;
                align_in = 'top';
            end
            
            text(X + 0.3, y_in_text, txt_in, 'HorizontalAlignment','left', 'VerticalAlignment',align_in, 'interpreter','latex', 'fontsize', 11, 'BackgroundColor', 'w');
            text(X + 0.3, Yc_out(idx_c) + v_push, txt_out, 'HorizontalAlignment','left', 'VerticalAlignment','bottom', 'interpreter','latex', 'fontsize', 11, 'BackgroundColor', 'w');
            
            if mod(ic, 2) == 0 
                y_fcp = y_grid_bottom - margin * 2.2; 
            else 
                y_fcp = y_grid_bottom - margin * 0.8; 
            end
            
            txt_data = ['$$FCp: ', num2str(griddiagr(ic,3), '%.2E'), '$$'];
            text(X, y_fcp, txt_data, 'interpreter','latex', 'fontsize', 11, 'HorizontalAlignment','center', 'VerticalAlignment','top');
        end
        
        % Leyenda inferior y formato de ejes
        text(max_X / 2 + x_spacing / 2, y_grid_bottom - margin * 3.8, 'Unidades: $FCp$ en $kJ/(h\cdot^{\circ}C)$', ...
            'FontSize', 11, 'Interpreter', 'latex', 'Color', [0.4 0.4 0.4], ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
            
        xticks(x_spacing : x_spacing : max_X)
        xticklabels(ID); 
        ax.XAxisLocation = 'top'; 
        
        % CIERRE TOTAL DEL EJE
        xlim([box_left, box_right]) 
        ylim([y_grid_bottom - margin * 5.0, y_grid_top]) 
        
        set(ax, 'YColor', 'none', 'Clipping', 'off') 
        box off 
        grid off 
        
        set(ax,'FontSize',12, 'TickLabelInterpreter','latex')
        title('Diagrama de malla','Fontsize',22,'FontWeight','normal','interpreter','latex')
            
    end
end