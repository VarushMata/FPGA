----------------------------------------------------------------------------------
-- COPYRIGHT 2019 Jesus Eduardo Méndez Rosales.
--This program is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU General Public License
--along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
--
-- Description: Las caracteristicas de este modulo son:
--					- Frecuencia variable (Máx 1 MHz).
--             - Selección de fase y polaridad.
--             - Selector de maestro ('0') o esclavo ('1').
--             - Transferencia Full Duplex característica del protocolo.
--             - Bit de control para transmisión de N bits en modo maestro.
--
--
--	CPOL = '0'
-- 
--      FPGA_CLK __________/¯¯¯¯\____/¯¯¯¯\____/¯¯¯¯\____/¯¯¯¯\____/¯¯¯¯\____/¯¯¯¯\____/¯¯¯¯\____/¯¯¯¯\_____________
--
--	CPOL = '1'
--
--      FPGA_CLK ¯¯¯¯¯¯¯¯¯¯\____/¯¯¯¯\____/¯¯¯¯\____/¯¯¯¯\____/¯¯¯¯\____/¯¯¯¯\____/¯¯¯¯\____/¯¯¯¯\____/¯¯¯¯¯¯¯¯¯¯¯¯¯
--
-- CPHA = '0'
--
--          MISO -----bit 7-----|--bit 6--|--bit 5--|--bit 4--|--bit 3--|--bit 2--|--bit 1--|--bit 0--|-------------------
-- 
--          MOSI -----bit 7-----|--bit 6--|--bit 5--|--bit 4--|--bit 3--|--bit 2--|--bit 1--|--bit 0--|-------------------
--
-- CPHA = '1'
--
--          MISO ----------|--bit 7--|--bit 6--|--bit 5--|--bit 4--|--bit 3--|--bit 2--|--bit 1--|-----bit 0--------------
--
--          MOSI ----------|--bit 7--|--bit 6--|--bit 5--|--bit 4--|--bit 3--|--bit 2--|--bit 1--|-----bit 0--------------
--
--            CS ¯¯¯¯¯¯¯\_______________________________________________________________________________/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
-- 
--     FIN_RT(M) ________________________________________________________________________________________/¯¯\_____________
--
--     FIN_RT(E) ___________________________________________________________________________________________/¯¯\__________
--
--   DATA_OUT(M) -------------------------------------- XXX ---------------------------------------------|---- VALIDO ----
--
--   DATA_OUT(E) ----------------------------------------- XXX ---------------------------------------------|-- VALIDO ---
--
--
--------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LIB_SPI_REVB is

GENERIC( FPGA_CLK : INTEGER := 50_000_000; -- Frecuencia de reloj.
			FREC_SPI : INTEGER := 1_000;      -- Frecuencia SPI.
			CPOL     : STD_LOGIC := '1';      -- Polaridad SPI.
			CPHA     : STD_LOGIC := '1';      -- Fase SPI.
			SEL_ME   : STD_LOGIC := '0';      -- Selector Maestro/Esclavo. '0' Maestro, '1' Esclavo.
			CICLOS_CLK : INTEGER := 8			 -- Número de ciclos de reloj que hay entre el CS en bajo y el primer flanco de reloj del SPI	
);

PORT( CLK      : IN  STD_LOGIC;                    -- Reloj de FPGA.
		INI_T    : IN  STD_LOGIC;                    -- Inicia transmisión.
		DATA_IN  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0); -- Byte a enviar.
		DATA_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Byte recibido.
		FIN_RT   : OUT STD_LOGIC;                    -- Bit que indica fin de recepción o transmisión.
		-- SPI --
		CLK_SPI  : INOUT STD_LOGIC;                  -- Reloj de SPI. De salida en modo maestro, de entrada en modo esclavo.
		MISO     : INOUT STD_LOGIC;                  -- Puerto MISO. De entrada como maestro, de salida como esclavo.
		MOSI     : INOUT STD_LOGIC;                  -- Puerto MOSI. De salida como maestro, de entrada como esclavo.
		CS       : INOUT STD_LOGIC                   -- Puerto CS. De salida como maestro, de entrada como esclavo.
);

