library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_filter is
    port(
        clk        : in  std_logic;
        rst        : in  std_logic;

        pixel_in   : in  std_logic_vector(7 downto 0);
        valid_in   : in  std_logic;

        pixel_out  : out std_logic_vector(7 downto 0);
        valid_out  : out std_logic
    );
end entity;

architecture rtl of top_filter is

    -- =============================
    -- Señales de direccionamiento
    -- =============================
    signal addr_pix : unsigned(5 downto 0) := (others=>'0'); -- 0..63
    signal addr_row : unsigned(2 downto 0);
    signal addr_col : unsigned(2 downto 0);

    -- =============================
    -- Line buffers (RAM 8x8)
    -- =============================
    type ram_t is array(0 to 7) of std_logic_vector(7 downto 0);

    signal line0 : ram_t := (others => (others=>'0')); -- fila actual
    signal line1 : ram_t := (others => (others=>'0')); -- fila anterior
    signal line2 : ram_t := (others => (others=>'0')); -- fila siguiente

    -- Señales de ventana 3×3
    signal w00, w01, w02 : std_logic_vector(7 downto 0);
    signal w10, w11, w12 : std_logic_vector(7 downto 0);
    signal w20, w21, w22 : std_logic_vector(7 downto 0);

    -- Salida del filtro mediana
    signal median_out : std_logic_vector(7 downto 0);
    signal median_valid : std_logic := '0';

begin

    ---------------------------------------------------------
    -- 1) Contador de píxel addr_pix (0..63)
    ---------------------------------------------------------
    process(clk, rst)
    begin
        if rst='1' then
            addr_pix <= (others=>'0');
        elsif rising_edge(clk) then
            if valid_in='1' then
                if addr_pix = 63 then
                    addr_pix <= (others=>'0');
                else
                    addr_pix <= addr_pix + 1;
                end if;
            end if;
        end if;
    end process;

    -- Convertir a fila / columna
    addr_row <= addr_pix(5 downto 3); -- bits 5,4,3
    addr_col <= addr_pix(2 downto 0); -- bits 2,1,0


    ---------------------------------------------------------
    -- 2) Line Buffers tipo RAM (cada uno almacena una fila)
    ---------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if valid_in='1' then

                -- El píxel entrante SIEMPRE pertenece a line0
                line0(to_integer(addr_col)) <= pixel_in;

                -- Cuando se llena una fila completa, rotamos:
                if addr_col = 7 then
                    line2 <= line1;
                    line1 <= line0;
                end if;

            end if;
        end if;
    end process;


    ---------------------------------------------------------
    -- 3) Construcción de la ventana 3×3
    ---------------------------------------------------------
    w00 <= line2(to_integer(addr_col-1)) when addr_col>0 else line2(0);
    w01 <= line2(to_integer(addr_col));
    w02 <= line2(to_integer(addr_col+1)) when addr_col<7 else line2(7);

    w10 <= line1(to_integer(addr_col-1)) when addr_col>0 else line1(0);
    w11 <= line1(to_integer(addr_col));
    w12 <= line1(to_integer(addr_col+1)) when addr_col<7 else line1(7);

    w20 <= line0(to_integer(addr_col-1)) when addr_col>0 else line0(0);
    w21 <= line0(to_integer(addr_col));
    w22 <= line0(to_integer(addr_col+1)) when addr_col<7 else line0(7);


    ---------------------------------------------------------
    -- 4) Instancia del filtro mediana 3×3
    ---------------------------------------------------------
    median_unit : entity work.median9
    port map(
        p1 => w00,  p2 => w01,  p3 => w02,
        p4 => w10,  p5 => w11,  p6 => w12,
        p7 => w20,  p8 => w21,  p9 => w22,
        med => median_out
    );

    ---------------------------------------------------------
    -- 5) Control de valid_out
    ---------------------------------------------------------
    process(clk, rst)
    begin
        if rst='1' then
            median_valid <= '0';
        elsif rising_edge(clk) then
            -- La ventana solo es válida a partir de la FILA 2 y COLUMNA 1
            if addr_row >= 2 and addr_col >= 1 and addr_col <= 6 then
                median_valid <= valid_in;
            else
                median_valid <= '0';
            end if;
        end if;
    end process;

   	pixel_out <= median_out after 10 ns;  -- retraso simulado
	valid_out <= median_valid;            -- valid sigue igual
end architecture;