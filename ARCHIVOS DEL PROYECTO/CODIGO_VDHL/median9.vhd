-- median9.vhdl
-- Implementa una Red de Ordenamiento (Sorting Network) para encontrar la mediana de 9 valores.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity median9 is
    port (
        -- 9 Entradas de Píxeles (8 bits cada uno)
        P1, P2, P3, P4, P5, P6, P7, P8, P9 : in  std_logic_vector(7 downto 0);
        
        -- Salida: Mediana de 8 bits (El 5to valor ordenado)
        Mediana_Out                        : out std_logic_vector(7 downto 0)
    );
end entity median9;

architecture structural of median9 is

    -- Definición del Tipo para el Vector de 9 píxeles
    type pixel_array is array (1 to 9) of std_logic_vector(7 downto 0);

    -- Función Auxiliar: Comparador/Selector (Min/Max)
    -- Max en el MSB (15 downto 8), Min en el LSB (7 downto 0)
    function comparator_select (A, B: std_logic_vector(7 downto 0)) 
        return std_logic_vector is
        variable Min, Max : std_logic_vector(7 downto 0);
    begin
        if unsigned(A) < unsigned(B) then
            Min := A;
            Max := B;
        else
            Min := B;
            Max := A;
        end if;
        return Max & Min; -- Usamos Max & Min para mantener los valores ordenados de mayor a menor en los bits más altos
    end function comparator_select;

    -- --- Señales Intermedias para las Etapas de Ordenamiento ---
    signal T1, T2, T3, T4, T5, T6, T7, T8 : std_logic_vector(15 downto 0); 
    signal T9, T10, T11, T12, T13, T14, T15 : std_logic_vector(15 downto 0);
    signal T16, T17, T18, T19, T20, T21, T22, T23 : std_logic_vector(15 downto 0); -- Nuevos comparadores
    
    signal S1, S2, S3, S4, S5, S6, S7, S8 : pixel_array; -- S8 es la salida final ordenada
    
