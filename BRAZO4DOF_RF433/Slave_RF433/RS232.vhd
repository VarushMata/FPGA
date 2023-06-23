----------------------------------------------------------------------------------
-- MEXILOGICS: CONTROL POR PROTOCOLO RS232 UTILIZANDO LA LIBRERÍA DE INTESC
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity RS232 is
--El generic es til cuando RS232 es parte de un TOP. SI no es parte de un TOP
--entonces se deben poner tanto la frecuencia del FPGA como los BAUDIOS como valores 
--contantes en el generic
generic	(	FPGA_CLK :			INTEGER := 50000000;	--FRECUENCIA DEL FPGA POR EJEMPLO 50000000 
				BAUD_RS232 :		INTEGER := 9600		--BAUDIOS. POR EJEMPLO 9600
			);
port	(	CLK : 		in std_logic ;			--Reloj de FPGA
			RX :			in std_logic ;			--Pin de recepcin de RS232
			TX_INI :		in std_logic ;			--Debe ponerse a '1' para inciar transmisin
			TX_FIN :		out std_logic ;		--Se pone '1' cuando termina la transmisin
			TX :			out std_logic ;		--Pin de transmisin de RS232
			RX_IN :		out std_logic ;		--Se pone a '1' cuando se ha recibido un Byte. Solo dura un 
														--Ciclo de reloj
			DATAIN :		in std_logic_vector(7 downto 0); --Puerto de datos de entrada para transmisin
			DOUT :		out std_logic_vector(7 downto 0) --Puerto de datos de salida para recepcin
		);
end RS232; 

architecture Behavioral of RS232 is

CONSTANT 	FPGA_CLK2 :			INTEGER := FPGA_CLK;						
CONSTANT		BAUD_RS2322 :		INTEGER := BAUD_RS232 ;					
CONSTANT		BAUD_FPGA2 :		INTEGER := FPGA_CLK2/BAUD_RS2322 ;
CONSTANT 	CLKBAUD2 :			INTEGER := BAUD_FPGA2/2 ;				

signal flanco_bajada :  		std_logic := '0';
signal clk_ini :					std_logic := '0';
signal clk_tx_ini :				std_logic := '0';
signal clk_flanco :				std_logic := '0';
signal clk_tx_flanco :			std_logic := '0';
signal rx_vector : 				std_logic_vector(4 downto 0) ;
signal rx_vector2 : 				std_logic_vector(4 downto 0) ;
signal tx_data :					std_logic_vector(7 downto 0) ;
signal tx_data2 :					std_logic_vector(7 downto 0) ;
signal dout_paralelo :			std_logic_vector(9 downto 0) ;
signal clk_baud :					natural range 0 to CLKBAUD2 - 1;
signal clk_tx_baud :				natural range 0 to BAUD_FPGA2 - 1;
signal paralelo_paso :			natural range 0 to 6 := 0 ;
signal tx_maquina :				natural range 0 to 6 := 0 ;
signal n :							natural range 0 to 10 := 0 ;
signal tx_n :						natural range 0 to 10 := 0 ;

begin

--Registro de corrimiento que muestrea RX en busca de condicion de INICIO
rx_vector <= rx_vector2(3 downto 0) & RX;

process(CLK)
begin
if rising_edge(CLK) then
	rx_vector2 <= rx_vector;
end if;
end process;
----------------------------------------------

--Genera un flanco de bajada siempre que la condicion "1100" sea cierta
flanco_bajada <= '1' when rx_vector(4 downto 1) = "1100" else
						'0';
						
				
--Maquina de estados que controla la rececion de 1 byte				
RECEPCION: process(CLK)
begin
if rising_edge(CLK) then
	if paralelo_paso = 0 then
		n <= 0;
		--Si hay un flanco de bajada en el estado 0 se debe a una condicion de inicio
		if flanco_bajada = '1' then
			paralelo_paso <= 1;
		else
			paralelo_paso <= 0;
		end if;
		RX_IN <= '0';
	elsif paralelo_paso = 1 then
		--Inicia reloj de BAUDIOS
		clk_ini <= '1';
		paralelo_paso <= 2;
	elsif paralelo_paso = 2 then
		--Este flanco indica la mitad del bit de inicio
		if clk_flanco = '1' then
			paralelo_paso <= 5 ;
		else
			paralelo_paso <= 2;
		end if;
	elsif paralelo_paso = 3 then
		--Si hay un flanco, quiere decir que ha terminado un bit e inicia
		--el siguiente
		if clk_flanco = '1' then
			paralelo_paso <= 4;
		else
			--SI no hay flanco, esta condicin indica la salida y el trmino de la 
			--recepcion
			if n < 10 then			
				paralelo_paso <= 3;
			else
				n <= 10;
				paralelo_paso <= 6;
			end if;
		end if;
	elsif paralelo_paso = 4 then
		--Si hay un flanco, entonces indica que se encuentra en medio de la recepcion
		--y debe ir al paso cinco para incremntar "n"
		if clk_flanco = '1' then
			paralelo_paso <= 5 ;
		else
			paralelo_paso <= 4;
		end if;
	elsif paralelo_paso = 5 then
		--Recibe bit a bit la informacin de entrada. "n" debe contar hasta 8
		n <= n + 1 ;
		dout_paralelo(n) <= RX ;
		paralelo_paso <= 3;
	else
		--En este ltimo paso, termina la recepcin y pone a un la bandera RX_IN indicando
		--que se ha recibido el BYTE y regresa al paso 0 (esperando otra recepcin)
		DOUT<= dout_paralelo(8 downto 1);
		clk_ini <= '0';
		n <= 0;
		paralelo_paso <= 0;
		RX_IN <= '1';
	end if;
