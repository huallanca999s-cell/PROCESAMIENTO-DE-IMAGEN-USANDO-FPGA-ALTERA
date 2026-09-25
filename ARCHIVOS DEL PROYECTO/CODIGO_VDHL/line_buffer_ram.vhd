-- line_buffer_ram.vhd
-- Componente para simular un Line Buffer de 204 píxeles (8 bits) usando RAM.
-- Este DEBE ser reemplazado por la IP Core de Quartus (altsyncram) en tu proyecto.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity line_buffer_ram is
    generic (
        COLUMNS : integer := 204;
        ADDR_WIDTH : integer := 8 -- ceil(log2(204)) = 8
    );
    port (
        clk    : in  std_logic;
        reset_n: in  std_logic;
        
        data_in : in  std_logic_vector(7 downto 0);
        write_en: in  std_logic;
        
        -- Misma dirección para lectura y escritura (Single-Port, Dual-Port Write/Read)
        address : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        
        data_out: out std_logic_vector(7 downto 0) -- Salida del píxel actual del buffer
    );
end entity line_buffer_ram;

architecture structural of line_buffer_ram is
    -- Usamos un tipo RAM para simular la memoria (no sintetizable directamente)
    -- En Quartus, esto se reemplaza por el 'altsyncram' generado.
    type memory_t is array (0 to COLUMNS-1) of std_logic_vector(7 downto 0);
    signal buffer_mem : memory_t := (others => (others => '0'));
    
    signal read_address : integer range 0 to COLUMNS-1;
begin
    
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            -- Reset no es necesario para la RAM, solo para la lógica de Quartus.
            null;
        elsif rising_edge(clk) then
            read_address <= to_integer(unsigned(address));
            
            -- Lógica de escritura del Line Buffer
            if write_en = '1' then
                -- Escribir el píxel entrante en la dirección actual
                buffer_mem(to_integer(unsigned(address))) <= data_in;
            end if;
        end if;
    end process;
    
    -- Lectura: La salida es combinacional o síncrona, dependiendo del IP Core.
    -- Aquí lo hacemos síncrono para coincidir con la arquitectura de FPGA:
    process(clk)
    begin
        if rising_edge(clk) then
            data_out <= buffer_mem(read_address);
        end if;
    end process;

end architecture structural;