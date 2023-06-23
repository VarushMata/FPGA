----------------------------------------------------------------------------------
-- COPYRIGHT 2019 Jess Eduardo Mndez Rosales
--
----------------------------------------------------------------------------------
-- MEXILOGICS: CONTROL DE LA LCD 16X2
--PARA MOSTRAR LOS ELEMENTOS MOSTRADOS

----------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.COMANDOS_LCD_REVD.ALL;

entity LIB_LCD_INTESC_REVD is

GENERIC(
			FPGA_CLK : INTEGER := 100_000_000
);


PORT(CLK: IN STD_LOGIC;

-----------------------------------------------------
------------------PUERTOS DE LA LCD------------------
	  RS 		  : OUT STD_LOGIC;							--
	  RW		  : OUT STD_LOGIC;							--
	  ENA 	  : OUT STD_LOGIC;							--
	  DATA_LCD : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);   --
-----------------------------------------------------
-----------------------------------------------------
	  
-----------------------------------------------------------
--------------ABAJO ESCRIBE TUS PUERTOS--------------------	
	 	UNI,DEC,CEN: IN STD_LOGIC_VECTOR (3 downto 0);
		INICIA: IN STD_LOGIC
-----------------------------------------------------------
-----------------------------------------------------------

	  );

end LIB_LCD_INTESC_REVD;

architecture Behavioral of LIB_LCD_INTESC_REVD is


CONSTANT NUM_INSTRUCCIONES : INTEGER := 33; 	--INDICAR EL NMERO DE INSTRUCCIONES PARA LA LCD


--------------------------------------------------------------------------------
-------------------------SEALES DE LA LCD (NO BORRAR)--------------------------
																										--
component PROCESADOR_LCD_REVD is																--
																										--
GENERIC(																								--
			FPGA_CLK : INTEGER := 50_000_000;												--
			NUM_INST : INTEGER := 1																--
);																										--
																										--
PORT( CLK 				 : IN  STD_LOGIC;														--
	   VECTOR_MEM 		 : IN  STD_LOGIC_VECTOR(8  DOWNTO 0);							--
	   C1A,C2A,C3A,C4A : IN  STD_LOGIC_VECTOR(39 DOWNTO 0);							--
	   C5A,C6A,C7A,C8A : IN  STD_LOGIC_VECTOR(39 DOWNTO 0);							--
	   RS 				 : OUT STD_LOGIC;														--
	   RW 				 : OUT STD_LOGIC;														--
	   ENA 				 : OUT STD_LOGIC;														--
	   BD_LCD 			 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);			         	--
	   DATA 				 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);							--
	   DIR_MEM 			 : OUT INTEGER RANGE 0 TO NUM_INSTRUCCIONES					--
	);																									--
																										--
end component PROCESADOR_LCD_REVD;															--
																										--
COMPONENT CARACTERES_ESPECIALES_REVD is													--
																										--
PORT( C1,C2,C3,C4 : OUT STD_LOGIC_VECTOR(39 DOWNTO 0);								--
		C5,C6,C7,C8 : OUT STD_LOGIC_VECTOR(39 DOWNTO 0)									--
	 );																								--
																										--
end COMPONENT CARACTERES_ESPECIALES_REVD;													--
																										--
CONSTANT CHAR1 : INTEGER := 1;																--
CONSTANT CHAR2 : INTEGER := 2;																--
CONSTANT CHAR3 : INTEGER := 3;																--
CONSTANT CHAR4 : INTEGER := 4;																--
CONSTANT CHAR5 : INTEGER := 5;																--
CONSTANT CHAR6 : INTEGER := 6;																--
CONSTANT CHAR7 : INTEGER := 7;																--
CONSTANT CHAR8 : INTEGER := 8;																--
																										--
type ram is array (0 to  NUM_INSTRUCCIONES) of std_logic_vector(8 downto 0); 	--
signal INST : ram := (others => (others => '0'));										--
																										--
signal blcd 			  : std_logic_vector(7 downto 0):= (others => '0');		--																										
signal vector_mem 	  : STD_LOGIC_VECTOR(8  DOWNTO 0) := (others => '0');		--
signal c1s,c2s,c3s,c4s : std_logic_vector(39 downto 0) := (others => '0');		--
signal c5s,c6s,c7s,c8s : std_logic_vector(39 downto 0) := (others => '0'); 	--
signal dir_mem 		  : integer range 0 to NUM_INSTRUCCIONES := 0;				--
signal apaga: std_logic;
																										--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
