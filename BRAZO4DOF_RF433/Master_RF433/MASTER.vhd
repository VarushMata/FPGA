----------------------------------------------------------------------------------
-- MEXILOGICS
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MASTER is
port(
	CLK: in STD_LOGIC;
	SWITCHES: in STD_LOGIC_VECTOR (7 downto 0);
	TX: out STD_LOGIC
);
end MASTER;

architecture Behavioral of MASTER is

signal tx_in_s,rx_in_s: std_logic;
signal tx_fin_s,rx: std_logic;
signal datain_s,dout_s: std_logic_vector (7 downto 0);


-- SYMBOLIC ENCODED state machine: STATE
type STATE_type is (
    ASIGNA, ENVIA
);
-- attribute enum_encoding of STATE_type: type is ... -- enum_encoding attribute is not supported for symbolic encoding

signal STATE, NextState_STATE: STATE_type;

-- Declarations of pre-registered internal signals
component RS232 is
generic( FPGA_CLK   : integer := 50000000;
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

----------------------------------------------------------------------
-- Machine: STATE
----------------------------------------------------------------------
------------------------------------
-- Next State Logic (combinatorial)
------------------------------------
STATE_NextState: process (STATE)
begin
	NextState_STATE <= STATE;
	-- Set default values for outputs and signals
	-- ...
	case STATE is
		when ASIGNA =>
			DATAIN_s <= SWITCHES;
			NextState_STATE <= ENVIA;
		when ENVIA =>
			if TX_FIN_s = '0' then	
				NextState_STATE <= ENVIA;
				TX_IN_s <= '1';
			elsif TX_FIN_s = '1' then	
				NextState_STATE <= ASIGNA;
				TX_IN_s <= '0';
			end if;
--vhdl_cover_off
		when others =>
			null;
--vhdl_cover_on
	end case;
end process;

------------------------------------
-- Current State Logic (sequential)
------------------------------------
STATE_CurrentState: process (clk)
begin
	if clk'event and clk = '1' then
		STATE <= NextState_STATE;
	end if;
end process;


end Behavioral;