end LIB_SPI_REVB;

architecture Behavioral of LIB_SPI_REVB is

CONSTANT ESCALA_FRECUENCIA : INTEGER := (FPGA_CLK / FREC_SPI)/2;  -- Escala para generar la frecuencia de reloj especificada en FREC_SPI.
CONSTANT ESCALA_STBY 		: INTEGER := FPGA_CLK / 3_125_000;  -- Escala para generar un tiempo de espera entre el CS en bajo y el MISO tome posesión del bus. 

signal ok_clk           : std_logic := '0'; -- Inicia el proceso que genera la señal de reloj SPI en modo maestro.
signal miso_in          : std_logic := 'Z'; -- Señal auxiliar para datos de entrada en modo maestro.
signal miso_out         : std_logic := 'Z'; -- Señal auxiliar para datos de salida en modo esclavo.
signal mosi_in          : std_logic := 'Z'; -- Señal auxiliar para datos de salida en modo maestro.
signal mosi_out         : std_logic := 'Z'; -- Señal auxiliar para datos de entrada en modo esclavo.
signal clk_spi_in       : std_logic := 'Z'; -- Señal auxiliar para reloj de entrada en modo esclavo.
signal clk_spi_out      : std_logic := 'Z'; -- Señal auxiliar para reloj de entrada en modo maestro.
signal cs_in            : std_logic := 'Z'; -- Señal auxiliar para chip-select de entrada en modo esclavo.
signal cs_out           : std_logic := 'Z'; -- Señal auxiliar para chip-select de entrada en modo maestro.
signal fin_r            : std_logic := '0'; -- Señal auxiliar para "FIN_RT" en proceso de recepción.
signal fin_t            : std_logic := '0'; -- Señal auxiliar para "FIN_RT" en proceso de transmisión.
signal okm_fs           : std_logic := '0'; -- Bit que indica que se detectó un flanco de subida en modo maestro. 
signal okm_fb           : std_logic := '0'; -- Bit que indica que se detectó un flanco de bajada en modo maestro. 
signal oke_fs           : std_logic := '0'; -- Bit que indica que se detectó un flanco de subida en modo esclavo. 
signal oke_fb           : std_logic := '0'; -- Bit que indica que se detectó un flanco de bajada en modo esclavo. 
signal cap_r            : std_logic := '0'; -- Bit que indica cuando se haya hecho una recepción de 8 bits;
signal cap_rm           : std_logic := '0'; -- Bit que indica cuando se haya hecho una recepción de 8 bits;
signal oke_pha          : std_logic := '0'; -- Bit que provoca el desfase en la transmisión en modo esclavo.
signal okm_pha          : std_logic := '0'; -- Bit que provoca el desfase en la transmisión en modo maestro.
signal regm_fs          : std_logic_vector(3 downto 0) := (others => '0'); -- Registro de corrimiento para detectar flancos de subida en modo maestro.
signal regm_fb          : std_logic_vector(3 downto 0) := (others => '0'); -- Registro de corrimiento para detectar flancos de bajada en modo maestro.
signal rege_fs          : std_logic_vector(3 downto 0) := (others => '0'); -- Registro de corrimiento para detectar flancos de subida en modo esclavo.
signal rege_fb          : std_logic_vector(3 downto 0) := (others => '0'); -- Registro de corrimiento para detectar flancos de bajada en modo esclavo.
signal data_in_e        : std_logic_vector(7 downto 0) := (others => '0'); -- Buffer de entrada en modo esclavo.
signal data_out_e       : std_logic_vector(7 downto 0) := (others => '0'); -- Buffer de entrada en modo esclavo.
signal data_in_m        : std_logic_vector(7 downto 0) := (others => '0'); -- Buffer que almacena temporalmente el byte a transmitir en modo maestro.
signal data_out_m       : std_logic_vector(7 downto 0) := (others => '0'); -- Buffer de entrada en modo esclavo.
signal data_rdy_e       : std_logic_vector(7 downto 0) := (others => '0'); -- Buffer de entrada en modo esclavo.
signal data_rdy_m       : std_logic_vector(7 downto 0) := (others => '0'); -- Buffer de entrada en modo esclavo.
signal edo_m            : integer range 0 to 10 := 0; -- Señal para máquina de estados de recepción en modo maestro.
signal edo_t            : integer range 0 to 10 := 0; -- Señal para máquina de estados de transmisión en modo maestro.
signal edo_re           : integer range 0 to 10 := 0; -- Señal para máquina de estados de recepción en modo esclavo.
signal edo_clk          : integer range 0 to 10 := 0; -- Señal para máquina de estados para generar la señal de reloj.
signal ir               : integer range 0 to 7  := 7; -- Contador para los bits de entrada en modo esclavo.
signal it               : integer range 0 to 7  := 7; -- Contador para los bits de entrada en modo esclavo.
signal irm              : integer range 0 to 7  := 7; -- Contador para los bits de entrada en modo maestro.
signal itm              : integer range 0 to 7  := 7; -- Contador para los bits de entrada en modo maestro.
signal conta_stbe       : integer range 0 to ESCALA_STBY := 0; -- Contador que genera retardo de Standby entre el CS en bajo y cuando MISO tome posesión del bus en modo esclavo.
signal offset_clk       : integer range 0 to 1 := 0; -- Cuenta el número de flancos para verificar que se hayan mandado 8 ciclos de reloj.
signal conta_reloj      : integer range 0 to 15 := 0; -- Cuenta el número de flancos para verificar que se hayan mandado 8 ciclos de reloj.
signal conta_ciclos     : integer range 0 to CICLOS_CLK-1 := 0; -- Cuenta el número de flancos para verificar que se hayan mandado 8 ciclos de reloj.
signal conta_frecuencia : integer range 0 to ESCALA_FRECUENCIA := 0; -- Contador para gener la frecuencia de reloj especificada en FREC_SPI.

