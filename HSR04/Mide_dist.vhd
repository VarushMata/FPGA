----------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mide_dist is
port( CLK     : IN  STD_LOGIC;
      ECO     : IN  STD_LOGIC;
      TRIGGER : OUT STD_LOGIC;
      SEG     : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      AN      : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)

    );
end Mide_dist;

architecture Behavioral of Mide_dist is
component INTESC_LIB_ULTRASONICO_RevC is
generic( FPGA_CLK : INTEGER := 50_000_000 );
PORT( CLK          : IN  STD_LOGIC;
      ECO          : IN  STD_LOGIC;
      TRIGGER      : OUT STD_LOGIC;
      DATO_LISTO   : OUT STD_LOGIC;
      DISTANCIA_CM : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
     );
end component INTESC_LIB_ULTRASONICO_RevC;

signal UNIint,DECint,CENint,MILint: std_logic_vector (3 downto 0); --U-D-C-M
signal SAL_400Hz: std_logic;

signal dato_listo   : std_logic := '0';
signal distancia_cm : std_logic_vector(8 downto 0) := (others => '0');
signal distanciona : std_logic_vector(8 downto 0) := (others => '0');


begin
u1: INTESC_LIB_ULTRASONICO_RevC 
generic map( FPGA_CLK => 50_000_000 ) -- Reloj de FPGA opera a 50MHz
PORT map( CLK          => CLK, 
          ECO          => ECO, 
          TRIGGER      => TRIGGER, 
          DATO_LISTO   => dato_listo, 
          DISTANCIA_CM => distancia_cm 
         );
u2: entity work.SHIFT_ADD port map(
	CONT => distanciona or "00000000000000", --a seal p/LD y srmd (U1)
	UNI => UNIint,  -- Seales a los displays
	DEC => DECint,
	CEN => CENint,
	MIL => MILint
);

u3: entity work.DISPLAY_result port map(
	UNI => UNIint,  -- Seales a los displays
	DEC => DECint,
	CEN => CENint,
	MIL => MILint,
	SAL_400Hz => SAL_400Hz, --A seal de reloj U4
	DISPLAY => SEG, --A segmentos de display
	AN => AN --A nodos del display
);

u4: entity work.DIV_CLK port map(
	clk => clk,
	SAL_400Hz => SAL_400Hz
);
			
process(clk) begin
	distanciona <= distancia_cm;
end process;


end Behavioral;

