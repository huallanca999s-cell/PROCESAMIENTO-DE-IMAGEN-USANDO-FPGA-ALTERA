library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_top_filter is
end entity;

architecture sim of tb_top_filter is

    -- Señales de simulación
    signal clk_tb       : std_logic := '0';
    signal rst_tb       : std_logic := '1';
    signal pixel_in_tb  : std_logic_vector(7 downto 0);
    signal valid_in_tb  : std_logic := '0';
    signal pixel_out_tb : std_logic_vector(7 downto 0);
    signal valid_out_tb : std_logic;

    -- Señales ROM
    signal rom_addr     : unsigned(5 downto 0) := (others=>'0');
    signal rom_data     : std_logic_vector(7 downto 0);

    constant Tclk : time := 20 ns;

begin

    ---------------------------------------------------------
    -- 1) Generador de reloj 50 MHz
    ---------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk_tb <= '0'; wait for Tclk/2;
            clk_tb <= '1'; wait for Tclk/2;
        end loop;
    end process;

    ---------------------------------------------------------
    -- 2) Instancia de la ROM
    ---------------------------------------------------------
    ROM_INST : entity work.ROM_8x8_scaled
        port map(
            clk  => clk_tb,
            addr => rom_addr,
            data => rom_data    -- <--- puerto correcto
        );

    ---------------------------------------------------------
    -- 3) Contador de dirección ROM y valid_in
    ---------------------------------------------------------
    process(clk_tb, rst_tb)
    begin
        if rst_tb='1' then
            rom_addr <= (others=>'0');
            valid_in_tb <= '0';
        elsif rising_edge(clk_tb) then
            if rom_addr < 63 then
                rom_addr <= rom_addr + 1;
                valid_in_tb <= '1';
            else
                valid_in_tb <= '0';
            end if;
        end if;
    end process;

    ---------------------------------------------------------
    -- 4) Instancia del DUT top_filter
    ---------------------------------------------------------
    DUT : entity work.top_filter
        port map(
            clk       => clk_tb,
            rst       => rst_tb,
            pixel_in  => rom_data,   -- <--- entrada desde ROM
            valid_in  => valid_in_tb,
            pixel_out => pixel_out_tb,
            valid_out => valid_out_tb
        );

    ---------------------------------------------------------
    -- 5) Reset inicial y fin de simulación
    ---------------------------------------------------------
    stim_proc : process
    begin
        rst_tb <= '1';
        wait for 2*Tclk;
        rst_tb <= '0';

        -- Esperar a que salga al menos un pixel filtrado
        wait until valid_out_tb='1';
        report "Primer pixel filtrado válido recibido" severity note;

        wait for 200 ns;
        report "Simulación finalizada" severity note;
        wait;
    end process;

end architecture;