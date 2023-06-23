----------------------------------------------------------------------------------
--MEXILOGICS: PROGRAMA PARA MOSTRAR EL NMERO XONVERTIDO A UDCM EN LOS DISPLAYS
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity Display_result is
generic(
	S: std_logic_vector (7 downto 0) := "01001001";
	guionb : std_logic_vector (7 downto 0) := "11101111";
	A: std_logic_vector (7 downto 0) := "00010001";
	B: std_logic_vector (7 downto 0) := "11000001";
	R: std_logic_vector (7 downto 0) := "11110101";
	E: std_logic_vector (7 downto 0) := "01100001";
	L: std_logic_vector (7 downto 0) := "11100011";
	V: std_logic_vector (7 downto 0) := "11000111"

);
Port(
	SELEC: in std_logic_vector (1 downto 0); 
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
PROCESS(SAL_400Hz, sel, SELEC)
BEGIN
IF SAL_400Hz'EVENT and SAL_400Hz='1' THEN SEL <= SEL + '1';
	CASE(SEL) IS
	when "00" => AN <= "11110111";
					 case(selec) is
						when "00" => DISPLAY <= B; 
						when "01" => DISPLAY <= V;
						when "10" => DISPLAY <= R;
						when others => DISPLAY <= x"00";
					 end case;
	when "01" => AN <="11111011"; 
					 case(selec) is
						when "00" => DISPLAY <= A; 
						when "01" => DISPLAY <= E;
						when "10" => DISPLAY <= A;
						when others => DISPLAY <= x"00";
					 end case;
	when "10" => AN <="11111101"; 
					 case(selec) is
						when "00" => DISPLAY <= guionb; 
						when "01" => DISPLAY <= L;
						when "10" => DISPLAY <= guionb;
						when others => DISPLAY <= x"00";
					 end case;
	when "11" => AN <="11111110"; 
					 case(selec) is
						when "00" => DISPLAY <= S; 
						when "01" => DISPLAY <= E;
						when "10" => DISPLAY <= S;
						when others => DISPLAY <= x"00";
					 end case;
	when others =>AN <="11111111"; DISPLAY <= x"00"; -- signo
	END CASE;
end if;
END PROCESS; -- fin del proceso Multiplexor
end Behavioral;

