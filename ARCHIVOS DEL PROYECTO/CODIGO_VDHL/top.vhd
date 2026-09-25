-- top.vhdl
-- Módulo principal de integración, control y buffer de líneas.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        CLK_50      : in  std_logic; -- Clock de la DE2-115
        RESET_n     : in  std_logic; -- Reset asíncrono (activo bajo)
        -- Señales de E/S de la placa (ej: LEDs para DONE)
        LED         : out std_logic_vector(7 downto 0)
    );
end entity top;

architecture structural of top is

    -- --- Parámetros de la Imagen (204x204) ---
    constant C_FILAS : integer := 204;
    constant C_COLS  : integer := 204;
    constant C_DEPTH : integer := C_FILAS * C_COLS; -- 41616 píxeles
    constant C_ADDR_BITS : integer := 16; -- ceil(log2(41616)) = 16
    constant C_COL_ADDR_BITS : integer := 8; -- ceil(log2(204)) = 8
    constant C_DELAY : integer := C_COLS + 1; -- Retraso del pipeline (2 líneas + 2 píxeles)

    -- --- Señales de Memoria ---
    signal addr_read, addr_write : std_logic_vector(C_ADDR_BITS-1 downto 0);
    signal data_rom_out, data_ram_in : std_logic_vector(7 downto 0); -- ROM (Lectura), RAM (Escritura)
    signal data_ram_out : std_logic_vector(7 downto 0); 
    signal we_ram        : std_logic; -- Habilitar escritura RAM (se conecta a wren)

    -- --- Señales de Control de Píxeles ---
    signal pixel_count   : integer range 0 to C_DEPTH;
    signal col_address   : std_logic_vector(C_COL_ADDR_BITS-1 downto 0);
    
    -- --- Señales de Line Buffer (LB) ---
    signal lb_addr      : std_logic_vector(C_COL_ADDR_BITS-1 downto 0);
    signal lb_we        : std_logic; -- Habilitador de escritura para ambos Line Buffers
    signal lb1_out, lb2_out : std_logic_vector(7 downto 0);
    
    -- --- Señales para la Ventana 3x3 (Píxeles del Kernel) ---
    signal P1, P2, P3, P4, P5, P6, P7, P8, P9 : std_logic_vector(7 downto 0); 
    
    -- --- Señales del Filtro ---
    signal mediana_result : std_logic_vector(7 downto 0);
    signal start_processing : std_logic; 

    -- --- Declaración de Componentes ---

    component median9 is
        port ( P1, P2, P3, P4, P5, P6, P7, P8, P9 : in  std_logic_vector(7 downto 0);
               Mediana_Out                        : out std_logic_vector(7 downto 0) );
    end component median9;

    component ROM_IMG is
        port ( address : in  std_logic_vector(C_ADDR_BITS-1 downto 0); clock   : in  std_logic;
               q       : out std_logic_vector(7 downto 0) );
    end component ROM_IMG;

    -- ***************************************************************
    -- Componente RAM_IMG corregido: 'we' cambiado a 'wren' 
    -- (Asumiendo que RAM_IMG es un IP Core o un archivo con ese nombre de puerto)
    -- ***************************************************************
    component RAM_IMG is
        port ( address : in  std_logic_vector(C_ADDR_BITS-1 downto 0); 
               data    : in  std_logic_vector(7 downto 0);
               wren    : in  std_logic;              -- ¡CORRECCIÓN AQUÍ!
               clock   : in  std_logic; 
               q       : out std_logic_vector(7 downto 0) );
    end component RAM_IMG;

    -- Componente del Line Buffer (Usar IP Core de Quartus)
    component line_buffer_ram is
        generic ( COLUMNS : integer := 204; ADDR_WIDTH : integer := 8 );
        port ( clk    : in  std_logic; reset_n: in  std_logic; data_in : in  std_logic_vector(7 downto 0);
               write_en: in  std_logic; address : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
               data_out: out std_logic_vector(7 downto 0) );
    end component line_buffer_ram;