---------------------------AGREGA TUS SEALES AQU------------------------------
signal uniint,decint,cenint: integer := 0;
signal C9,C10,C11,C12,C5,C13,C14,C15: std_logic_vector (7 downto 0);
signal C16,C17,C18,C19,C20,C21,C22,C23: std_logic_vector (7 downto 0);
signal limpia: std_logic;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


begin

---------------------------------------------------------------
-------------------COMPONENTES PARA LCD------------------------
																				 --
u1: PROCESADOR_LCD_REVD													 --
GENERIC map( FPGA_CLK => FPGA_CLK,									 --
				 NUM_INST => NUM_INSTRUCCIONES )						 --
																				 --
PORT map( CLK,VECTOR_MEM,C1S,C2S,C3S,C4S,C5S,C6S,C7S,C8S,RS, --
			 RW,ENA,BLCD,DATA_LCD, DIR_MEM );						 --
																				 --
U2 : CARACTERES_ESPECIALES_REVD 										 --
PORT MAP( C1S,C2S,C3S,C4S,C5S,C6S,C7S,C8S );				 		 --
																				 --
VECTOR_MEM <= INST(DIR_MEM);											 --
																				 --
---------------------------------------------------------------
---------------------------------------------------------------


-------------------------------------------------------------------
---------------ESCRIBE TU CDIGO PARA LA LCD-----------------------

INST(0) <= LCD_INI("00");
INST(1) <= POS(1,1);
INST(2) <= CHAR(MI);
INST(3) <= CHAR(N);
INST(4) <= CHAR(G);
INST(5) <= CHAR(R);
INST(6) <= CHAR(E);
INST(7) <= CHAR(S);
INST(8) <= CHAR(E);
INST(9) <= CHAR_ASCII(x"20");
INST(10) <= CHAR(O);
INST(11) <= CHAR(B);
INST(12) <= CHAR(J);
INST(13) <= CHAR(E);
INST(14) <= CHAR(T);
INST(15) <= CHAR(O);
INST(16) <= BUCLE_INI(1);
INST(17) <= POS(2,1);
INST(18) <= CHAR_ASCII(C9);
INST(19) <= CHAR_ASCII(C10);
INST(20) <= CHAR_ASCII(C11);
INST(21) <= CHAR_ASCII(C12);
INST(22) <= CHAR_ASCII(C13);
INST(23) <= CHAR_ASCII(C14);
INST(24) <= CHAR_ASCII(C15);
INST(25) <= CHAR_ASCII(C16);
INST(26) <= CHAR_ASCII(C17);
INST(27) <= CHAR_ASCII(C18);
INST(28) <= CHAR_ASCII(C19);
INST(29) <= CHAR_ASCII(C20);
INST(30) <= CHAR_ASCII(C21);
INST(31) <= CHAR_ASCII(C22);
INST(32) <= CHAR_ASCII(C23);
INST(33) <= BUCLE_FIN(1);
-------------------------------------------------------------------
-------------------------------------------------------------------


-------------------------------------------------------------------
--------------------ESCRIBE TU CDIGO DE VHDL----------------------
process(clk) begin
	if clk'event and clk = '1' then
		UNIint <= conv_integer(UNI);
		DECint <= conv_integer(DEC);
		CENint <= conv_integer(CEN);
	end if;
end process;

process(clk) begin
	if clk'event and clk = '1' then
		if UNIint = 0 and DECint = 0 and CENint = 0 then 
			C9 <= x"70";
			C10 <= x"61";
			C11 <= x"72";
			C12 <= x"61";
			C13 <= x"20";
			C14 <= x"63";
			C15 <= x"6F";
			C16 <= x"6E";
			C17 <= x"74";
			C18 <= x"69";
			C19 <= x"6E";
			C20 <= x"75";
			C21 <= x"61";
			C22 <= x"72";
			C23 <= x"2E";
		else
			C9 <= x"44";
			C10 <= x"75";
			C11 <= x"6C";
			C12 <= x"63";
			C13 <= x"65";
			C14 <= x"73";
			C15 <= x"3A";
			C16 <= x"20";
			C17 <= x"20";
			C18 <= x"20";
			C19 <= x"30" + CEN;
			C20 <= x"30" + DEC;
			C21 <= x"30" + UNI;
			C22 <= x"20";	
			C23 <= x"55";
		end if;
	end if;
end process;
-------------------------------------------------------------------
-------------------------------------------------------------------

end Behavioral;

