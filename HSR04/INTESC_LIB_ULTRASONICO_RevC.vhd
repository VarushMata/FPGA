----------------------------------------------------------------------------------
-- MEXILOGICS LIBRERA PARA MEDIR LA DISTANCIA EN CM CON EL SENSOR ULTRASNICO HSR-04
------------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity INTESC_LIB_ULTRASONICO_RevC is

generic(
			FPGA_CLK : INTEGER := 50_000_000
);

PORT(
		CLK 			 : IN  STD_LOGIC;                   -- Reloj del FPGA.
		ECO 			 : IN  STD_LOGIC;                   -- Eco del sensor ultrasnico.
		TRIGGER 		 : OUT STD_LOGIC;                   -- Trigger del sensor ultrasnico.
		DATO_LISTO 	 : OUT STD_LOGIC;                   -- Bandera que indica cuando el valor de la distancia es correcto.
		DISTANCIA_CM : OUT STD_LOGIC_VECTOR(8 DOWNTO 0) -- Valor de la distancia en centmetros-
);

end INTESC_LIB_ULTRASONICO_RevC;

architecture Behavioral of INTESC_LIB_ULTRASONICO_RevC is


CONSTANT VAL_1US 					  : INTEGER := (FPGA_CLK/1_000_000); -- Constante con el nmero de periodos de CLK que hay en un microsegundo. Se utiliza para el clculo de la distancia.
CONSTANT ESCALA_PERIODO_TRIGGER : INTEGER := (FPGA_CLK/16);        -- Constante para generar el periodo del Trigger.
CONSTANT ESCALA_TRIGGER 		  : INTEGER := (FPGA_CLK/100_000);   -- Constante para generar el ciclo de trabajo del Trigger.

COMPONENT DIVISION_ULTRASONICO_RevA
PORT(
	CLK       : IN  std_logic;
	INI       : IN  std_logic;
	DIVIDENDO : IN  std_logic_vector(31 downto 0);
	DIVISOR   : IN  std_logic_vector(31 downto 0);          
	RESULTADO : OUT std_logic_vector(31 downto 0);
	OK        : OUT std_logic
	);
END COMPONENT;

signal ok		  				 : std_logic;                                      -- Bandera que indica fin de divisin.
signal ini		  				 : std_logic;                                      -- Bit que inicia el proceso de divisin.
signal trigger_s 				 : std_logic := '0';                               -- Bit auxiliar para Trigger y tambin se utiliza como indicador para mandar la distancia.
signal calcular 				 : std_logic := '0';                               -- Bit que indica cundo calcular la divisin.
signal dividendo 				 : std_logic_vector(31 downto 0);                  -- Operadior dividendo.
signal divisor   				 : std_logic_vector(31 downto 0);                  -- Operador divisor.
signal resultado 				 : std_logic_vector(31 downto 0);                  -- Resultado de la divisin.
signal conta_trigger 		 : integer range 0 to escala_periodo_trigger := 0; -- Contador para la generacin del Trigger.
signal conta_eco 				 : integer := 0;                                   -- Contador para el clculo del tiempo de Eco.
signal escala_total 			 : integer := 0;                                   -- Auxiliar que adquiere el nmero de periodos que se obtubieron con Eco en '1' y as calcular la distancia.
signal tiempo_microsegundos : integer := 0;                                   -- Seal que guarda el tiempo en microsegundos.
signal edo_res : integer range 0 to 7 := 0;                                   -- Seal para la mquina de estados que calcula la distancia.
signal edo_eco : integer range 0 to 7 := 0;                                   -- Seal para la mquina de estados que calcula los periodos de CLK con Eco en '1'.

begin

-- Instancia del componente que realiza la divisin.
Inst_DIVISION_ULTRASONICO_RevA: DIVISION_ULTRASONICO_RevA PORT MAP(
	CLK, INI, DIVIDENDO, DIVISOR, RESULTADO, OK );

--PROCESO QUE GENERA SEAL DE TRIGGER---
process(CLK)
begin
	if rising_edge(CLK) then
		conta_trigger <= conta_trigger+1;
		if conta_trigger = 0 then
			trigger_s <= '1';
		elsif conta_trigger = escala_trigger then
			trigger_s <= '0';
		elsif conta_trigger = escala_periodo_trigger then
			conta_trigger <= 0;
		end if;
	end if;
end process;

TRIGGER <= trigger_s;
----------------------------------------

--PROCESO QUE OBTIENE ESCALA DE ECO---
process(CLK)
begin
if rising_edge(CLK) then
	case(edo_eco) is
		when 0 => if eco = '1' then -- Se espera a que Eco se ponga a '1'.
					edo_eco <= 1;
					end if;
		when 1 => if eco = '1' then -- Cuenta el nmero de periodos cuando Eco se encuentra en '1'.
						conta_eco <= conta_eco+1;
					else
						edo_eco <= 2;
					end if;
					
		when 2 => conta_eco <= 0; -- Se reinicia el contador cuando Eco se hace '0' y 
		--se almacena el ltimo valor registrado en "conta_eco". Se pone a '1' "calcular".
					 escala_total <= conta_eco;
					 calcular <= '1';
					 edo_eco <= 3;
					 
		when 3 => calcular <= '0'; -- Se desactuva el bit "calcular" y se regresa al estado 0.
					 edo_eco <= 0;
		when others => null;
	end case;
