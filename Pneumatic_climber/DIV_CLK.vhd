----------------------------------------------------------------------------------
--MEXILOGICS
--DIVISOR DE 2.5ms
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.STD_LOGIC_arith.ALL;

--Declaracin de entidad
entity DIV_CLK is
port(
	clk: in std_logic; --reloj de 50MHz 
	SAL_400Hz: inout std_logic --salida 2.5ms
);
end DIV_CLK;

----------------------------------------------------------------------------------
--Declaracin de la arquitectura
architecture Behavioral of DIV_CLK is
--Declaracin de seales de divisores
signal conta_1250us : integer range 1 to 62_500 := 1; --pulso de 1250 us@400Hz (0.25ms)

begin
--Divisor 2.5ms = 400Hz
--Divisor nodos
process(clk) begin
if rising_edge(clk) then
	if(conta_1250us = 62_500) then --cuenta 1250us (50MHz = 62500)
	SAL_400Hz <= not(SAL_400Hz); --Genera un barrido de 2.5ms
	conta_1250us <= 1;

	else conta_1250us <= conta_1250us + 1;
	end if;
end if;
end process; --Fin del proceso divisor de nodos

----------------------------------------------------------------------------------
--fin de la arquitectura
end Behavioral;

