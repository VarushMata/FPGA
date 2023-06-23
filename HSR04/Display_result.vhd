----------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity Display_result is
Port(
	UNI,DEC,CEN,MIL: in std_logic_vector (3 downto 0); --U-D-C-M
	SAL_400Hz : in std_logic; --Reloj de 400Hz
	DISPLAY : out STD_LOGIC_VECTOR(7 downto 0); --segmentos del display
	AN : out std_logic_vector (7 downto 0) --nodos del display
);
end Display_result;

architecture Behavioral of Display_result is
-- Declaracin de seales de la multiplexacin y asignacin de U-D-C al disp

signal SEL: std_logic_vector (1 downto 0):="00"; -- selector de barrido
signal D: std_logic_vector (3 downto 0); -- almacena los valores del disp
begin
PROCESS(SAL_400Hz, sel, UNI, DEC,CEN,MIL)
BEGIN
IF SAL_400Hz'EVENT and SAL_400Hz='1' THEN SEL <= SEL + '1';
	CASE(SEL) IS
	when "00" => AN <="11110111"; D <= UNI; -- UNIDADES
	when "01" => AN <="11111011"; D <= DEC; -- DECENAS
	when "10" => AN <="11111101"; D <= CEN; -- CENTENAS
	when "11" => AN <="11111110"; D<= MIL; --MILLARES
	when others =>AN <="11111111"; D <= x"0"; -- signo
	END CASE;
end if;
END PROCESS; -- fin del proceso Multiplexor

process(D) begin
case(D) is
WHEN x"0" => DISPLAY <= "00000011"; --0
WHEN x"1" => DISPLAY <= "10011111"; --1
WHEN x"2" => DISPLAY <= "00100101"; --2
WHEN x"3" => DISPLAY <= "00001101"; --3
WHEN x"4" => DISPLAY <= "10011001"; --4
WHEN x"5" => DISPLAY <= "01001001"; --5
WHEN x"6" => DISPLAY <= "01000001"; --6
WHEN x"7" => DISPLAY <= "00011111"; --7
WHEN x"8" => DISPLAY <= "00000001"; --8
WHEN x"9" => DISPLAY <= "00001001"; --9
WHEN x"F" => DISPLAY <= "11111101"; --signo
WHEN OTHERS => DISPLAY <= "11111111"; --apagado
end case;
end process;
end Behavioral;

