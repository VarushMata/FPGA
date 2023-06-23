----------------------------------------------------------------------------------
--MEXILOGICS: RECIPIENTE CONTADOR CON SALIDA A DISPLAY LCD 16X2
--UTILIZANDO SENSORES INFRARROJOS PARA REALIZAR EL CONTEO
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Celda_carga is
port (
	  CLK: IN STD_LOGIC; -- Seal de reloj
	  sens1,reset,inicia,sens2 : in std_logic; --Señales de enraada                  
	  LCD_E,LCD_RW,LCD_RS : out std_logic;         -- Seal de LCD
	  DATA: out std_logic_vector (7 downto 0)    --Dato para la LCD
    );
end Celda_carga;

architecture Behavioral of Celda_carga is


signal UNIint,DECint,CENint,MILint: std_logic_vector (3 downto 0); --U-D-C-M
signal contador: integer := 0;
signal conta_dulce : std_logic_vector (13 downto 0);
signal conta_12us : integer range 1 to 1_250_000 := 1; --pulso de 1.2MHz
signal SAL_Hz: std_logic;

begin

process(clk) begin
if rising_edge(clk) then
	if(conta_12us = 1_250_000) then --cuenta 1250us (50MHz = 62500)
		SAL_Hz <= not(SAL_Hz); --Genera un barrido de 2.5ms
		conta_5000us <= 1;
	else conta_5000us <= conta_5000us + 1;
	end if;
end if;
end process; --Fin del proceso divisor de nodos
-- Proceso p
Contador_objetos: process(SAL_HZ,reset,inicia)
begin
	if reset = '1' or inicia = '1' then 
		--Reestablecer las seales
		contador <= 0;
	elsif rising_edge(SAL_HZ) then
		if sens1 = '0' or sens2 = '0' then
			--Contador para la LCD 
			contador <= contador + 1;
		else
			contador <= contador;
		end if;
	end if;
conta_dulce <= conv_std_logic_vector(contador,14);
end process;

--Librería LCD
U1: entity work.LIB_LCD_INTESC_REVD port map(
	clk => clk,
	inicia => inicia,
	RS => LCD_RS,
	ENA => LCD_E,
	RW => LCD_RW,
	DATA_LCD => DATA,
	UNI => UNIINT,
	DEC => DECINT,
	CEN => CENINT
);

--Separador a Unidades decenas y centenas
u2: entity work.SHIFT_ADD port map(
	CONT => conta_dulce, --contador para aparecer en LCD
	UNI => UNIint,  -- Seales a los displays
	DEC => DECint,
	CEN => CENint,
	MIL => MILint
);

end Behavioral;

