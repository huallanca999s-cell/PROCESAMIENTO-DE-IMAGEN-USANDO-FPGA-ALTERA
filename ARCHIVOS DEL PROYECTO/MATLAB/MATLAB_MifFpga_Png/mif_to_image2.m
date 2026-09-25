%==========================================================================
%                  CONVERSIÓN DE ARCHIVO .MIF A IMAGEN PNG
%==========================================================================
% Este script lee un archivo .mif (Memory Initialization File) y lo 
% reconstruye en una imagen PNG en escala de grises.
% 
% INSTRUCCIONES:
% 1. Asegúrate de que 'SALIDA.mif' exista en el mismo directorio.
% 2. Ejecuta el script completo en la ventana de comandos de MATLAB.
% --- Configuración de Parámetros ---
% Nombre del archivo MIF de entrada (CORREGIDO al nombre del archivo subido)
input_mif_filename = 'SALIDA.mif';
% Nombre del archivo de imagen PNG de salida
output_image_filename = 'imagen_reconstruida_204x204_2.png';
% Dimensiones de la Imagen (CORRECTAS: Raíz cuadrada de 41616 = 204)
FILAS = 204; 
COLUMNAS = 204; 
% --- Llamada a la Función Principal y Manejo de Errores ---
disp('===================================================');
disp('  Iniciando la conversión de Archivo MIF a Imagen');
disp('===================================================');
try
    generate_png_from_mif(input_mif_filename, output_image_filename, FILAS, COLUMNAS);
catch ME
    disp(' ');
    disp('!!! Error Crítico Durante la Ejecución !!!');
    disp(['Mensaje: ', ME.message]);
    disp(' ');
end
%==========================================================================
%                  FUNCIÓN PRINCIPAL (Implementación CORREGIDA)
%==========================================================================
function generate_png_from_mif(input_mif_filename, output_image_filename, image_rows, image_cols)
% Genera una imagen PNG a partir de los datos contenidos en el .mif.
    % 1. Apertura y Lectura del Archivo .mif
    fid = fopen(input_mif_filename, 'r');
    if fid == -1
        error('MATLAB:fileReadError', 'No se pudo abrir el archivo MIF: %s. Revise el nombre y la ruta.', input_mif_filename);
    end
    
    data_values = [];
    pixel_count = 0;
    
    while ~feof(fid)
        line = fgetl(fid); % Leer la siguiente línea
        line = strtrim(line);
        
        % Saltar líneas de encabezado, comentarios o BEGIN/END, etc.
        if isempty(line) || startsWith(line, '%') || contains(line, 'WIDTH') || contains(line, 'DEPTH') || ...
           contains(line, 'RADIX') || contains(line, 'CONTENT') || contains(line, 'BEGIN') || contains(line, 'END')
            continue;
        end
        
        % Buscar el patrón '[Dirección(es)] : [Valor];'
        parts = strsplit(line, ':');
        
        if length(parts) == 2
            addr_part = strtrim(parts{1}); % Contiene Dirección o Rango
            data_bin_part = strtrim(parts{2}); % Contiene el valor binario
            
            % 1. Parsear y convertir el valor de datos (BINARIO a DECIMAL)
            data_bin = strrep(data_bin_part, ';', ''); 
            data_bin = strtrim(data_bin);
            
            try
                % Uso de bin2dec para datos en BINARIO (según DATA_RADIX=BIN)
                data_dec = bin2dec(data_bin); 
            catch
                continue; % Saltar si la conversión de datos falla
            end
            
            % 2. Determinar el número de píxeles en esta línea (manejando rangos)
            num_pixels_in_line = 0;
            
            % Caso 1: Rango de direcciones (ej: [0001..103D])
            if startsWith(addr_part, '[') && endsWith(addr_part, ']')
                addr_range_str = strrep(strrep(addr_part, '[', ''), ']', '');
                range_parts = strsplit(addr_range_str, '..');
                
                if length(range_parts) == 2
                    try
                        % Las direcciones están en HEXADECIMAL (según ADDRESS_RADIX=HEX)
                        addr_start_dec = hex2dec(strtrim(range_parts{1}));
                        addr_end_dec = hex2dec(strtrim(range_parts{2}));
                        
                        % Calcular número de píxeles en el rango
                        num_pixels_in_line = addr_end_dec - addr_start_dec + 1;
                    catch
                        continue; % Saltar si el análisis del rango falla
                    end
                end
            % Caso 2: Dirección única (ej: 0000)
            else
                num_pixels_in_line = 1; 
            end
            
            % 3. Agregar el valor al vector de datos, repitiéndolo si es un rango
            if num_pixels_in_line > 0
                % Repetir el valor de datos por el número de píxeles en la línea
                new_values = repmat(data_dec, num_pixels_in_line, 1);
                data_values = [data_values; new_values];
                pixel_count = pixel_count + num_pixels_in_line;
            end
        end
    end
    fclose(fid);
    
    disp('--- Estado del Archivo MIF ---');
    disp(['  Archivo leído: ', input_mif_filename]);
    disp(['  Píxeles de datos leídos (total, incluyendo rangos): ', num2str(pixel_count)]);
    disp(['  Dimensiones esperadas: ', num2str(image_rows), ' x ', num2str(image_cols)]);
    disp('------------------------------');
    
    % 2. Reconstrucción de la Matriz de Imagen
    
    expected_pixels = image_rows * image_cols;
    
    if pixel_count ~= expected_pixels
        % Ahora este error debería corregirse si el archivo está completo
        error('MATLAB:PixelCountMismatch', 'El número de píxeles leídos (%d) NO coincide con el número de píxeles esperados (%d).', ...
            pixel_count, expected_pixels);
    end
    
    % Reconstruir la matriz (reshape opera por columna, coincidiendo con el orden MIF)
    img_matrix_column_major = reshape(data_values, image_rows, image_cols);
    
    % Convertir a uint8 (8 bits) para escala de grises
    img_out = uint8(img_matrix_column_major); 
    
    % 3. Guardar la Imagen de Salida
    imwrite(img_out, output_image_filename);
    disp(['✅ Imagen guardada exitosamente como: **', output_image_filename, '**']);
    disp('===================================================');
end