----------------------------------------------------------------------------------
--MEXILOGICS: CDIGO PARA LEER UN RECEPTOR DE UN MDULO DE 433 MHZ, LO QUE PERMITE EL CONTROL DE 
--UN BRAZO ROBTICO DE 4 GRADOS DE LIBERTAD EMPLEANDO SERVOMOTORES
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity SLAVE_R is
port(
	CLK: in STD_LOGIC; --RELOJ
	LEDS: out STD_LOGIC_VECTOR (7 downto 0); --MUESTRA DE LECTURA
	DOF1,DOF2,DOF3,DOF4: out std_logic; --CONTROL DE SERVOMOTORES
	RX: in STD_LOGIC; --INGRESO DE DATOS DEL RECEPTOR
	ANode,dsply: out std_logic_vector (7 downto 0) --CONEXIN A DISPLAY DE 7 SEG
);

end SLAVE_R;

architecture Behavioral of SLAVE_R is

signal tx_in_s,rx_in_s: std_logic; --CONTROL DE DATOS DEL EMISOR
signal tx_fin_s,tx: std_logic;
signal datain_s,dout_s: std_logic_vector (7 downto 0); 
signal asigna_led: std_logic_vector (7 downto 0);
signal clk_out,clk_lento: std_logic;
signal counter: integer range 0 to 277 := 0;
signal counter2: integer range 0 to 600_000;
signal pos1,pos2,pos3,pos4: std_logic_vector (6 downto 0) := "0000000";
signal sal_400Hz: std_logic;



-- SYMBOLIC ENCODED state machine: Sreg0
type Sreg0_type is (
    RECIBE, MUESTRA
);
-- attribute enum_encoding of Sreg0_type: type is ... -- enum_encoding attribute is not supported for symbolic encoding

signal Sreg0, NextState_Sreg0: Sreg0_type;


-- Declarations of pre-registered internal signals
--COMUNICACIN RS232 PARA EL TRANSMISOR Y RECEPTOR
component RS232 is
generic    ( FPGA_CLK   : integer := 50000000;
          BAUD_RS232 : integer := 9600
        );
port( CLK    : in  std_logic;
      RX     : in  std_logic;
      TX_INI : in  std_logic;
      DATAIN : in  std_logic_vector(7 downto 0);
      TX_FIN : out std_logic;
      TX     : out std_logic;
      RX_IN  : out std_logic;
      DOUT   : out std_logic_vector(7 downto 0)
);
end component RS232;

begin

--DECLARACIN DEL COMPONENTE DE COMUNICACIN RS232 CON LOS DATOS ADECUADOS
--PARA EL MDULO SELECCIONADO
u1 : rs232 generic map(
     FPGA_CLK   => 433_000_000,
     BAUD_RS232 => 2400
     )
port map( CLK    => CLK,
          RX     => RX,
          TX_INI => tx_in_s,
          TX_FIN => tx_fin_s,
          TX     => TX,
          RX_IN  => rx_in_s,
          DATAIN => datain_s,
          DOUT   => dout_s
);

--LOS SIGUIENTES COMPONENTES CONTROLAN LA POSICIN INDIVIDUALMENTE DE CADA
--SERVOMOTOR
u2: entity work.Servo_pos port map(
	clk => clk_out,
	posi => pos1,
	servo => dof1
);

u3: entity work.Servo_pos port map(
	clk => clk_out,
	posi => pos2,
	servo => dof2
);

u4: entity work.Servo_pos port map(
	clk => clk_out,
	posi => pos3,
	servo => dof3
);

u5: entity work.Servo_pos port map(
	clk => clk_out,
	posi => pos4,
	servo => dof4
);

u6: entity work.DIV_CLK port map(
	clk => clk,
	SAL_400Hz => SAL_400Hz
);


--SE MUESTRA EN EL DISPLAY LA ACCIN REALIZADA
u7: entity work.Display_result port map(
	SELEC => asigna_led,
	SAL_400Hz => SAL_400Hz, --A seal de reloj U4
	DISPLAY => dsply, --A segmentos de display
	AN => ANode --A nodos del display
);

--MQUINA DE ESTADOS QUE CONTROLA LA COMUNICACIN RS232
----------------------------------------------------------------------
-- Machine: Sreg0
----------------------------------------------------------------------
------------------------------------
-- Next State Logic (combinatorial)
------------------------------------
Sreg0_NextState: process (Sreg0)
begin
	NextState_Sreg0 <= Sreg0;
	-- Set default values for outputs and signals
	-- ...
	case Sreg0 is
		when RECIBE =>
			if RX_IN_S = '1' then	
				NextState_Sreg0 <= MUESTRA;
			elsif RX_IN_S = '0' then	
				NextState_Sreg0 <= RECIBE;
			end if;
		when MUESTRA =>
			asigna_led <= DOUT_S;
			NextState_Sreg0 <= RECIBE;
