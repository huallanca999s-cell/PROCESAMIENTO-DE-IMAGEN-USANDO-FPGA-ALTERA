%% MATRIZ ESCALADA A GRISES 8x8
A_scaled = [  29   57   86  114  143  171  200  228;
              57   86  114  143  171  200  228  255;
              43   71  100 128  157  185  214  242;
              71  100 128  157  185  214  242  255;
               0   29   57   86  114  143  171  200;
              57   86  114  143  171  200  228  255;
              29   57   86  114  143  171  200  228;
              71  100 128  157  185  214  242  255];

[filas, columnas] = size(A_scaled);

%% MOSTRAR MATRIZ ORIGINAL COMO IMAGEN
figure;
imshow(A_scaled, []);
title('Matriz Original Escalada a Grises 0–255');
hold on;
for i = 1:filas
    for j = 1:columnas
        text(j, i, num2str(A_scaled(i,j)), 'Color', 'red', ...
            'FontSize', 12, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center');
    end
end
hold off;

%% FILTRO MEDIANA 3x3 CON 2 LINE BUFFERS (Valid-Only)
M = A_scaled; % Matriz de salida

line_buffer1 = zeros(1,columnas,'uint8'); % fila i-2
line_buffer2 = zeros(1,columnas,'uint8'); % fila i-1

for i = 1:filas
    current_row = A_scaled(i,:); % fila actual
    
    if i >= 3 % valid-only: desde la tercera fila
        for j = 2:columnas-1
            % Ventana 3x3 usando los line buffers
            ventana = [line_buffer1(j-1:j+1);
                       line_buffer2(j-1:j+1);
                       current_row(j-1:j+1)];
            M(i,j) = median(ventana(:)); % mediana
        end
    end
    
    % Actualizar buffers
    line_buffer1 = line_buffer2;
    line_buffer2 = current_row;
end

%% MOSTRAR MATRIZ FILTRADA COMO IMAGEN
figure;
imshow(M, []);
title('Filtro Mediana 3x3 con 2 line buffers (Valid-Only)');
hold on;
for i = 1:filas
    for j = 1:columnas
        text(j, i, num2str(M(i,j)), 'Color', 'red', ...
            'FontSize', 12, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center');
    end
end
hold off;
