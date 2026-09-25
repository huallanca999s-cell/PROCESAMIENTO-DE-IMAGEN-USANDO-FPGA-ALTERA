# Procesamiento de Imágenes en FPGA mediante Filtro de Ventana

Este repositorio contiene la implementación en hardware para el procesamiento digital de imágenes en tiempo real utilizando una FPGA. El proyecto implementa un algoritmo de filtrado espacial por matriz/ventana (kernel) sobre una arquitectura de hardware descripta en VHDL/Verilog y sintetizada mediante Intel Quartus Prime.

---

## Especificaciones Técnicas y Herramientas

* **Entorno de Desarrollo:** Intel Quartus Prime Lite
* **Herramienta de Simulación:** ModelSim
* **Lenguaje de Descripción de Hardware:** VHDL
* **Target Device:** FPGA Intel/Altera Cyclone IV EP4CE115F29C7
* **Operación de Procesamiento:** Filtro mediana 3x3

---

## Arquitectura del Sistema

El sistema recibe un flujo de datos de imagen pixel por pixel y utiliza **buffers de línea (Line Buffers)** y registros en cascada para conformar la ventana espacial requerida para la convolución en hardware.

1. **Recepción y Buffering:** Captura de píxeles en escala de grises y almacenamiento temporal para acceso paralelo a la vecindad $3 \times 3$.
2. **Unidad del Filtro (Kernel):** Arreglo de multiplicadores y acumuladores para aplicar los coeficientes del filtro.
3. **Control de Desbordamiento y Normalización:** Ajuste de los valores resultantes al rango de píxeles ($0 - 255$).
4. **Salida:** Generación de la imagen filtrada sincronizada con la señal de reloj principal.

---

## 📊 Resultados y Simulación

Aquí se presentan las capturas de pantalla de las simulaciones temporales en ModelSim y los resultados del procesamiento de imagen (Original vs. Filtrada):

<p align="center">
  <img src="CAPTURAS/capturasimu.png" alt="Simulación en ModelSim" width="800">
  <br>
  <em>Figura 1: Simulación del timing y sincronización de señales en ModelSim.</em>
</p>

<p align="center">
  <img src="CAPTURAS/resultado.png" alt="Resultado del Filtro de Imagen" width="700">
  <br>
  <em>Figura 2: Comparativa de la imagen original y el resultado tras aplicar el filtro de ventana en FPGA.</em>
</p>

*(Asegúrate de ajustar las rutas de las imágenes en las etiquetas `<img>` según tus carpetas).*

---

## Autoría y Créditos

Este proyecto fue desarrollado en el entorno académico como parte del trabajo de diseño digital avanzado en FPGA.

* **Autores:**
  * Erick Isaias Huallanca Perez
  * Po Cheng Chien Chang
* **Contribuciones Clave:**
  * Diseño de la arquitectura de hardware y búferes de línea.
  * Implementación y síntesis de la lógica en Intel Quartus.
  * Verificación mediante testbenches y análisis de timing en ModelSim.