begin

    -- ----------------------------------------------------------------------
    -- ETAPA 1: Comparaciones Iniciales (P1..P8)
    -- ----------------------------------------------------------------------
    T1 <= comparator_select(P1, P2); S1(1) <= T1(15 downto 8); S1(2) <= T1(7 downto 0); 
    T2 <= comparator_select(P3, P4); S1(3) <= T2(15 downto 8); S1(4) <= T2(7 downto 0);
    T3 <= comparator_select(P5, P6); S1(5) <= T3(15 downto 8); S1(6) <= T3(7 downto 0);
    T4 <= comparator_select(P7, P8); S1(7) <= T4(15 downto 8); S1(8) <= T4(7 downto 0);
    S1(9) <= P9; 
    
    -- ----------------------------------------------------------------------
    -- ETAPA 2: Combinación y Ordenamiento Parcial (Merge 2x2, 2x2)
    -- ----------------------------------------------------------------------
    T5 <= comparator_select(S1(1), S1(3)); S2(1) <= T5(15 downto 8); S2(3) <= T5(7 downto 0);
    T6 <= comparator_select(S1(2), S1(4)); S2(2) <= T6(15 downto 8); S2(4) <= T6(7 downto 0);

    T7 <= comparator_select(S1(5), S1(7)); S2(5) <= T7(15 downto 8); S2(7) <= T7(7 downto 0);
    T8 <= comparator_select(S1(6), S1(8)); S2(6) <= T8(15 downto 8); S2(8) <= T8(7 downto 0);
    S2(9) <= S1(9); 

    -- Etapa 2.5 (Merge of 4 and 5 elements)
    T9 <= comparator_select(S2(3), S2(5)); S3(3) <= T9(15 downto 8); S3(5) <= T9(7 downto 0);
    T10 <= comparator_select(S2(4), S2(6)); S3(4) <= T10(15 downto 8); S3(6) <= T10(7 downto 0);

    S3(1) <= S2(1);
    S3(2) <= S2(2);
    S3(7) <= S2(7);
    S3(8) <= S2(8);
    S3(9) <= S2(9);

    -- ----------------------------------------------------------------------
    -- ETAPA 3: Fusión final de las dos mitades (Comparadores en pares (2,3), (4,5), etc.)
    -- ----------------------------------------------------------------------
    T11 <= comparator_select(S3(2), S3(3)); S4(2) <= T11(15 downto 8); S4(3) <= T11(7 downto 0);
    T12 <= comparator_select(S3(4), S3(5)); S4(4) <= T12(15 downto 8); S4(5) <= T12(7 downto 0);
    T13 <= comparator_select(S3(6), S3(7)); S4(6) <= T13(15 downto 8); S4(7) <= T13(7 downto 0);
    T14 <= comparator_select(S3(8), S3(9)); S4(8) <= T14(15 downto 8); S4(9) <= T14(7 downto 0);

    S4(1) <= S3(1);

    -- ----------------------------------------------------------------------
    -- ETAPA 4: Fusión final - Primer nivel de pares (Comparadores (3,5))
    -- ----------------------------------------------------------------------
    T15 <= comparator_select(S4(3), S4(5)); S5(3) <= T15(15 downto 8); S5(5) <= T15(7 downto 0);
    
    S5(1) <= S4(1);
    S5(2) <= S4(2);
    S5(4) <= S4(4);
    S5(6) <= S4(6);
    S5(7) <= S4(7);
    S5(8) <= S4(8);
    S5(9) <= S4(9);

    -- ----------------------------------------------------------------------
    -- ETAPA 5: Ajustes 1 (Comparadores (1,2), (3,4), (5,6), (7,8))
    -- Usamos S6 para almacenar el resultado de esta etapa
    -- ----------------------------------------------------------------------
    T16 <= comparator_select(S5(1), S5(2)); S6(1) <= T16(15 downto 8); S6(2) <= T16(7 downto 0);
    T17 <= comparator_select(S5(3), S5(4)); S6(3) <= T17(15 downto 8); S6(4) <= T17(7 downto 0);
    T18 <= comparator_select(S5(5), S5(6)); S6(5) <= T18(15 downto 8); S6(6) <= T18(7 downto 0);
    T19 <= comparator_select(S5(7), S5(8)); S6(7) <= T19(15 downto 8); S6(8) <= T19(7 downto 0);
    S6(9) <= S5(9); 
    
    -- ----------------------------------------------------------------------
    -- ETAPA 6: Ajustes 2 (Comparadores (2,3), (4,5), (6,7))
    -- Usamos S7 para almacenar el resultado de esta etapa
    -- ----------------------------------------------------------------------
    T20 <= comparator_select(S6(2), S6(3)); S7(2) <= T20(15 downto 8); S7(3) <= T20(7 downto 0);
    T21 <= comparator_select(S6(4), S6(5)); S7(4) <= T21(15 downto 8); S7(5) <= T21(7 downto 0);
    T22 <= comparator_select(S6(6), S6(7)); S7(6) <= T22(15 downto 8); S7(7) <= T22(7 downto 0);
    S7(1) <= S6(1);
    S7(8) <= S6(8);
    S7(9) <= S6(9);
    
    -- ----------------------------------------------------------------------
    -- ETAPA 7: Último Ajuste (Comparadores (3,4), (5,6))
    -- Usamos S8 para la salida final (totalmente ordenado)
    -- ----------------------------------------------------------------------
    T23 <= comparator_select(S7(3), S7(4)); S8(3) <= T23(15 downto 8); S8(4) <= T23(7 downto 0);
    S8(5) <= S7(5) when unsigned(S7(5)) < unsigned(S7(6)) else S7(6);
    S8(6) <= S7(6) when unsigned(S7(5)) < unsigned(S7(6)) else S7(5);

    S8(1) <= S7(1); 
    S8(2) <= S7(2);
    S8(7) <= S7(7); 
    S8(8) <= S7(8); 
    S8(9) <= S7(9);

    -- --- SELECCIÓN FINAL DE LA MEDIANA ---
    -- El 5to valor (índice 5) de la lista S8 es la mediana.
    Mediana_Out <= S8(5);

end architecture structural;