begin

--------------------------------------------------------------------------------
----------------- ASIGANCIÓN DE SEÑALES DEPENDIENDO EL MODO --------------------
--------------------------------------------------------------------------------
FIN_RT     <= fin_r       when SEL_ME = '1' else fin_t;
MISO       <= miso_out    when SEL_ME = '1' else 'Z';
MOSI       <= mosi_out    when SEL_ME = '0' else 'Z';
miso_in    <= MISO        when SEL_ME = '0' else '0';
mosi_in    <= MOSI        when SEL_ME = '1' else '0';
CLK_SPI    <= clk_spi_out when SEL_ME = '0' else 'Z';
clk_spi_in <= CLK_SPI     when SEL_ME = '1' else '0';
CS         <= cs_out      when SEL_ME = '0' else 'Z';
cs_in      <= CS          when SEL_ME = '1' else '0';
DATA_OUT   <= data_rdy_e  when SEL_ME = '1' else data_rdy_m;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-------------------- DETECCIÓN DE FLANCOS EN AMBOS MODOS -----------------------
--------------------------------------------------------------------------------
process(CLK)
begin
if rising_edge(CLK) then
   rege_fs <= rege_fs(2 downto 0) & clk_spi_in;
   rege_fb <= rege_fb(2 downto 0) & clk_spi_in;
   regm_fs <= regm_fs(2 downto 0) & clk_spi_out;
   regm_fb <= regm_fb(2 downto 0) & clk_spi_out;
   
	if regm_fs = "0011" then -- Detecta flancos de subida del reloj generado en modo maestro.
      okm_fs <= '1';
   else
      okm_fs <= '0';
   end if;

   if rege_fs = "0011" then -- Detecta flancos de subida del reloj generado en modo esclavo.
      oke_fs <= '1';
   else
      oke_fs <= '0';
   end if;
	
	if regm_fb = "1100" then -- Detecta flancos de bajada del reloj generado en modo maestro.
      okm_fb <= '1';
   else
      okm_fb <= '0';
   end if;

   if rege_fb = "1100" then -- Detecta flancos de bajada del reloj generado en modo esclavo.
      oke_fb <= '1';
   else
      oke_fb <= '0';
   end if;
