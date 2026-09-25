library ieee;
use ieee.std_logic_1164.all;

entity window3x3 is
    port(
        clk   : in  std_logic;
        cur   : in  std_logic_vector(7 downto 0);
        row1  : in  std_logic_vector(7 downto 0);
        row2  : in  std_logic_vector(7 downto 0);

        valid_in : in  std_logic;     -- << NUEVO
        valid_out : out std_logic;    -- << NUEVO

        p1,p2,p3,p4,p5,p6,p7,p8,p9 : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of window3x3 is

    signal r1_0, r1_1, r1_2 : std_logic_vector(7 downto 0) := (others => '0');
    signal r2_0, r2_1, r2_2 : std_logic_vector(7 downto 0) := (others => '0');
    signal r3_0, r3_1, r3_2 : std_logic_vector(7 downto 0) := (others => '0');

    signal v1, v2, v3 : std_logic := '0';  -- pipeline de validez

begin

    process(clk)
    begin
        if rising_edge(clk) then
            
            -- FILA SUPERIOR
            r1_0 <= row2;
            r1_1 <= r1_0;
            r1_2 <= r1_1;

            -- FILA MEDIA
            r2_0 <= row1;
            r2_1 <= r2_0;
            r2_2 <= r2_1;

            -- FILA INFERIOR
            r3_0 <= cur;
            r3_1 <= r3_0;
            r3_2 <= r3_1;

            -- PIPELINE del valid_in
            v1 <= valid_in;
            v2 <= v1;
            v3 <= v2;

        end if;
    end process;

    valid_out <= v3;

    p1 <= r1_2; p2 <= r1_1; p3 <= r1_0;
    p4 <= r2_2; p5 <= r2_1; p6 <= r2_0;
    p7 <= r3_2; p8 <= r3_1; p9 <= r3_0;

end architecture;