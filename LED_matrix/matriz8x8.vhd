library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
entity matrixArrowMov is 
Generic (N: integer:=15; M: integer:=24); -- M es para el divisor y N para el barrido 
Port ( clk,magnet,hold: in STD_LOGIC; -- reloj de 50MHz, direccin, hold y  sonido 
sonidoOUT: out std_logic; --salida de sonido para una bocina de alta impedancia 
R,C : out STD_LOGIC_VECTOR (8 downto 1)); -- Renglones y Columnas 
end matrixArrowMov; 

architecture matrixArrowMov of matrixArrowMov is 
--seales 
signal clkdiv: std_logic_vector (M downto 0); --divisor de M+1 bits 
signal barrido: std_logic_vector (2 downto 0); --contador de 3 bits para el barrido del  arreglo 
signal sonidoSW: std_logic := '0'; --seal para activar el sonido
type arreglo is array (1 to 8) of std_logic_vector(7 downto 0); --declaracin de la matriz 8x8 
signal tabla: arreglo; --seal que recibe las cuatro figuras (tabla1,2,3,4) para ciclarse 
--constantes 
constant tabla1 : arreglo :=( 
"00000000",
"00000000",
"00000010",
"00000010",
"00000000",
"00000000",
"00000000",
"00000000");
constant tabla2 : arreglo :=(
"00000000",
"00000000",
"00000010",
"00000010",
"00000010",
"00000010",
"00000000",
"00000000");  
constant tabla3 : arreglo :=( 
"00000000",
"00000000",
"00000010",
"00000010",
"00000010",
"00000010",
"00001100",
"00000000"); 
constant tabla4 : arreglo :=( 
"00000000",
"00000000",
"00000010",
"00000010",
"00000010",
"00000010",
"00111100",
"00000000"); 
constant tabla5 : arreglo :=( 
"00000000",
"00000000",
"00000010",
"00000010",
"01000010",
"01000010",
"00111100",
"00000000"); 
constant tabla6 : arreglo :=( 
"00000000",
"00000000",
"01000010",
"01000010",
"01000010",
"01000010",
"00111100",
"00000000"); 
constant tabla7 : arreglo :=(  
"00000000",
"00110000",
"01000010",
"01000010",
"01000010",
"01000010",
"00111100",
"00000000");  
constant tabla8 : arreglo :=( 
"00001000",
"00111100",
"01001010",
"01000010",
"01000010",
"01000010",
"00111100",
"00000000"); 
constant tabla9 : arreglo :=(  
"00000001",
"00000010",
"00000100",
"00001000",
"00010000",
"10100000",
"11000000",
"10000000");  
-- la seal tempo es un contador de 3 bits que asigna de forma temporal el valor 
-- de las 8 tablas 
signal tempo: std_logic_vector(2 downto 0);-- 
signal duracion: std_logic_vector(1 downto 0); --contador para el sonido 
begin 
--comienza la arquitectura 
-- proceso del divisor cldiv 
divisor: process (clk) 
begin 
if clk'event and clk='1' then 
clkdiv <= clkdiv + 1; --contador de M bits 
end if; 
end process divisor; 
--manda los datos del display 
asigna: process (clkdiv(M), barrido, magnet, hold) 
begin 
tempo <= clkdiv(M downto M-2); 
-- esta asignacin funciona igual que clkdiv <= clkdiv + 1 
barrido <= clkdiv(N downto N-2); 
-- cambio de las figuras para la seal tabla 
if tempo = o"0" then tabla <= tabla1; 
elsif tempo = o"1" then tabla <= tabla2;
elsif tempo = o"2" then tabla <= tabla3; 
elsif tempo = o"3" then tabla <= tabla4; 
elsif tempo = o"4" then tabla <= tabla5; 
elsif tempo = o"5" then tabla <= tabla6; 
elsif tempo = o"6" then tabla <= tabla7; 
else tabla <= tabla8; 
end if; 
--se mandan los datos a los renglones y las columnas con el contador barrido 
if hold='1' then --manda cuadro con puntos en las esquinas 
case barrido is 
when o"0" => C <= tabla9(1); R <= NOT "01111111"; 
when o"1" => C <= tabla9(2); R <= NOT "10111111"; 
when o"2" => C <= tabla9(3); R <= NOT "11011111"; 
when o"3" => C <= tabla9(4); R <= NOT "11101111"; 
when o"4" => C <= tabla9(5); R <= NOT "11110111"; 
when o"5" => C <= tabla9(6); R <= NOT "11111011"; 
when o"6" => C <= tabla9(7); R <= NOT "11111101"; 
when o"7" => C <= tabla9(8); R <= NOT "11111110"; 
when others =>C <= tabla9(1); R <= NOT "00000000"; 
end case; 
elsif magnet = '0' then
	case barrido is 
	when o"0" => C <= tabla(1); R <= NOT "01111111"; 
	when o"1" => C <= tabla(2); R <= NOT "10111111"; 
	when o"2" => C <= tabla(3); R <= NOT "11011111"; 
	when o"3" => C <= tabla(4); R <= NOT "11101111"; 
	when o"4" => C <= tabla(5); R <= NOT "11110111"; 
	when o"5" => C <= tabla(6); R <= NOT "11111011"; 
	when o"6" => C <= tabla(7); R <= NOT "11111101"; 
	when o"7" => C <= tabla(8); R <= NOT "11111110"; 
	when others => C <= tabla(1); R <= NOT "00000000"; 
	end case; 
else 
	case barrido is 
	when o"0" => C <= tabla(8); R <= NOT "01111111"; 
	when o"1" => C <= tabla(7); R <= NOT "10111111"; 
	when o"2" => C <= tabla(6); R <= NOT "11011111"; 
	when o"3" => C <= tabla(5); R <= NOT "11101111"; 
	when o"4" => C <= tabla(4); R <= NOT "11110111"; 
	when o"5" => C <= tabla(3); R <= NOT "11111011"; 
	when o"6" => C <= tabla(2); R <= NOT "11111101"; 
	when o"7" => C <= tabla(1); R <= NOT "11111110"; 
	when others => C <= tabla(1); R <= NOT "00000000"; 
	end case; 
end if; 
end process asigna; 

sonido: process(clkdiv(M), magnet, hold) 
begin 
duracion <= clkdiv(M downto M-1); 
if hold = '1' then sonidoOUT <= '0'; --sin sonido 
elsif magnet = '1' then 
case duracion is 
 when "00" => sonidoOUT <= '0';  
 when others => sonidoOUT <= '0';  
end case; 
else -- dir = '0' then 
case duracion is 
 when "00" => sonidoOUT <= clkdiv(16); 
 when "01" => sonidoOUT <= '0'; --clkdiv(15);  
 when "10" => sonidoOUT <= clkdiv(16); 
 when "11" => sonidoOUT <= '0';  --clkdiv(13);  
 when others => sonidoOUT <= '0'; 
end case; 
end if; 
end process sonido; 

end matrixArrowMov;