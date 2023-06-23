----------------------------------------------------------------------------------
--MEXILOGICS
--Convertidor SHIFt and add 3
--------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

--------------------------------------------------------
--Declaracin de la entidad

entity SHIFT_ADD is
port(
	CONT: in std_logic_vector (13 downto 0):=(others=>'0'); --8 bits
	UNI,DEC,CEN,MIL: out std_logic_vector (3 downto 0)
);
end SHIFT_ADD;

--------------------------------------------------------
--Declaracin de la arquitectura
architecture Behavioral of SHIFT_ADD is
--DECLARACIN DE SEALES DE ASIGNACIN DE U-D-C
signal P:std_logic_vector(15 downto 0); --Asigna UNI,DEC,CEN

-----------CONVERTIR DE BIN A BCD------------------
-- Este proceso contiene un algoritmo recorre y suma 3 para
-- convertir un nmero binario abcd, que se manda a los displays.
-- El algoritmo consiste en desplazar (shift) el vector inicial
-- (en binario) el nmero de veces segn sea el nmero de bits,
-- y cuando alguno de los bloques de 4 bits (U-D-C-UM, que es el
-- nmero de bits necesarios para que cuente de 0 a 9 por cifra)
-- sea igual o mayor a 5 (por eso el >4) se le debe sumar 3
-- a ese bloque, despus se continua desplazando hasta que otro
-- (o el mismo) bloque cumpla con esa condicin y se le sumen 3.

-- Inicialmente se rota 3 veces porque es el nmero mnimo de bits
-- que debe tener para que sea igual o mayor a 5.
-- Finalmente se asigna a otro vector, el vector ya convertido,
-- que cuenta con 3 bloques para las 3 cifras de 4 bits cada una.
begin
PROCESS(CONT)
VARIABLE UM_C_D_U:STD_LOGIC_VECTOR(29 DOWNTO 0);
--30 bits para separar las U.Millar-Centenas-Decenas-Unidades
BEGIN

--ciclo de inicialización
FOR I IN 0 TO 29 LOOP --
UM_C_D_U(I):='0'; -- se inicializa con 0
END LOOP;
UM_C_D_U(13 DOWNTO 0):=CONT(13 downto 0); --contador de 14 bits
-- UM_C_D_U(17 DOWNTO 4):=CONT(13 downto 0); --contador de 14 bits, carga desde

-- el shift4

--ciclo de asignación UM-C-D-U
FOR I IN 0 TO 13 LOOP
-- FOR I IN 0 TO 9 LOOP -- si carga desde shift4 solo hace 10 veces el ciclo shift add
-- los siguientes condicionantes comparan (>=5) y suman 3
IF UM_C_D_U(17 DOWNTO 14) > 4 THEN -- U
UM_C_D_U(17 DOWNTO 14):= UM_C_D_U(17 DOWNTO 14)+3;
END IF;
IF UM_C_D_U(21 DOWNTO 18) > 4 THEN -- D
UM_C_D_U(21 DOWNTO 18):= UM_C_D_U(21 DOWNTO 18)+3;
END IF;
IF UM_C_D_U(25 DOWNTO 22) > 4 THEN -- C
UM_C_D_U(25 DOWNTO 22):= UM_C_D_U(25 DOWNTO 22)+3;
END IF;
IF UM_C_D_U(29 DOWNTO 26) > 4 THEN -- UM
UM_C_D_U(29 DOWNTO 26):= UM_C_D_U(29 DOWNTO 26)+3;
END IF;
-- realiza el corrimiento
UM_C_D_U(29 DOWNTO 1):= UM_C_D_U(28 DOWNTO 0);
END LOOP;
P<=UM_C_D_U(29 DOWNTO 14); -- guarda en P y en seguida se separan UM-C-D-U

END PROCESS;
--UNIDADES
UNI<=P(3 DOWNTO 0);
--DECENAS
DEC<=P(7 DOWNTO 4);
--CENTENAS
CEN<=P(11 DOWNTO 8);
--MILLARES
MIL<=P(15 DOWNTO 12);

end Behavioral;