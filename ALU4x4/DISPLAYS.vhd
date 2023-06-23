----------------------------------------------------------------------------------
--MEXILOGICS
--CONTROLADOR DE DISPLAY DE 4 DGITOS
--------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.STD_LOGIC_arith.ALL;


entity DISPLAYS is
Port(
	selOP : in std_logic_vector (3 downto 0); --Selector de la operacin
	UNI,DEC,CEN,signo : in std_logic_vector (3 downto 0); --U-D-C
	SAL_400Hz : in std_logic; --Reloj de 400Hz
	DISPLAY : out STD_LOGIC_VECTOR(7 downto 0); --segmentos del display
	AN : out std_logic_vector (7 downto 0) --nodos del display
);

end DISPLAYS;
----------------------------------------------------------------
-- Declaracin de la arquitectura

architecture Behavioral of DISPLAYS is
-- Declaracin de seales de la multiplexacin y asignacin de letras al disp
signal SEL: std_logic_vector (1 downto 0):="00"; -- selector de barrido
signal Dig: std_logic_vector (3 downto 0); --Almacena los valores del disp
signal segments : std_logic_vector (7 downto 0):=x"00";
-- Declaracin de constantes para las letras (AND, OR, XOR, NOT) al disp
constant A: std_logic_vector (7 downto 0):= "00010001"; -- A
constant N: std_logic_vector (7 downto 0):= "11010101"; -- n
constant D: std_logic_vector (7 downto 0):= "10000101"; -- d
constant V: std_logic_vector (7 downto 0):= "11111111"; -- V sin dato
constant O: std_logic_vector (7 downto 0):= "00000011"; -- O
constant R: std_logic_vector (7 downto 0):= "11110101"; -- r
constant X: std_logic_vector (7 downto 0):= "00111011"; -- ^
constant T: std_logic_vector (7 downto 0):= "11100001"; -- t
begin

---MULTIPLEXOR
Process(SAL_400Hz,selOP,signo,dig,UNI,DEC,CEN)
begin
IF SAL_400Hz'EVENT and SAL_400Hz='1' THEN SEL <= SEL + '1';

--dependiendo de la operacin, muestra un resultado
case(SEL) is

when "00" =>AN<="11110111";
if selOP=x"5" then segments <= V; --andV
elsif selOP=x"6" then segments <= V; --orV
elsif selOP=x"7" then segments <= V; --xorV
elsif selOP=x"8" then segments <= V; --notV
elsif selOP=x"1" or selOP=x"2" or selOP=x"3" or selOP=x"4"
or selOP =x"A" or selOP=x"B" then
case(UNI) is
WHEN x"0" => segments <= "00000011"; --0
WHEN x"1" => segments <= "10011111"; --1
WHEN x"2" => segments <= "00100101"; --2
WHEN x"3" => segments <= "00001101"; --3
WHEN x"4" => segments <= "10011001"; --4
WHEN x"5" => segments <= "01001001"; --5
WHEN x"6" => segments <= "01000001"; --6
WHEN x"7" => segments <= "00011111"; --7
WHEN x"8" => segments <= "00000001"; --8
WHEN x"9" => segments <= "00001001"; --9
WHEN x"F" => segments <= "11111101"; --signo
WHEN OTHERS => segments <= "11111111"; --apagado
end case;
else segments<=V; end if;

when "01" =>AN<="11111011";
if selOP=x"5" then segments <= D; --andV
elsif selOP=x"6" then segments <= V; --orV
elsif selOP=x"7" then segments <= R; --xorV
elsif selOP=x"8" then segments <= T; --notV
elsif selOP=x"1" or selOP=x"2" or selOP=x"3" or selOP=x"4"
or selOP =x"A" or selOP=x"B" then
case(DEC) is
WHEN x"0" => segments <= "00000011"; --0
WHEN x"1" => segments <= "10011111"; --1
WHEN x"2" => segments <= "00100101"; --2
WHEN x"3" => segments <= "00001101"; --3
WHEN x"4" => segments <= "10011001"; --4
WHEN x"5" => segments <= "01001001"; --5
WHEN x"6" => segments <= "01000001"; --6
WHEN x"7" => segments <= "00011111"; --7
WHEN x"8" => segments <= "00000001"; --8
WHEN x"9" => segments <= "00001001"; --9
WHEN x"F" => segments <= "11111101"; --signo
WHEN OTHERS => segments <= "11111111"; --apagado
end case;
else segments<=V; end if;

