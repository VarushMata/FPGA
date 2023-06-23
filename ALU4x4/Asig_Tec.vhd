
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.STD_LOGIC_arith.ALL;


entity Asig_Tec is
	PORT(
		clk,boton_pres,ind : in std_logic;
		NuA,nub,selopint : out std_logic_vector (3 downto 0)
	);
end Asig_Tec;

architecture Behavioral of Asig_Tec is
begin
process(clk,ind,boton_pres,NuA,NuB)
--Proceso para declarar A y B
variable u: integer :=0;

begin
if rising_edge(clk) then
--Se usa un ciclo for para poner 1 o 0 en las entradas de los nmeros para
--realizar las operaciones
 --Los nmeros se ingresan del bit ms significativo al menos
		if u=0 then
			if ind = '1' and boton_pres=x"0" then NuB(3)<='0';u:=u+1; --Si se presiona 0, se ingresa a 0
			elsif ind = '1' and boton_pres=x"1" then NuA(3)<='1';u:=u+1; --Al presionar 1 se ingresa como un 1
			else u:=0;
			end if;
		elsif u=1 then
			if ind = '1' and boton_pres=x"0" then NuA(2)<='0';u:=u+1; --Si se presiona 0, se ingresa a 0
			elsif ind = '1' and boton_pres=x"1" then NuA(2)<='1';u:=u+1; --Al presionar 1 se ingresa como un 1
			end if;
			
		elsif u=2 then
			if ind = '1' and boton_pres=x"0" then NuA(1)<='0';u:=u+1; --Si se presiona 0, se ingresa a 0
			elsif ind = '1' and boton_pres=x"1" then NuA(1)<='1';u:=u+1; --Al presionar 1 se ingresa como un 1
			end if;
			
		elsif u=3 then
			if ind = '1' and boton_pres=x"0" then NuA(0)<='0';u:=u+1; --Si se presiona 0, se ingresa a 0
			elsif ind = '1' and boton_pres=x"1" then NuA(0)<='1';u:=u+1; --Al presionar 1 se ingresa como un 1
			end if;
			
		elsif u=4 then
			if ind = '1' and boton_pres=x"0" then NuB(3)<='0';u:=u+1; --Si se presiona 0, se ingresa a 0
			elsif ind = '1' and boton_pres=x"1" then NuB(3)<='1';u:=u+1; --Al presionar 1 se ingresa como un 1
			end if;
			
		elsif u=5 then
			if ind = '1' and boton_pres=x"0" then NuB(2)<='0';u:=u+1; --Si se presiona 0, se ingresa a 0
			elsif ind = '1' and boton_pres=x"1" then NuB(2)<='1';u:=u+1; --Al presionar 1 se ingresa como un 1
			end if;
			
		elsif u=6 then
			if ind = '1' and boton_pres=x"0" then NuB(1)<='0';u:=u+1; --Si se presiona 0, se ingresa a 0
			elsif ind = '1' and boton_pres=x"1" then NuB(1)<='1';u:=u+1; --Al presionar 1 se ingresa como un 1
			end if;
			
		elsif u=7 then
			if ind = '1' and boton_pres=x"0" then NuB(0)<='0';u:=u+1; --Si se presiona 0, se ingresa a 0
			elsif ind = '1' and boton_pres=x"1" then NuB(0)<='1';u:=u+1; --Al presionar 1 se ingresa como un 1
			end if;
				
	--Proceso para obtener el valor para seleccionar la operacin
	--Leemos el siguiente valor, el cual ser presionado en el teclado
	--Dependiendo del valor se mostrar la operacin deseada
		elsif u=8 then
			if ind = '1' and (boton_pres = x"1" or boton_pres = x"2" or boton_pres = x"3" or boton_pres = x"A"
			or boton_pres = x"4" or boton_pres = x"5" or boton_pres = x"6" or boton_pres = x"B") then selOPint<=boton_pres;
			elsif ind ='1' and boton_pres=x"E" then u:=0; NuA<=x"0";NuB<=x"0"; selOPint<=x"0";
			end if;
end if;
end if;
end process;	

end Behavioral;