--	if edo_eco = 0 then 
--		if eco = '1' then
--			edo_eco <= 1;
--		end if;
--		
--	elsif edo_eco = 1 then
--		if eco = '1' then -- Cuenta el nmero de periodos cuando Eco se encuentra en '1'.
--			conta_eco <= conta_eco+1;
--		else
--			edo_eco <= 2;
--		end if;
--		
--	elsif edo_eco = 2 then -- Se reinicia el contador cuando Eco se hace '0' y se almacena el ltimo valor registrado en "conta_eco". Se pone a '1' "calcular".
--		conta_eco <= 0;
--		escala_total <= conta_eco;
--		calcular <= '1';
--		edo_eco <= 3;
--			
--	elsif edo_eco = 3 then -- Se desactuva el bit "calcular" y se regresa al estado 0.
--		calcular <= '0';
--		edo_eco <= 0;
--		
--	end if;
end if;
end process;
--------------------------------------

--Proceso que divide y obtiene el resultado final--
process(CLK)
begin
if rising_edge(CLK) then -- Espera a que transcurra el primer trigger para realizar el primer clculo y tenerlo listo en el segundo trigger.
	case(edo_res) is
	when 0 => if trigger_s = '1' then
					edo_res <= 1;
				 end if;
	when 1 => if calcular = '1' then -- Espera a que se le indique cundo realizar la divisin para obtener los microsegundos que dur "Eco".
					dividendo <= conv_std_logic_vector(escala_total,32);
					divisor <= conv_std_logic_vector(VAL_1US,32);
					edo_Res <= 3;
				 end if;
	when 3 => if ok = '1' then -- Espera a que finalice el proceso de divisin.
					edo_res <= 4;
					ini <= '0';
				 else
					ini <= '1';
				 end if;
	when 4 => dividendo <= resultado; -- Se realiza la divisin Tmicrosegundos/58 para obtener el valor de la distancia.
				 divisor <= conv_std_logic_vector(58,32);
				 edo_res <= 5;
	when 5 => -- Espera a que finalice el proceso de divisin.
				if ok = '1' then
					edo_res <= 6;
					ini <= '0';
				else
					ini <= '1';
				end if;
	when 6 => -- Espera a que Trigger se ponga a '1' y se mande la distancia por el puerto "DISTANCIA_CM". Se activa la bandera "DATO_LISTO".
				if trigger_s = '1' then
					DATO_LISTO <= '1';
					DISTANCIA_CM <= resultado(8 downto 0);
					edo_res <= 7;
				end if;
	when 7 => -- Se desactiva la bandera "DATO_LISTO".
				DATO_LISTO <= '0';
				edo_res <= 1;
	when others => null;
	end case;
	
--	if edo_res = 0 then
--		if trigger_s = '1' then
--			edo_res <= 1;
--		end if;
--		
--	elsif edo_res = 1 then -- Espera a que se le indique cundo realizar la divisin para obtener los microsegundos que dur "Eco".
--		if calcular = '1' then
--			dividendo <= conv_std_logic_vector(escala_total,32);
--			divisor <= conv_std_logic_vector(VAL_1US,32);
--			edo_Res <= 3;
--		end if;
--		
--	elsif edo_res = 3 then -- Espera a que finalice el proceso de divisin.
--		if ok = '1' then
--			edo_res <= 4;
--			ini <= '0';
--		else
--			ini <= '1';
--		end if;
--		
--	elsif edo_res = 4 then -- Se realiza la divisin Tmicrosegundos/58 para obtener el valor de la distancia.
--		dividendo <= resultado;
--		divisor <= conv_std_logic_vector(58,32);
--		edo_res <= 5;
--		
--	elsif edo_res = 5 then -- Espera a que finalice el proceso de divisin.
--		if ok = '1' then
--			edo_res <= 6;
--			ini <= '0';
--		else
--			ini <= '1';
--		end if;
--	
--	elsif edo_res = 6 then -- Espera a que Trigger se ponga a '1' y se mande la distancia por el puerto "DISTANCIA_CM". Se activa la bandera "DATO_LISTO".
--		if trigger_s = '1' then
--			DATO_LISTO <= '1';
--			DISTANCIA_CM <= resultado(8 downto 0);
--			edo_res <= 7;
--		end if;
--		
--	
--	elsif edo_res = 7 then -- Se desactiva la bandera "DATO_LISTO".
--		DATO_LISTO <= '0';
--		edo_res <= 1;
--	
--	end if;
end if;
end process;



end Behavioral;

