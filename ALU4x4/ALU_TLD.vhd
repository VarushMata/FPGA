--Sumador, restador, multiplicador y divisin 
--Con salida a display
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
--Declaracin de la entidad
entity ALU_TLD is
Port(
	CLK: in std_logic; --Reloj de 50MHz
	COLUMNAS : in std_logic_vector(3 downto 0); -- columnas teclado 4x4
	FILAS : out std_logic_vector (3 downto 0); -- filas teclado 4x4
	LEDs : out std_logic_vector (7 downto 0); --Salida a LEDs testigos
	DISPLAY: out std_logic_vector (7 downto 0); --Segmentos del display
	AN: out std_logic_vector (7 downto 0) --nodos del display
);
end ALU_TLD;

architecture Behavioral of ALU_TLD is


component LIB_TEC_MATRICIAL_4x4_INTESC_RevA is

--Llamando a la librera para controlar el teclado
GENERIC(
			FREQ_CLK : INTEGER := 50_000_000         --FRECUENCIA DE LA TARJETA
);

PORT(
	CLK 		  : IN  STD_LOGIC; 						  --RELOJ FPGA
	COLUMNAS   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0); --PUERTO CONECTADO A LAS COLUMNAS DEL TECLADO
	FILAS 	  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); --PUERTO CONECTADO A LA FILAS DEL TECLADO
	BOTON_PRES : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); --PUERTO QUE INDICA LA TECLA QUE SE PRESION
	IND		  : OUT STD_LOGIC							  --BANDERA QUE INDICA CUANDO SE PRESION UNA TECLA (SLO DURA UN CICLO DE RELOJ)
);

end component LIB_TEC_MATRICIAL_4x4_INTESC_RevA;

--Declaracin de seal que indica los valores de A y de B
signal NuA:std_logic_vector(3 downto 0); --Asigna el nmero A
signal NuB:std_logic_vector(3 downto 0); --Asigna el nmero B

--Declaracin de seal que indica si se presion un botn
signal boton_pres : std_logic_vector (3 downto 0) := (others => '0');

--Declaracin de seal que indica la direccin del botn presionado
signal ind : std_logic := '0';

--Declaracin de seales del divisor
signal SAL_400Hz: std_logic;

--Declaracin de seales del resultado
signal resultado: std_logic_vector (7 downto 0);

--Declaracin de seales de asignacin de U-D-C-UM
signal UNIint,DECint,CENint,signoint: std_logic_vector (3 downto 0); --U-D-C-signo

--Declaracin del selector
signal selOPint: std_logic_vector (3 downto 0):="0000";

begin

libreria : LIB_TEC_MATRICIAL_4x4_INTESC_RevA 
Generic map  (FREQ_CLK => 50000000)
	port map (
	CLK => CLK,
	COLUMNAS => COLUMNAS ,
	FILAS => FILAS,
	BOTON_PRES => BOTON_PRES,
	ind => IND
);

process(clk,ind,boton_pres,NuA,NuB)
--Proceso para declarar A y B
variable u: integer :=0;

begin
if rising_edge(clk) then
--Se usa un ciclo for para poner 1 o 0 en las entradas de los nmeros para
--realizar las operaciones
 --Los nmeros se ingresan del bit ms significativo al menos
		if u=0 then
			if ind = '1' and boton_pres=x"0" then NuA(3)<='0';u:=u+1; --Si se presiona 0, se ingresa a 0
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
			or boton_pres = x"4" or boton_pres = x"5" or boton_pres = x"6" or boton_pres = x"B" or boton_pres =x"7"
			or boton_pres = x"8") then selOPint<=boton_pres;
			elsif ind ='1' and boton_pres=x"E" then u:=0; NuA<=x"0";NuB<=x"0"; selOPint<=x"0";
			end if;
end if;
end if;
end process;	

--Declaracin del cto lgico
U1: entity work.ALU_op port map(
	A => NuA,
	B => NuB,
	C => resultado,
	selOP => selOpint,
	signo => signoint,
	ledt=> leds
);

--Declaracin del componente que convierte de binario a decimal
--por la metodologa de correr y sumar 3 (shift and add 3)
U2: entity work.SHIFT_ADD port map(
	C => resultado, --a seal p/LD y srmd (U1)
	UNI => UNIint,  -- Seales a los displays
	DEC => DECint,
	CEN => CENint
);

--Controlador de display
U3: entity work.DISPLAYS port map(
	UNI => UNIint,  -- Seales a los displays
	DEC => DECint,
	CEN => CENint,
	signo => signoint,
	SAL_400Hz => SAL_400Hz, --A seal de reloj U4
	DISPLAY => DISPLAY, --A segmentos de display
	AN => AN, --A nodos del display
	selOP => selOPint
);

--Declaracin del componente divisor (2.5ms=400Hz)
U4: entity work.DIV_CLK port map(
	clk => clk,
	SAL_400Hz => SAL_400Hz
);

end Behavioral;
