-------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : SFM
-- Author      : d4c0902varu@outlook.com
-- Company     : ipn
--
-------------------------------------------------------------------------------
--
-- File        : c:\My_Designs\CILO\CILO\SFM\compile\Tapping.vhd
-- Generated   : 06/06/23 18:56:44
-- From        : c:\My_Designs\CILO\CILO\SFM\src\Tapping.asf
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

entity Tapping is 
	port (
		CLK_ext: in STD_LOGIC;
		SENS1: in STD_LOGIC;
		SENS2: in STD_LOGIC;
		TAPRELE,TAP: out STD_LOGIC);
end Tapping;

architecture Tapping_arch of Tapping is

-- diagram signals declarations
signal delay_counter_STATE: INTEGER range 0 to 2;

-- USER DEFINED ENCODED state machine: STATE
attribute enum_encoding: string;
type STATE_type is (
    IDLE, TAP1, Wait1, TAP2, Wait2, TAP3, Wait3, T_DS1
);
attribute enum_encoding of STATE_type: type is
	"0000 " &		-- IDLE
	"0001 " &		-- TAP1
	"0010 " &		-- Wait1
	"0011 " &		-- TAP2
	"0100 " &		-- Wait2
	"0101 " &		-- TAP3
	"0111 " &		-- Wait3
	"1000" ; 		-- T_DS1

signal STATE, NextState_STATE: STATE_type;

-- Declarations of pre-registered internal signals
signal int_TAP, next_TAP: STD_LOGIC;
signal next_delay_counter_STATE: INTEGER range 0 to 2;

begin

-- concurrent signals assignments

-- Diagram ACTION

----------------------------------------------------------------------
-- Machine: STATE
----------------------------------------------------------------------
------------------------------------
-- Next State Logic (combinatorial)
------------------------------------
STATE_NextState: process (delay_counter_STATE, SENS1, SENS2, int_TAP, STATE)
begin
	NextState_STATE <= STATE;
	-- Set default values for outputs and signals
	next_TAP <= int_TAP;
	next_delay_counter_STATE <= delay_counter_STATE;
	case STATE is
		when IDLE =>
			next_TAP <= '0';
			if SENS1 = '0' and SENS2 = '0' then	
				NextState_STATE <= TAP1;
			elsif SENS1 = '1' or SENS2 = '1' then	
				NextState_STATE <= IDLE;
			end if;
		when TAP1 =>
			next_TAP <= '1';
			NextState_STATE <= Wait1;
		when Wait1 =>
			next_TAP <= '0';
			NextState_STATE <= TAP2;
		when TAP2 =>
			next_TAP <= '1';
			NextState_STATE <= Wait2;
		when Wait2 =>
			next_TAP <= '0';
			NextState_STATE <= TAP3;
		when TAP3 =>
			next_TAP <= '1';
			NextState_STATE <= Wait3;
		when Wait3 =>
			next_TAP <= '0';
			NextState_STATE <= T_DS1;
			next_delay_counter_STATE <= 2 - 1;
		when T_DS1 =>
			if delay_counter_STATE = 0 then	
				NextState_STATE <= IDLE;
			else
				NextState_STATE <= T_DS1;
				if delay_counter_STATE /= 0 then next_delay_counter_STATE <= delay_counter_STATE - 1;
				end if;
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
		delay_counter_STATE <= next_delay_counter_STATE;
		int_TAP <= next_TAP;
	end if;
end process;

-- Copy temporary signals to target output ports
TAP <= int_TAP;
TAPRELE <= int_TAp;

end Tapping_arch;