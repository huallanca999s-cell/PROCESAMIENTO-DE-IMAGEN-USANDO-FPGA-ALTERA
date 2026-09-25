function generate_png_from_mif(input_mif_filename, output_image_filename, image_rows, image_cols)
    fid = fopen("ave.png", 'r');
    if fid == -1
        error('No se pudo abrir el archivo MIF: %s', input_mif_filename);
    end

    % Crear vector de píxeles con ceros (para llenar posiciones faltantes)
    expected_pixels = image_rows * image_cols;
    data_values = zeros(expected_pixels, 1);  % Inicializa todos como 0

    line_count = 0;
    
    while ~feof(fid)
        line = strtrim(fgetl(fid));
        
        % Ignorar comentarios y encabezados
        if isempty(line) || startsWith(line, '%') || contains(line, 'WIDTH') || ...
           contains(line, 'DEPTH') || contains(line, 'RADIX') || contains(line, 'CONTENT') || ...
           contains(line, 'BEGIN') || contains(line, 'END')
            continue;
        end

        % Buscar patrón 'direccion : valor;'
        parts = strsplit(line, ':');
        if length(parts) == 2
            addr_str = strtrim(parts{1});
            data_hex = strrep(strtrim(parts{2}), ';', '');
            
            try
                address = str2double(addr_str) + 1; % +1 por índice MATLAB
                data_dec = hex2dec(data_hex);

                if address <= expected_pixels
                    data_values(address) = data_dec; % Colocar valor en dirección correcta
                end
                
                line_count = line_count + 1;
            catch
                continue;
            end
        end
    end

    fclose(fid);

    disp('--- Estado del Archivo MIF ---');
    disp(['  Líneas de datos leídas: ', num2str(line_count)]);
    disp(['  Tamaño total esperado: ', num2str(expected_pixels)]);
    disp('------------------------------');
    
    % Reconstruir la matriz
    img_matrix = reshape(data_values, image_rows, image_cols);

    % Convertir a imagen y guardar
    img_out = uint8(img_matrix);
    imwrite(img_out, output_image_filename);

    disp(['✅ Imagen guardada exitosamente como: ', output_image_filename]);
    disp('===================================================');
end