when "10" =>AN<="11111101";
if selOP=x"5" then segments <= N; --andV
elsif selOP=x"6" then segments <= R; --orV
elsif selOP=x"7" then segments <= O; --xorV
elsif selOP=x"8" then segments <= O; --notV
elsif selOP=x"1" or selOP=x"2" or selOP=x"3" or selOP=x"4" 
or selOP =x"A" or selOP=x"B"then
case(CEN) is
WHEN x"0" => segments <= "00000011"; --0
WHEN x"1" => segments <= "10011111"; --1
WHEN x"2" => segments <= "00100101"; --2
WHEN x"3" => segments <= "00001101"; --3
WHEN x"4" => segments <= "10011001"; --4
WHEN x"5" => segments <= "01001001"; --5
WHEN x"6" => segments <= "01000001"; --6
WHEN x"7" => segments <= "00011111"; --7
WHEN x"8" => segments <= "00000001"; --8
WHEN x"9" => segments <= "00001001"; --9
WHEN x"F" => segments <= "11111101"; --signo
WHEN OTHERS => segments <= "11111111"; --apagado
end case;
else segments<=V; end if;

when "11" =>AN<="11111110";
if selOP=x"5" then segments <= A; --andV
elsif selOP=x"6" then segments <= O; --orV
elsif selOP=x"7" then segments <= X; --xorV
elsif selOP=x"8" then segments <= N; --notV
elsif selOP=x"1" or selOP=x"2" or selOP=x"3" or selOP=x"4" 
or selOP =x"A" or selOP=x"B"then
case(SIGNO) is
WHEN x"0" => segments <= "00000011"; --0
WHEN x"1" => segments <= "10011111"; --1
WHEN x"2" => segments <= "00100101"; --2
WHEN x"3" => segments <= "00001101"; --3
WHEN x"4" => segments <= "10011001"; --4
WHEN x"5" => segments <= "01001001"; --5
WHEN x"6" => segments <= "01000001"; --6
WHEN x"7" => segments <= "00011111"; --7
WHEN x"8" => segments <= "00000001"; --8
WHEN x"9" => segments <= "00001001"; --9
WHEN x"F" => segments <= "11111101"; --signo
WHEN OTHERS => segments <= "11111111"; --apagado
end case; --signo
else segments<=V; end if;

when others =>AN<="11111111";
if selOP=x"5" then segments <= V; --andV
elsif selOP=x"6" then segments <= V; --orV
elsif selOP=x"7" then segments <= V; --xorV
elsif selOP=x"8" then segments <= V; --notV
elsif selOP=x"1" or selOP=x"2" or selOP=x"3" or selOP=x"4"
or selOP =x"A" or selOP=x"B" then
case(SIGNO) is
WHEN x"0" => segments <= "00000011"; --0
WHEN x"1" => segments <= "10011111"; --1
WHEN x"2" => segments <= "00100101"; --2
WHEN x"3" => segments <= "00001101"; --3
WHEN x"4" => segments <= "10011001"; --4
WHEN x"5" => segments <= "01001001"; --5
WHEN x"6" => segments <= "01000001"; --6
WHEN x"7" => segments <= "00011111"; --7
WHEN x"8" => segments <= "00000001"; --8
WHEN x"9" => segments <= "00001001"; --9
WHEN x"F" => segments <= "11111101"; --signo
WHEN OTHERS => segments <= "11111111"; --apagado
end case;
else segments<=V; end if;

end case;
end if;

end process; --Fin de proceso de displays
DISPLAY<=segments;


end Behavioral; --Fin de la arquitectura