----------------------------------------------------------------------------------
-- MEXILOGICS: CONTROL DE DISPLAYS DE 7 SEGMENTOS
-- SEGÚN EL MOVIMIENTO DEL BRAZO
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity Display_result is
Port(
	selec: in std_logic_vector (7 downto 0); --U-D-C-M
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
PROCESS(SAL_400Hz, sel,selec)
BEGIN
IF SAL_400Hz'EVENT and SAL_400Hz='1' THEN SEL <= SEL + '1';
	CASE(SEL) IS
	when "00" => AN <="11110111"; DIsplay <= x"00"; 
	when "01" => AN <="11111011";
					 if selec(0) = '1'  or selec(2) = '1' then display <= "11000011"; --SUBIR
					 elsif selec(1) = '1' or selec(3)='1' then display <= "10001111"; --BAJAR
					 elsif selec(4) = '1' or selec(5) = '1' then display <= "11100001"; --ROTAR
					 elsif selec(6) = '1' or selec(7) = '1' then display <= "00110001"; --GRIPPER
					 end if;
	when "10" => AN <="11111101";  
					 if selec(0) = '1'  or selec(2) = '1' then display <= "11000111";
					 elsif selec(1) = '1' or selec(3)='1' then display <= "00010001";
					 elsif selec(4) = '1' or selec(5) = '1' then display <= "00000011";
					 elsif selec(6) = '1' or selec(7) = '1' then display <= "11110101";
					 end if;
	when "11" => AN <="11111110"; 
					 if selec(0) = '1'  or selec(2) = '1' then display <= "01001001";
					 elsif selec(1) = '1' or selec(3)='1' then display <= "11000011";
					 elsif selec(4) = '1' or selec(5) = '1' then display <= "11110101";
					 elsif selec(6) = '1' or selec(7) = '1' then display <= "00001001";
					 end if;
	when others =>AN <="11111111"; display <= x"00"; -- signo
	END CASE;
end if;
END PROCESS; -- fin del proceso Multiplexor
end Behavioral;

