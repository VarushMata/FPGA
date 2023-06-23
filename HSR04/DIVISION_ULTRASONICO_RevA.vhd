----------------------------------------------------------------------------------
-- MEXILOGICS: Cdigo que realiza divisiones mediante sumatorias, el algoritmo cuenta el nmero de iteraciones que fueron necesarias para que el divisor
--sea igual o mayor al dividendo.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity DIVISION_ULTRASONICO_RevA is

PORT(
		CLK 		 : IN  STD_LOGIC;                     -- Reloj FPGA.
		INI		 : IN  STD_LOGIC;                     -- Bit que inicia proceso de divisin.
		DIVIDENDO : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- Operador dividendo.
		DIVISOR   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- Operador divisor.
		RESULTADO : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Resultado de la divisin.
		OK			 : OUT STD_LOGIC                      -- Bit que indica fin de divisin.
);

end DIVISION_ULTRASONICO_RevA;

architecture Behavioral of DIVISION_ULTRASONICO_RevA is

signal iteraciones : std_logic_vector(31 downto 0) := (others => '0'); -- Seal que cuenta el nmero de iteraciones.
signal dividendo_s : std_logic_vector(31 downto 0) := (others => '0'); -- Seal auxiliar para el dividendo.
signal divisor_s   : std_logic_vector(31 downto 0) := (others => '0'); -- Seal auxiliar para el divisor.
signal edo 			 : integer range 0 to 3 := 0;                        -- Seal para la mquina de estados.

begin

PROCESS(CLK)
begin
if rising_edge(CLK) then
	case(edo) is
	when 0 => if ini = '1' then -- Espera a que el bit "ini" se ponga a '1'.
					dividendo_s <= DIVIDENDO;
					divisor_s <= DIVISOR;
					iteraciones <= (others => '0');
					edo <= 1;
				 end if;
	when 1 => -- Proceso de aproximacin para calcular el nmero de iteraciones.
		      if divisor_s <= dividendo_s then -- Si es menor o igual el proceso contina.
					divisor_s <= divisor_s + DIVISOR;
					iteraciones <= iteraciones+1;
					edo <= 1;
				else -- Si la condicin deja de cumplirse entonces se manda el resultado como el nmero de iteraciones. Se activa la bandera "ok".
					resultado <= iteraciones;
					ok <= '1';
					edo <= 2;
				end if;
	when 2 => -- Se desactiva la bandera "ok".
				ok <= '0';
				edo <= 3;
	when 3 => -- Estado dummy.
				edo <= 0;
	when others => null;
	end case;
--	if edo = 0 then
--		if ini = '1' then -- Espera a que el bit "ini" se ponga a '1'.
--			dividendo_s <= DIVIDENDO;
--			divisor_s <= DIVISOR;
--			iteraciones <= (others => '0');
--			edo <= 1;
--		end if;
--		
--	elsif edo = 1 then -- Proceso de aproximacin para calcular el nmero de iteraciones.
--		if divisor_s <= dividendo_s then -- Si es menor o igual el proceso contina.
--			divisor_s <= divisor_s + DIVISOR;
--			iteraciones <= iteraciones+1;
--			edo <= 1;
--		else -- Si la condicin deja de cumplirse entonces se manda el resultado como el nmero de iteraciones. Se activa la bandera "ok".
--			resultado <= iteraciones;
--			ok <= '1';
--			edo <= 2;
--		end if;
--		
--	elsif edo = 2 then -- Se desactiva la bandera "ok".
--		ok <= '0';
--		edo <= 3;
--	
--	elsif edo = 3 then -- Estado dummy.
--		edo <= 0;
--	
--	end if;
end if;
end process;


end Behavioral;