--vhdl_cover_off
		when others =>
			null;
		--vhdl_cover_on
	end case;
end process;


------------------------------------
-- Current State Logic (sequential)
------------------------------------
Sreg0_CurrentState: process (clk)
begin
	if clk'event and clk = '1' then
		Sreg0 <= NextState_Sreg0;
	end if;
end process;

--DIVISOR DE FRECUENCIA PARA EL SERVOMOTOR
freq_divider: process(clk) begin
	if rising_edge(clk) then
		if counter = 277 then
			clk_out <= not clk_out;
			counter <= 0;
		else
			counter <= counter + 1;
		end if;
	end if;
end process;

--DIVISOR DE FRECUENCIA PARA EL MOVIMIENTO DEL BRAZO
divider: process(clk) begin
	if rising_edge(clk) then
		if counter2 = 600_000 then
			clk_lento <= not clk_lento;
			counter2 <= 0;
		else
			counter2 <= counter2 + 1;
		end if;
	end if;
end process;

--CONTROLADOR DE LA POSICIN DE LOS SERVOMOTORES DELIMITANDO SUS MXIMOS Y MNIMOC
process(clk_lento, asigna_led,pos1,pos2) begin
	if clk_lento'event and clk_lento = '1' then --Actualizacin de la posicin
		if pos1 = x"7E" then --Si llega a su mximo no se puede mover
			if asigna_led(0) = '1' then
				pos1 <= pos1;
			elsif asigna_led(1) = '1' then
				pos1 <= pos1 - '1'; 
			end if;
		elsif pos1 = x"01" then --Si llega a su mnimo no se puede mover
			if asigna_led(0) = '1' then
				pos1 <= pos1 + '1';
			elsif asigna_led(1) = '1' then
				pos1 <= pos1;
			end if;
		else
			if asigna_led(0) = '1' then --Al presionar el botn se incrementa la posicin
				pos1 <= pos1 + '1';
			elsif asigna_led(1) = '1' then --Se decrementa al presionar el otro botn
				pos1 <= pos1 - '1';
			end if;
		end if;
		
		if pos2 = x"7E" then 
			if asigna_led(2) = '1' then
				pos2 <= pos2;
			elsif asigna_led(3) = '1' then
				pos2 <= pos2 - '1';
			end if;
		elsif pos2 = x"01" then
			if asigna_led(2) = '1' then
				pos2 <= pos2 + '1';
			elsif asigna_led(3) = '1' then
				pos2 <= pos2;
			end if;
		else
			if asigna_led(2) = '1' then
				pos2 <= pos2 + '1';
			elsif asigna_led(3) = '1' then
				pos2 <= pos2 - '1';
			end if;
		end if;
		
		if pos3 = x"7E" then 
			if asigna_led(4) = '1' then
				pos3 <= pos3;
			elsif asigna_led(5) = '1' then
				pos3 <= pos3 - '1';
			end if;
		elsif pos3 = x"01" then
			if asigna_led(4) = '1' then
				pos3 <= pos3 + '1';
			elsif asigna_led(5) = '1' then
				pos3 <= pos3;
			end if;
		else
			if asigna_led(4) = '1' then
				pos3 <= pos3 + '1';
			elsif asigna_led(5) = '1' then
				pos3 <= pos3 - '1';
			end if;
		end if;
		
		if pos4 = x"7E" then  
			if asigna_led(6) = '1' then
				pos4 <= pos4;
			elsif asigna_led(7) = '1' then
				pos4 <= pos4 - '1';
			end if;
		elsif pos4 = x"01" then
			if asigna_led(6) = '1' then
				pos4 <= pos4 + '1';
			elsif asigna_led(7) = '1' then
				pos4 <= pos4;
			end if;
		else
			if asigna_led(6) = '1' then
				pos4 <= pos4 + '1';
			elsif asigna_led(7) = '1' then
				pos4 <= pos4 - '1';
			end if;
		end if;
		
	end if;
end process;
 
leds <= asigna_led; --ASIGNACIN DE LOS DATOS TRANSMITIDOS A UNOS LEDS PARA VERIFICAR
--EL FUNCIONAMIENTO

end Behavioral;

