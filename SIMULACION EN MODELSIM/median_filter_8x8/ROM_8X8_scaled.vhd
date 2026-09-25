library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM_8x8_scaled is
    port(
        clk  : in  std_logic;
        addr : in  unsigned(5 downto 0);
        data : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of ROM_8x8_scaled is

    type rom_t is array(0 to 63) of std_logic_vector(7 downto 0);

    constant ROM : rom_t := (
        x"1D", x"39", x"56", x"72", x"8F", x"AB", x"C8", x"E4",
        x"39", x"56", x"72", x"8F", x"AB", x"C8", x"E4", x"FF",
        x"2B", x"47", x"64", x"80", x"9D", x"B9", x"D6", x"F2",
        x"47", x"64", x"80", x"9D", x"B9", x"D6", x"F2", x"FF",
        x"00", x"1D", x"39", x"56", x"72", x"8F", x"AB", x"C8",
        x"39", x"56", x"72", x"8F", x"AB", x"C8", x"E4", x"FF",
        x"1D", x"39", x"56", x"72", x"8F", x"AB", x"C8", x"E4",
        x"47", x"64", x"80", x"9D", x"B9", x"D6", x"F2", x"FF"
    );

    signal reg_data : std_logic_vector(7 downto 0) := (others => '0');

begin
    process(clk)
    begin
        if rising_edge(clk) then
            reg_data <= ROM(to_integer(addr));
        end if;
    end process;

    data <= reg_data;

end architecture;