end if;
end process;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
------------- PROCESO DE RECEPCIÓN Y TRANSMISIÓN EN MODO ESCLAVO ---------------
--------------------------------------------------------------------------------
-- Máquina de estados para recepción --
process(cs_in, CLK)
begin
if cs_in = '1' then -- Si el Chip Select esta desactivado la maquina de estados se detiene
   cap_r <= '0';
	ir <= 7;
	edo_re <= 0;
	
elsif rising_edge(CLK) then
	if edo_re = 0 then -- Estado dummy.
		edo_re <= 1;
		
	elsif edo_re = 1 then -- Controla las iteraciones con los detectores de flancos dependiendo la fase y polaridad que se haya seleccionado.
		cap_r <= '0';
		if CPOL = '0' then 						-- Polaridad 0
			if CPHA = '0' then 					-- Fase 0
				if oke_fs = '1' then
					data_in_e(ir) <= mosi_in;
					ir <= ir-1;
					if ir = 0 then
						ir <= 7;
						edo_re <= 3;
					end if;
				end if;
			else 										-- Fase 1
				if oke_fb = '1' then
					data_in_e(ir) <= mosi_in;
					ir <= ir-1;
					if ir = 0 then
						ir <= 7;
						cap_r <= '1';
						edo_re <= 4;
					end if;
				end if;
			end if;
		else 											-- Polaridad 1
			 if CPHA = '0' then					-- Fase 0
				if oke_fb = '1' then
					data_in_e(ir) <= mosi_in;
					ir <= ir-1;
					if ir = 0 then
						ir <= 7;
						edo_re <= 3;
					end if;
				end if;
			else										-- Fase 1
				if oke_fs = '1' then
					data_in_e(ir) <= mosi_in;
					ir <= ir-1;
					if ir = 0 then
						ir <= 7;
						cap_r <= '1';
						edo_re <= 4;
					end if;
				end if;
			end if;
		end if;
	
	elsif edo_re = 3 then -- Indica fin de recepción en el último flanco de la señal de reloj.
		if CPOL = '0' then
			if CPHA = '0' then
				if oke_fb = '1' then
					cap_r <= '1';
					edo_re <= 4;
				end if;
			else
			end if;
		else
			if CPHA = '0' then
				if oke_fs = '1' then
					cap_r <= '1';
					edo_re <= 4;
				end if;
			else
			end if;
		end if;

	elsif edo_re = 4 then -- Desactiva bandera de fin de recepción.
		cap_r <= '0';
		edo_re <= 1;
	
	end if;
end if;
end process;

-- Se manda el byte recibido por el puerto DATA_OUT.
process(CLK)
begin
if rising_edge(CLK) then
   fin_r <= '0';
   if cap_r = '1' then
      fin_r <= '1';
      data_rdy_e <= data_in_e;
	end if;
end if;
end process;

-- Maquina de estados para la transmisión --
process(cs_in, CLK)
begin
if cs_in = '1' then
   miso_out <= 'Z';
	it <= 7;
	oke_pha <= '0';
	edo_t <= 0;