end if;
end process;
		
--Reloj con frecuencia de BAUDIOS/2 para entrada. Siempre que termina, enva un flanco en
--clk_flanco
process(CLK)
begin
if rising_edge(CLK) then
	if clk_ini = '1' then
		if clk_baud < (CLKBAUD2-1) then
			clk_baud <= clk_baud + 1;
			clk_flanco <= '0';
		else
			clk_baud <= 0;
			--Pone clk_flanco a '1' en el desborde
			clk_flanco <= '1';
		end if;
	else
		clk_flanco <= '0';
		clk_baud <= 0;
	end if;
end if;
end process;

--Mquina de estados que controla transmisin de 1 BYTE
TRANSMICION: process(CLK)
begin
if rising_edge(CLK) then
	if tx_maquina = 0 then
		TX <= '1';
		clk_tx_ini <= '0';
		tx_n <= 0;
		TX_FIN <= '0';
		--Para iniciar la transmisin, debemos poner TX_INI a '1' manualmente o a travs
		--de otro modulo
		if TX_INI = '1' then
			tx_maquina <= 1;
			--Cuando se pone TX_INI a '1', se carga la informacin que se necesita enviar en 
			--tx_data usando el puerto DATAIN
			tx_data <= DATAIN ;
		else
			tx_maquina <= 0;
			tx_data <= "00000000";
		end if;
	elsif tx_maquina = 1 then
		--Hace TX = '0', es decir, es el bit de inicio. Tambin inicia el reloj para BAUDIOS
		--de transmisin
		TX <= '0';
		clk_tx_ini <= '1';
		tx_maquina <= 2;
	elsif tx_maquina = 2 then
		--El reloj de BAUDIOS indica cuando se ha enviado un bit completo. Cuando este bit
		--ha sido enviado, entonces se carga en TX el siguiente bit usando la instruccin 
		--TX <= tx_data(0) y se pasa al estado 3
		if clk_tx_flanco = '1' then
			tx_maquina <= 3 ;
			TX <=tx_data(0);
		else
			tx_maquina <= 2;
		end if;
	elsif tx_maquina = 3 then
		--Se usa un registro de corrimiento para recorrer la inforamcion del registro tx_data.
		--Tx_data2 es un registro auxiliar que recibe la informacin recorrida un lugar a la 
		--derecha. Antes de recorrer la informacion se compara tx_n para saber cuantos bits
		--ya se han enviado. 
		if tx_n < 9 then
			tx_n <= tx_n + 1;
			tx_data2 <= '1' & tx_data(7 downto 1);
			tx_maquina <= 4;
		--SI ya se envio el bit de paro, entonces la mquina de estados se va al ltimo estado
		else
			tx_maquina <= 5;
		end if;
	elsif tx_maquina = 4 then
		--Si an no se han enviado los 10 bits (8 de informacin, 1 de inicio y 1 de paro) entonces
		--actualiza el registr tx_data con el valor de tx_data2 (que tiene la informacin recorrida
		--un lugar a la derecha) y regresa al estado 2
		tx_data <= tx_data2;
		tx_maquina <= 2;
	else
		--Si ya esta en el ltimo estado, espera a que pongamos TX_INI a '0' antes de regresar al
		--estado inicial. Eso ha sido implementado como proteccin contra posibles colisiones
		--de BYTES
		if TX_INI = '1' then
			TX_FIN <= '1' ;
			tx_maquina <= 5 ;
		else
			TX_FIN <= '0' ;
			tx_maquina <= 0;
		end if;
	end if;
end if;
end process;


--RELOJ DE BAUDIOS PARA TRANSMISIN
process(CLK)
begin
if rising_edge(CLK) then
	if clk_tx_ini = '1' then
		if clk_tx_baud < (BAUD_FPGA2-1) then
			clk_tx_baud <= clk_tx_baud + 1;
			clk_tx_flanco <= '0';
		else
			clk_tx_baud <= 0;
			--Pone clk_tx_flanco en el desborde
			clk_tx_flanco <= '1';
		end if;
	else
		clk_tx_flanco <= '0';
		clk_tx_baud <= 0;
	end if;
end if;
end process;

end Behavioral;