begin
    -- 1. Instanciación del Filtro de Mediana
    MEDIANA_UNIT : median9  
    port map ( P1 => P1, P2 => P2, P3 => P3, P4 => P4, P5 => P5, P6 => P6, 
               P7 => P7, P8 => P8, P9 => P9, Mediana_Out => mediana_result );
    
    -- 2. Instanciación de las Memorias (ROM/RAM)
    ROM_INST : ROM_IMG port map ( address => addr_read, clock => CLK_50, q => data_rom_out );
    
    -- ***************************************************************
    -- Instanciación RAM_INST corregida: 'we' cambiado a 'wren'
    -- ***************************************************************
    RAM_INST : RAM_IMG 
    port map ( address => addr_write, data => mediana_result, 
               wren => we_ram, -- ¡CORRECCIÓN AQUÍ!
               clock => CLK_50, 
               q => data_ram_out );

    -- 3. Instanciación de los Line Buffers
    -- LB1 almacena la línea L-1 (el dato de L-2 sale de LB2)
    LB_1 : line_buffer_ram 
    generic map ( COLUMNS => C_COLS, ADDR_WIDTH => C_COL_ADDR_BITS )
    port map ( clk => CLK_50, reset_n => RESET_n, data_in => data_rom_out, 
               write_en => lb_we, address => lb_addr, data_out => lb1_out );
    
    -- LB2 almacena la línea L-2 (el dato de L-3 sale de LB1)
    LB_2 : line_buffer_ram 
    generic map ( COLUMNS => C_COLS, ADDR_WIDTH => C_COL_ADDR_BITS )
    port map ( clk => CLK_50, reset_n => RESET_n, data_in => lb1_out, -- La entrada es la salida del LB1 (L-1)
               write_en => lb_we, address => lb_addr, data_out => lb2_out );

    -- 4. Proceso de Control de Direcciones y Pipeline
    process(CLK_50, RESET_n)
        variable col_count : integer range 0 to C_COLS; -- Contador local de columna
    begin
        if RESET_n = '0' then
            pixel_count <= 0;
            addr_read   <= (others => '0');
            addr_write  <= (others => '0');
            we_ram      <= '0';
            lb_we       <= '0';
            start_processing <= '0';
            col_count := 0;
            lb_addr     <= (others => '0');
            
            -- Resetear Buffers de Desplazamiento
            P1 <= (others => '0'); P2 <= (others => '0'); P3 <= (others => '0');
            P4 <= (others => '0'); P5 <= (others => '0'); P6 <= (others => '0');
            P7 <= (others => '0'); P8 <= (others => '0'); P9 <= (others => '0');
            LED <= (others => '0');
            
        elsif rising_edge(CLK_50) then
            
            -- Lógica de Lectura y Contadores
            if pixel_count < C_DEPTH then
                addr_read <= std_logic_vector(to_unsigned(pixel_count, C_ADDR_BITS));
                pixel_count <= pixel_count + 1;
                
                -- Contador de Columna
                if col_count = C_COLS - 1 then
                    col_count := 0;
                else
                    col_count := col_count + 1;
                end if;
                
                -- Dirección de Line Buffer (para leer y escribir el mismo índice)
                lb_addr <= std_logic_vector(to_unsigned(col_count, C_COL_ADDR_BITS));
                lb_we <= '1'; -- Siempre escribimos el píxel leído en el Line Buffer

                -- --- Lógica de Desplazamiento del Buffer de Ventana 3x3 ---
                -- Píxeles de la Fila Actual (L)
                P3 <= P2;
                P2 <= P1;
                P1 <= data_rom_out; -- Nuevo píxel leído de la ROM

                -- Píxeles de la Fila Anterior (L-1)
                P6 <= P5;
                P5 <= P4;
                P4 <= lb1_out; -- Salida del Line Buffer 1 (Línea L-1)

                -- Píxeles de la Fila 2x Anterior (L-2)
                P9 <= P8;
                P8 <= P7;
                P7 <= lb2_out; -- Salida del Line Buffer 2 (Línea L-2)
                
                -- --- Lógica de Control ---
                -- start_processing se activa cuando se han cargado las 2 primeras líneas (2*C_COLS)
                -- y los 2 primeros píxeles de la tercera línea (para centrar la ventana en P5).
                if pixel_count >= C_DELAY then
                    start_processing <= '1';
                else
                    start_processing <= '0';
                end if;

            else
                -- Proceso de lectura terminado
                lb_we <= '0'; -- Detener escritura en Line Buffers
                LED(0) <= '1'; -- Señal de 'DONE'
            end if;

            -- Lógica de Escritura (Escritura en la RAM)
            if start_processing = '1' then
                we_ram <= '1';
                -- Dirección de escritura ajustada por el retraso del pipeline
                addr_write <= std_logic_vector(to_unsigned(pixel_count - C_DELAY, C_ADDR_BITS));
            else
                we_ram <= '0';
            end if;
            
        end if;
    end process;

    -- Conectar el resultado del filtro a la entrada de la RAM
    data_ram_in <= mediana_result;
    
end architecture structural;