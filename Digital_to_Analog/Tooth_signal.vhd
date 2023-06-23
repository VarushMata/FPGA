
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity Tooth_signal is
Generic (max: integer:= 7); -- nmero mximo para implementar
--Generic (max: integer:= 3); -- nmero mximo para simular
Port (
CLK: in STD_LOGIC; -- reloj de 50MHz para la nexys 2
RST: in STD_LOGIC; -- reset BTN0
SW: in STD_LOGIC; -- cambia la velocidad de la seal
LED: OUT STD_LOGIC_VECTOR(max DOWNTO 0); -- a leds testigo
R2R: OUT STD_LOGIC_VECTOR(max DOWNTO 0) -- al PmodR2R
);
end Tooth_signal;

architecture Behavioral of Tooth_signal is
signal clkdiv: std_logic:='0'; -- clkdiv
signal CONT: std_logic_vector (max DOWNTO 0):=(others=>'0'); -- cont de max+1 bits
signal CONT2: std_logic_vector (max DOWNTO 0):=(others=>'0'); -- cont rampa

begin

---------------------contador------------------------------------
-- en este proceso se genera un contador de n=max+1 bits,
-- que servir como divisores de frecuencia para el contador
PROCESS(RST, clk, cont)
begin
if RST='1' then
CONT<=(others=>'0');
elsif (rising_edge(clk)) then -- reloj 50MHz

CONT<=CONT+'1'; -- contador ascendente

end if;

end process;

---------------------selecciona la velocidad de la seal------------------------------------
-- en este proceso se selecciona la velocidad con cont(max) o cont(max-1)
PROCESS(clk,sw, cont(max),cont(max-1))
begin
if(rising_edge(clk)) then -- reloj 50MHz
if sw='0' then clkdiv <= CONT(max); -- reloj lento
else clkdiv <= CONT(max-1); -- reloj rpido
end if;
end if;
end process;

---------------------contador (seal rampa)------------------------------------
-- en este proceso se genera un contador de 8 bits que depende
-- de clkdiv que sirve para generar una seal rampa
PROCESS(RST, clkdiv,cont2)
begin
if RST='1' then

CONT2<=(others=>'0');
elsif(rising_edge(clkdiv)) then -- reloj clkdiv

CONT2<=CONT2+'1'; -- contador ascendente

end if;
end process;

LED <= CONT2(max downto 0); -- salida a leds rampa
R2R <= CONT2(max downto 0); -- salida al pmod rampa


end Behavioral;