elsif rising_edge(CLK) then
	miso_out <= data_out_e(it);

	if edo_t = 0 then
		if ini_t = '1' then
			data_out_e <= DATA_IN;
			oke_pha <= '0';
			edo_t <= 1;
		end if;
		
	elsif edo_t = 1 then
		--
		if CPOL = '0' then 						-- Polaridad 0
			if CPHA = '0' then 					-- Fase 0
				if oke_fb = '1' then
					it <= it-1;
					if it = 0 then
						it <= 7;
						edo_t <= 3;
					end if;
				end if;
			else 										-- Fase 1
				if oke_fs = '1' then
					oke_pha <= '1';
					if oke_pha = '1' then
						it <= it-1;
						if it = 1 then
							it <= 0;
							edo_t <= 2;
						end if;
					end if;
				end if;
			end if;
		else 											-- Polaridad 1
			if CPHA = '0' then 					-- Fase 0
				if oke_fs = '1' then
					it <= it-1;
					if it = 0 then
						it <= 7;
						edo_t <= 3;
					end if;
				end if;
			else										-- Fase 1
				if oke_fb = '1' then
					oke_pha <= '1';
					if oke_pha = '1' then
						it <= it-1;
						if it = 1 then
							it <= 0;
							edo_t <= 2;
						end if;
					end if;
				end if;
			end if;
		end if;
	
	elsif edo_t = 2 then
		if CPOL = '1' then
			if oke_fs = '1' then
				it <= 7;
				edo_t <= 3;
			end if;
		else
			if oke_fb = '1' then
				it <= 7;
				edo_t <= 3;
			end if;
		end if;
		
	elsif edo_t = 3 then
--		edo_t <= 0;
		if fin_r = '1' then
			edo_t <= 0;
		end if;
	end if;
end if;
end process;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
------------- PROCESO DE RECEPCIÓN Y TRANSMISIÓN EN MODO MAESTRO ---------------
--------------------------------------------------------------------------------
-- Máquina de estados que genera el reloj de SPI --
process(cs_out, CLK)
begin
if cs_out = '1' then
	edo_clk <= 0;
	offset_clk <= 0;
	if CPOL = '1' then
		clk_spi_out <= '1';
	else
		clk_spi_out <= '0';
	end if;
elsif rising_edge(CLK) then
	if edo_clk = 0 then
		if CPOL = '1' then
			clk_spi_out <= '1';
		else
			clk_spi_out <= '0';
		end if;
		edo_clk <= 1;
		
	elsif edo_clk = 1 then
		if ok_clk = '1' then
			edo_clk <= 2;
			clk_spi_out <= not clk_spi_out;
		end if;
		
	elsif edo_clk = 2 then
		conta_frecuencia <= conta_frecuencia+1;
		if conta_frecuencia = ESCALA_FRECUENCIA then
			conta_frecuencia <= 0;
			clk_spi_out <= not clk_spi_out;
			 conta_reloj <= conta_reloj+1;
			 if conta_reloj = 14+offset_clk then
				conta_reloj <= 0;
				offset_clk <= 1;
				edo_clk <= 3;
			end if;
		end if;
		
	elsif edo_clk = 3 then
		if CPOL = '1' then
			if okm_fs = '1' then
				if ok_clk = '1' then
					edo_clk <= 2;
				else
					edo_clk <= 0;
				end if;
			end if;
		else
			if okm_fb = '1' then
				if ok_clk = '1' then
					edo_clk <= 2;
				else
					edo_clk <= 0;
				end if;
			end if;
		end if;
	
	end if;
end if;
end process;
	
	
mosi_out <= data_in_m(itm);	

