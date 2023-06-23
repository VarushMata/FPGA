----------------------------------------------------------------------------------
-- MEXILOGICS: CONTROL DE SERVOMOTOR SG90 EL CUAL CUENTA CON 90 GRADOS DE MOVIMIENTO
-- SE COMPARA EN UN TIEMPO DE 20MS PARA DAR LA SEÑAL
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Servo_pos is
port (
	clk: in std_logic;
	posi: in std_logic_vector (6 downto 0); --POSICIÓN MÁXIMA DE 180
	servo: out std_logic
	);
end Servo_pos;

architecture Behavioral of Servo_pos is

signal cnt: unsigned(11 downto 0);
signal pos_comp: std_logic_vector(6 downto 0);
signal pwmi: unsigned(7 downto 0);

begin

pos_comp <= "1011010" when unsigned(posi) > "1011010" else posi; --SI EXCEDE LOS 90 GRADOS SE QUEDA EN ESE VALOR
pwmi <= unsigned('0' & pos_comp) + 90; --SI NO EXCEDE 90 GRADOS ENTONCES MODIFICA LA POSICIÓN

counter: process(clk) begin --CONTROL DEL PWM PARA DAR LOS VALORES QUE SE COMPARAN EN 2O MS
	if rising_edge(clk) then
		if cnt = 1799 then --CONTADOR PARA LOS 90 GRADOS
			cnt <= (others => '0');
		else
			cnt <= cnt + 1;
		end if;
	end if;
end process;

servo <= '1' when (cnt < pwmi) else '0'; --ASIGNACIÓN DEL PWM A LA SALIDA

end Behavioral;

