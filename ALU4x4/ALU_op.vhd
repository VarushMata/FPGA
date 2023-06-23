--------------------------------------------------------
--MEXILOGICS
--programa de sumador, restador, divisor y multiplicador 
--de 4 bits con salida a display y led testigos con BCD
--shift and add 3
--------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
--------------------------------------------------------
--Declaracin de la entidad

entity ALU_op is
Port(
	A,B: in std_logic_vector(3 downto 0); --Entradas ingresadas por teclado 4x4
	c: inout std_logic_vector (7 downto 0); --Salida a LED testigos
	signo : out std_logic_vector (3 downto 0); --Salida para el signo
	selOP: in std_logic_vector (3 downto 0);
	ledt : out std_logic_vector (7 downto 0)

);
end ALU_op;

--Declaracin de la arquitectura
architecture Behavioral of ALU_op is
begin
--Este proceso realiza las operaciones segn el selector selOP
process(A,B,selOP)
begin
	case selOP is
	when x"1"=>c<=("0000" & A) + ("0000" & B); signo <= x"E"; --suma
	when x"2"=>
					if A>B then c<=("0000" & A)-("0000" & B); signo <= x"E";
					else c<=("0000" & B)-("0000" & A); signo <= x"F";
					end if;
	when x"3"=>c<= A*B; signo <= x"E";
	when x"4"=> 
					if B = x"0" then c <=x"FF"; signo <= x"E"; --Si es divisin entre 0 
					else c <= conv_std_logic_vector((conv_integer(A)/conv_integer(B)),8); signo <= x"E"; --Cualquier otro caso
					end if;
	when x"5"=>c<= ("0000" & A) and ("0000" & B); --AND
	when x"6"=>c<= ("0000" & A) or ("0000" & B); --OR
	when x"7"=>c<= ("0000" & A) xor ("0000" & B); --XOR
	when x"8"=>c<= "0000" & not(A);--NOT A
	when x"A"=>c<="0000"& A;
	when x"B"=>c<="0000" & B;
	when others =>c<=(others =>'0'); signo<=x"E";--Cualquier otro caso
	end case;
end process;
ledt <= c;
end Behavioral;

