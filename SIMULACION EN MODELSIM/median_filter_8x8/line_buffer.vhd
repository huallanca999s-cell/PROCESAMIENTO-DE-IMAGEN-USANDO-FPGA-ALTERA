library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity line_buffer is
    port(
        clk   : in  std_logic;
        we    : in  std_logic; -- habilita escritura (en tu top lo pones a '1' mientras lees)
        d_in  : in  std_logic_vector(7 downto 0);
        d_out : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of line_buffer is
    type mem_t is array(0 to 7) of std_logic_vector(7 downto 0);
    signal mem : mem_t := (others => (others => '0'));
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                -- shift a la derecha: mem(7) <= mem(6), ..., mem(1) <= mem(0), mem(0) <= d_in
                for i in 7 downto 1 loop
                    mem(i) <= mem(i-1);
                end loop;
                mem(0) <= d_in;
            end if;
            d_out <= mem(7);  -- dato alineado (pixel de misma columna de la fila previa)
        end if;
    end process;
end architecture;

