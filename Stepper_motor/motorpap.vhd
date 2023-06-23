----------------------------------------------------------------------------------
--MEXILOGICS
--PUNTO 2 AUTOMATIZACION DE ESCALERAS ELECTRICAS
--AL DETECTAR A UNA PERSONA SE ENCIENDE UN MOTOR A PASOS POR 10 SEGUNDOS
--SI DETECTA A ALGUIEN M[AS SE REINICIA EL CONTADOR
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;


entity motorpap is port(
	clk : in std_logic; --reloj
	sensor: in std_logic; --entrada
	O: out std_logic_vector(1 to 4); --salidas
	an : out std_logic_vector(7 downto 0); --salida a los anodos 
	D : out std_logic_vector(7 downto 0) --salida a los displays
);

end motorpap;

architecture Behavioral of motorpap is

constant max_count : integer := 250_000; --Generar la seal de 5ms
signal count : integer range 0 to max_count; --contador para seal de 5ms
signal clkdiv : std_logic := '0'; --seal para el divisor de reloj para el motor a pasos
signal sel : std_logic_vector(1 downto 0) := "00"; --Selector para cambiar de fase del motor
signal trig : std_logic := '0'; --Valor para encender el motor a pasos
constant seg_count : integer := 50_000_000*10; --Generar la seal de 10 segundos
signal counter : integer range 0 to seg_count; --contador para los 10 segundos

begin


--contador de 10 seg
divisor2: process(clk,counter,sensor) begin
	if clk'event and clk='1' then --Divisor de reloj para contar 10 segundos
			if counter < seg_count then
				D <= "10001110"; AN <= "11111110"; --F en el display 4 
				counter <= counter + 1; --Incrementa hasta los 10 segundos
				if sensor = '0' then counter <= 0; end if; --Al detectar el sensor se reinicia el contador
				trig <= '1'; --El motor se mantiene encendido
			else
				trig <= '0'; --Apaga el motor
				D <= "10001100"; AN <= "11110111"; --P en el display 1
			end if;
		end if;
if sensor <= '0' then counter <= 0; end if; --Al detectar el sensor se reinicia el contador
end process;

--demultiplexor
mux: process(sel,trig) begin
	case sel is
	--Fases del motor que cambian con cada tick del divisor de reloj
		when "00" => O(1)<= trig; O(2)<='0'; O(3) <= '0'; O(4) <= '0';  
		when "01" => O(1)<='0'; O(2)<= trig; O(3) <= '0'; O(4) <= '0'; 
		when "10" => O(1)<='0'; O(2)<='0'; O(3) <= trig; O(4) <= '0'; 
		when "11" => O(1)<='0'; O(2)<='0'; O(3) <= '0'; O(4) <= trig; 
		when others => O(1)<='0'; O(2)<='0'; O(3) <= '0'; O(4) <= trig;
		end case;
	
end process;

	
--divisor, genera seal dpara el motor a pasos
divisor: process(clk,clkdiv,count) begin

	if clk'event and clk='1' then
		if count<max_count then
			count<=count+1;
		else
			clkdiv<=not clkdiv;
			count<=0;
		end if;
	end if;
end process;

--contador para el selector
contador: process(clkdiv) begin

if clkdiv'event and clkdiv='1' then
	sel<=sel + '1';
end if;
end process;

end Behavioral;

