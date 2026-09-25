% --- 1. CONFIGURACIÓN INICIAL (Asumimos que ya tienes una imagen ruidosa) ---

% Si no tienes la variable J de un script anterior, puedes cargar una imagen ruidosa:
% J = imread('imagen_con_ruido_sal_y_pimienta.png'); 
% J = im2double(J); % Asegurarse de que esté en formato double para el filtrado

% --- EJEMPLO COMPLETO: Generamos el ruido primero para tener 'J' ---
% Cargar la imagen base (reemplaza 'tu_imagen.jpg')
I = imread('imagen_con_ruido_sal_y_pimienta.png');
if size(I, 3) == 3
    I = rgb2gray(I);
end
I_double = im2double(I);
D = 0.05;
J = imnoise(I_double, 'salt & pepper', D); % J es la imagen con ruido
% ----------------------------------------------------------------------


% --- 2. APLICAR EL FILTRO DE MEDIANA ---

% [3 3] es el tamaño de la ventana del filtro. 
% Es el más común y efectivo para el ruido "sal y pimienta".
ventana_tam = [3 3]; 
K = medfilt2(J, ventana_tam);

% --- 3. EXPORTAR LA IMAGEN FILTRADA ---

nombre_archivo_salida = 'imagen_filtrada_con_mediana.png';
% La función imwrite guarda la matriz 'K' como un archivo PNG
imwrite(K, nombre_archivo_salida);
disp(['La imagen filtrada ha sido exportada como: ' nombre_archivo_salida]);


% --- 4. VISUALIZACIÓN DE RESULTADOS ---

figure;
subplot(1, 2, 1);
imshow(J);
title('Imagen Original con Ruido');
subplot(1, 2, 2);
imshow(K);
title('Imagen Filtrada (Filtro Mediana 3x3)');