process(CLK)
begin
if rising_edge(CLK) then
	if edo_m = 0 then
		if INI_T = '1' then
			edo_m <= 1;
			okm_pha <= '0';
			data_in_m <= DATA_IN;
		end if;
		cs_out <= '1';
		fin_t <= '0';
		ok_clk <= '0';
		
	elsif edo_m = 1 then
		conta_ciclos <= conta_ciclos+1;
		cs_out <= '0';
		if conta_ciclos = CICLOS_CLK-1 then
			conta_ciclos <= 0;
			ok_clk <= '1';
			edo_m <= 2;
		end if;
			
	elsif edo_m = 2 then
		if CPOL = '0' then
			if CPHA = '0' then
				if okm_fb = '1' then
					itm <= itm-1;
					if itm = 0 then
						itm <= 7;
						edo_m <= 3;
						ok_clk <= '0';
						fin_t <= '1';
					end if;
				end if;
			else
				if okm_fs = '1' then
					okm_pha <= '1';
					if okm_pha = '1' then
						itm <= itm-1;
						if itm = 1 then
							itm <= 0;
							edo_m <= 5;
							ok_clk <= '0';
						end if;
					end if;
				end if;
			end if;
		else
			if CPHA = '0' then
				if okm_fs = '1' then
					itm <= itm-1;
					if itm = 0 then
						itm <= 7;
						edo_m <= 3;
						ok_clk <= '0';
						fin_t <= '1';
					end if;
				end if;
			else
				if okm_fb = '1' then
					okm_pha <= '1';
					if okm_pha = '1' then
						itm <= itm-1;
						if itm = 1 then
							itm <= 0;
							edo_m <= 5;
--							fin_t <= '1';
							ok_clk <= '0';
						end if;
					end if;
				end if;
			end if;
		end if;
	
	elsif edo_m = 3 then
		edo_m <= 8;
		fin_t <= '0';
	
	elsif edo_m = 8 then
		edo_m <= 7;
	
	elsif edo_m = 7 then
		if INI_T = '1' then
			edo_m <= 6;
			ok_clk <= '1';
			fin_t <= '0';
			okm_pha <= '0';
		else
			edo_m <= 4;
		end if;
	
	elsif edo_m = 6 then
		edo_m <= 2;
		data_in_m <= DATA_IN;
	
	elsif edo_m = 4 then
		conta_ciclos <= conta_ciclos+1;
		if conta_ciclos = CICLOS_CLK-1 then
			conta_ciclos <= 0;
			cs_out <= '1';
			edo_m <= 0;
		end if;
		
	elsif edo_m = 5 then
		if CPOL = '1' then
			if okm_fs = '1' then
				itm <= 7;
				edo_m <= 3;
				fin_t <= '1';
			end if;
		else
			if okm_fb = '1' then
				itm <= 7;
				edo_m <= 3;
				fin_t <= '1';
			end if;
		end if;
		
		if INI_T = '1' then
			ok_clk <= '1';
		end if;
	
	end if;
end if;
end process;


process(cs_out, CLK)
begin
if cs_out = '1' then
   cap_rm <= '0';
	irm <= 7;
elsif rising_edge(CLK) then
	cap_rm <= '0';
	if CPOL = '0' then 						-- Polaridad 0
		if CPHA = '0' then 					-- Fase 0
			if okm_fs = '1' then
				data_out_m(irm) <= miso_in;
				irm <= irm-1;
				if irm = 0 then
					irm <= 7;
					cap_rm <= '1';
				end if;
			end if;
		else 										-- Fase 1
			if okm_fb = '1' then
				data_out_m(irm) <= miso_in;
				irm <= irm-1;
				if irm = 0 then
					irm <= 7;
					cap_rm <= '1';
				end if;
			end if;
		end if;
	else 											-- Polaridad 1
		 if CPHA = '0' then					-- Fase 0
			if okm_fb = '1' then
				data_out_m(irm) <= miso_in;
				irm <= irm-1;
				if irm = 0 then
					irm <= 7;
					cap_rm <= '1';
				end if;
			end if;
		else										-- Fase 1
			if okm_fs = '1' then
				data_out_m(irm) <= miso_in;
				irm <= irm-1;
				if irm = 0 then
					irm <= 7;
					cap_rm <= '1';
				end if;
			end if;
		end if;
	end if;
end if;
end process;

process(CLK)
begin
if rising_edge(CLK) then
   if cap_rm = '1' then
      data_rdy_m <= data_out_m;
	end if;
end if;
end process;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------





end Behavioral;

