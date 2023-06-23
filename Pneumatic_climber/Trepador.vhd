-------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : SFM
-- Author      : d4c0902varu@outlook.com
-- Company     : ipn
--
-------------------------------------------------------------------------------
--
-- File        : c:\My_Designs\CILO\CILO\SFM\compile\Trepador.vhd
-- Generated   : 06/04/23 20:17:03
-- From        : c:\My_Designs\CILO\CILO\SFM\src\Trepador.asf
-- By          : FSM2VHDL ver. 5.0.5.4
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Trepador is 
	port (
		CLK50,soundon: in STD_LOGIC;
		CLK_ext: in STD_LOGIC;
		DIR: in STD_LOGIC;
		HOLD: in STD_LOGIC;
		DISPLAY,AN: out STD_LOGIC_VECTOR (7 downto 0);
		LEDS,SAL: out STD_LOGIC_VECTOR (2 downto 0);
		SOUT: out STD_LOGIC);
end Trepador;

architecture Trepador_arch of Trepador is

-- diagram signals declarations
signal EST_DISP: STD_LOGIC_VECTOR (1 downto 0);
signal SAL_400HZ: STD_LOGIC;

-- USER DEFINED ENCODED state machine: STATE
attribute enum_encoding: string;
type STATE_type is (
    A, B, C, D, E, F
);
attribute enum_encoding of STATE_type: type is
	"000 " &		-- A
	"001 " &		-- B
	"010 " &		-- C
	"011 " &		-- D
	"100 " &		-- E
	"101" ; 		-- F

signal STATE, NextState_STATE: STATE_type;

-- Declarations of pre-registered internal signals
signal int_SAL, next_SAL: STD_LOGIC_VECTOR (2 downto 0);
signal int_SOUT, next_SOUT: STD_LOGIC;
signal next_EST_DISP: STD_LOGIC_VECTOR (1 downto 0);

begin

-- concurrent signals assignments

-- Diagram ACTION

----------------------------------------------------------------------
-- Machine: STATE
----------------------------------------------------------------------
------------------------------------
-- Next State Logic (combinatorial)
------------------------------------
STATE_NextState: process (DIR, HOLD, int_SAL, int_SOUT, EST_DISP, STATE,soundon)
begin
	NextState_STATE <= STATE;
	-- Set default values for outputs and signals
	next_SAL <= int_SAL;
	next_SOUT <= int_SOUT;
	next_EST_DISP <= EST_DISP;
	case STATE is
		when A =>
			next_SAL <= "100";
			if soundon = '1' then
				next_sout <= '1';
			else 
				next_sout <= '0';
			end if;
			next_EST_DISP <= "00";
			if DIR = '1' then	
				NextState_STATE <= F;
			elsif HOLD ='1' and (DIR = '0' or DIR = '1') then	
				NextState_STATE <= A;
			elsif DIR = '0' then	
				NextState_STATE <= B;
			end if;
		when B =>
			next_SAL <= "110";
			next_SOUT <= '0';
			next_EST_DISP <= "01";
			if DIR = '1' then	
				NextState_STATE <= A;
			elsif HOLD ='1' and (DIR = '0' or DIR = '1') then	
				NextState_STATE <= B;
			elsif DIR = '0' then	
				NextState_STATE <= C;
			end if;
		when C =>
			next_SAL <= "111";
			next_SOUT <= '0';
			next_EST_DISP <= "10";
			if DIR = '1' then	
				NextState_STATE <= B;
			elsif HOLD ='1' and (DIR = '0' or DIR = '1') then	
				NextState_STATE <= C;
			elsif DIR = '0' then	
				NextState_STATE <= D;
			end if;
		when D =>
			next_SAL <= "011";
			next_SOUT <= '0';
			next_EST_DISP <= "00";
			if DIR = '1' then	
				NextState_STATE <= C;
			elsif HOLD ='1' and (DIR = '0' or DIR = '1') then	
				NextState_STATE <= D;
			elsif DIR = '0' then	
				NextState_STATE <= E;
			end if;
		when E =>
			next_SAL <= "001";
			next_SOUT <= '0';
			next_EST_DISP <= "01";
			if DIR = '1' then	
				NextState_STATE <= D;
			elsif HOLD ='1' and (DIR = '0' or DIR = '1') then	
				NextState_STATE <= E;
			elsif DIR = '0' then	
				NextState_STATE <= F;
			end if;
		when F =>
			next_SAL <= "101";
			next_SOUT <= '0';
			next_EST_DISP <= "10";
			if DIR = '1' then	
				NextState_STATE <= E;
			elsif HOLD ='1' and (DIR = '0' or DIR = '1') then	
				NextState_STATE <= F;
			elsif DIR = '0' then	
				NextState_STATE <= A;
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
STATE_CurrentState: process (CLK_ext)
begin
	if CLK_ext'event and CLK_ext = '1' then
		STATE <= NextState_STATE;
	end if;
end process;

------------------------------------
-- Registered Outputs Logic
------------------------------------
STATE_RegOutput: process (CLK_ext)
begin
	if CLK_ext'event and CLK_ext = '1' then
		EST_DISP <= next_EST_DISP;
		int_SAL <= next_SAL;
		int_SOUT <= next_SOUT;
	end if;
end process;

U1: entity work.DISPLAY_result port map(
	SELEC => EST_DISP,
	SAL_400Hz => SAL_400Hz, --A seal de reloj U4
	DISPLAY => DISPLAY, --A segmentos de display
	AN => AN --A nodos del display
);

U2: entity work.DIV_CLK port map( --Divisor de reloj para los displays
	clk => clk50,
	SAL_400Hz => SAL_400Hz
);

-- Copy temporary signals to target output ports
SAL <= int_SAL;
SOUT <= int_SOUT;
LEDS <= int_SAL;


end Trepador_arch;