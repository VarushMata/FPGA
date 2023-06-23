----------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.STD_LOGIC_arith.ALL;

entity Sine_signal is
Generic( max: integer:=22; -- No. bits del divisor
max2 : integer:= 7;
n: integer:=8 -- No. bits de salida
);

Port(
btn0: in std_logic; --use BTN0 as reset input
clk: in std_logic; --Nexys 2 50MHz, Nexys 3 100 MHz clock input
SW : in std_logic; --Selector de velocidad para la señal de rampa
sine: out std_logic_vector (7 downto 0);
ramp: out std_logic_vector (7 downto 0)
);
end Sine_signal;

architecture Behavioral of Sine_signal is

-----------------------------------------------------------------
-- Signals, Type and Constants Declarations

------------------------------------------------------------------
signal cntUS:std_logic_vector (5 downto 0):= (others =>'0'); --Signal to do OneUSClk
signal OneUSClk: std_logic; --Signal is treated as a 1 MHz clock
signal CONT2: std_logic_vector (max2 DOWNTO 0):=(others=>'0'); -- cont rampa
signal clkdiv: std_logic:='0'; -- clkdiv
signal CONT: std_logic_vector (max2 DOWNTO 0):=(others=>'0'); -- cont de max+1 bits


--Declaración de la tabla
type tablaSeno is array(integer range 0 to 359) of std_logic_vector(7 downto 0);

constant Datos_seno : tablaSeno := (
0 => x"7F", --
1 => x"81", --
2 => x"83", --
3 => x"86", --
4 => x"88", --
5 => x"8A", --
6 => x"8C", --
7 => x"8F", --
8 => x"91", --
9 => x"93", --
10 => x"95", --
11 => x"97", --
12 => x"9A", --
13 => x"9C", --
14 => x"9E", --
15 => x"A0", --
16 => x"A2", --
17 => x"A4", --
18 => x"A6", --
19 => x"A9", --
20 => x"AB", --
21 => x"AD", --
22 => x"AF", --
23 => x"B1", --
24 => x"B3", --
25 => x"B5", --
26 => x"B7", --
27 => x"B9", --
28 => x"BB", --
29 => x"BD", --
30 => x"BF", --
31 => x"C1", --
32 => x"C3", --
33 => x"C4", --
34 => x"C6", --
35 => x"C8", --
36 => x"CA", --
37 => x"CC", --
38 => x"CD", --
39 => x"CF", --
40 => x"D1", --
41 => x"D3", --
42 => x"D4", --
43 => x"D6", --
44 => x"D8", --
45 => x"D9", --
46 => x"DB", --
47 => x"DC", --
48 => x"DE", --
49 => x"DF", --
50 => x"E1", --
51 => x"E2", --
52 => x"E3", --
53 => x"E5", --
54 => x"E6", --
55 => x"E7", --
56 => x"E9", --
57 => x"EA", --
58 => x"EB", --
59 => x"EC", --
60 => x"ED", --
61 => x"EF", --
62 => x"F0", --
63 => x"F1", --
64 => x"F2", --
65 => x"F3", --
66 => x"F3", --
67 => x"F4", --
68 => x"F5", --
69 => x"F6", --
70 => x"F7", --
71 => x"F8", --
72 => x"F8", --
73 => x"F9", --
74 => x"FA", --
75 => x"FA", --
76 => x"FB", --
77 => x"FB", --
78 => x"FC", --
79 => x"FC", --
80 => x"FD", --
81 => x"FD", --
82 => x"FD", --
83 => x"FE", --
84 => x"FE", --
85 => x"FE", --
86 => x"FE", --
87 => x"FE", --
88 => x"FE", --
89 => x"FE", --
90 => x"FF", --
91 => x"FE", --
92 => x"FE", --
93 => x"FE", --
94 => x"FE", --
95 => x"FE", --
96 => x"FE", --
97 => x"FE", --
98 => x"FD", --
99 => x"FD", --
100 => x"FD", --
101 => x"FC", --
102 => x"FC", --
103 => x"FB", --
104 => x"FB", --
105 => x"FA", --
106 => x"FA", --
107 => x"F9", --
108 => x"F8", --
109 => x"F8", --
110 => x"F7", --
111 => x"F6", --
112 => x"F5", --
113 => x"F4", --
114 => x"F3", --
115 => x"F3", --
116 => x"F2", --
117 => x"F1", --
118 => x"F0", --
119 => x"EF", --
120 => x"ED", --
121 => x"EC", --
122 => x"EB", --
123 => x"EA", --
124 => x"E9", --
125 => x"E7", --
126 => x"E6", --
127 => x"E5", --
128 => x"E3", --
129 => x"E2", --
130 => x"E1", --
131 => x"DF", --
132 => x"DE", --
133 => x"DC", --
134 => x"DB", --
135 => x"D9", --
136 => x"D8", --
137 => x"D6", --
138 => x"D4", --
139 => x"D3", --
140 => x"D1", --
141 => x"CF", --
142 => x"CD", --
143 => x"CC", --
144 => x"CA", --
145 => x"C8", --
146 => x"C6", --
147 => x"C4", --
148 => x"C3", --
149 => x"C1", --
150 => x"BF", --
151 => x"BD", --
152 => x"BB", --
153 => x"B9", --
154 => x"B7", --
155 => x"B5", --
156 => x"B3", --
157 => x"B1", --
158 => x"AF", --
159 => x"AD", --
160 => x"AB", --
161 => x"A9", --
162 => x"A6", --
163 => x"A4", --
164 => x"A2", --
165 => x"A0", --
166 => x"9E", --
167 => x"9C", --
168 => x"9A", --
169 => x"97", --
170 => x"95", --
171 => x"93", --
172 => x"91", --
173 => x"8F", --
174 => x"8C", --
175 => x"8A", --
176 => x"88", --
177 => x"86", --
178 => x"83", --
179 => x"81", --
180 => x"7F", --
181 => x"7D", --
182 => x"7B", --
183 => x"78", --
184 => x"76", --
185 => x"74", --
186 => x"72", --
187 => x"6F", --
188 => x"6D", --
189 => x"6B", --
190 => x"69", --
191 => x"67", --
192 => x"64", --
193 => x"62", --
194 => x"60", --
195 => x"5E", --
196 => x"5C", --
197 => x"5A", --
198 => x"58", --
199 => x"55", --
200 => x"53", --
201 => x"51", --
202 => x"4F", --
203 => x"4D", --
204 => x"4B", --
205 => x"49", --
206 => x"47", --
207 => x"45", --
208 => x"43", --
209 => x"41", --
210 => x"3F", --
211 => x"3D", --
212 => x"3B", --
213 => x"3A", --
214 => x"38", --
215 => x"36", --
216 => x"34", --
217 => x"32", --
218 => x"31", --
219 => x"2F", --
220 => x"2D", --
221 => x"2B", --
222 => x"2A", --
223 => x"28", --
224 => x"26", --
225 => x"25", --
226 => x"23", --
227 => x"22", --
228 => x"20", --
229 => x"1F", --
230 => x"1D", --
231 => x"1C", --
232 => x"1B", --
233 => x"19", --
234 => x"18", --
235 => x"17", --
236 => x"15", --
237 => x"14", --
238 => x"13", --
239 => x"12", --
240 => x"11", --
241 => x"0F", --
242 => x"0E", --
243 => x"0D", --
244 => x"0C", --
245 => x"0B", --
246 => x"0B", --
247 => x"0A", --
248 => x"09", --
249 => x"08", --
250 => x"07", --
251 => x"06", --
252 => x"06", --
253 => x"05", --
254 => x"04", --
255 => x"04", --
256 => x"03", --
257 => x"03", --
258 => x"02", --
259 => x"02", --
260 => x"01", --
261 => x"01", --
262 => x"01", --
263 => x"00", --
264 => x"00", --
265 => x"00", --
266 => x"00", --
267 => x"00", --
268 => x"00", --
269 => x"00", --
270 => x"00", --
271 => x"00", --
272 => x"00", --
273 => x"00", --
274 => x"00", --
275 => x"00", --
276 => x"00", --
277 => x"00", --
278 => x"01", --
279 => x"01", --
280 => x"01", --
281 => x"02", --
282 => x"02", --
283 => x"03", --
284 => x"03", --
285 => x"04", --
286 => x"04", --
287 => x"05", --
288 => x"06", --
289 => x"06", --
290 => x"07", --
291 => x"08", --
292 => x"09", --
293 => x"0A", --
294 => x"0B", --
295 => x"0B", --
296 => x"0C", --
297 => x"0D", --
298 => x"0E", --
299 => x"0F", --
300 => x"11", --
301 => x"12", --
302 => x"13", --
303 => x"14", --
304 => x"15", --
305 => x"17", --
306 => x"18", --
307 => x"19", --
308 => x"1B", --
309 => x"1C", --
310 => x"1D", --
311 => x"1F", --
312 => x"20", --
313 => x"22", --
314 => x"23", --
315 => x"25", --
316 => x"26", --
317 => x"28", --
318 => x"2A", --
319 => x"2B", --
320 => x"2D", --
321 => x"2F", --
322 => x"31", --
323 => x"32", --
324 => x"34", --
325 => x"36", --
326 => x"38", --
327 => x"3A", --
328 => x"3B", --
329 => x"3D", --
330 => x"3F", --
331 => x"41", --
332 => x"43", --
333 => x"45", --
334 => x"47", --
335 => x"49", --
336 => x"4B", --
337 => x"4D", --
338 => x"4F", --
339 => x"51", --
340 => x"53", --
341 => x"55", --
342 => x"58", --
343 => x"5A", --
344 => x"5C", --
345 => x"5E", --
346 => x"60", --
347 => x"62", --
348 => x"64", --
349 => x"67", --
350 => x"69", --
351 => x"6B", --
352 => x"6D", --
353 => x"6F", --
354 => x"72", --
355 => x"74", --
356 => x"76", --
357 => x"78", --
358 => x"7B", --
359 => x"7D"); --

signal Datos_seno_ptr : integer range 0 to 359 :=0; --Datos_seno'HIGH + 1 := 0;
------------------------------------------------------------------
begin
------------------------------------------------------------------
--This process counts to 24(or 49), and then resets. It is used to divide the clock signal.

--This makes oneUSClock peak aprox. once every 1microsecond
process (CLK, btn0)
begin
if (CLK = '1' and CLK'event) then
-- if(cntUS = "110001") then --49 Nexys 3
if(cntUS = "011000" or btn0 = '1') then --24 Nexys 2 [50*20ns]=1us
cntUS <= "000000";
oneUSClk <= not oneUSClk;
else
cntUS <= cntUS + '1';
end if;
end if;
end process;
----------------------------------------------------------------------------------------------------
--This process increments the pointer Datos_seno_ptr
process (oneUSClk, btn0, Datos_seno_ptr)
begin
if (oneUSClk = '1' and oneUSClk'event) then
if Datos_seno_ptr = 359 or btn0 = '1' then
Datos_seno_ptr <= 0;
else
Datos_seno_ptr <= Datos_seno_ptr + 1;
end if;
end if;
end process;

---------------------contador------------------------------------
-- en este proceso se genera un contador de n=max+1 bits,
-- que servir como divisores de frecuencia para el contador
PROCESS(btn0, clk, cont)
begin
if btn0='1' then
CONT<=(others=>'0');
elsif (rising_edge(clk)) then -- reloj 50MHz

CONT<=CONT+'1'; -- contador ascendente

end if;

end process;

---------------------selecciona la velocidad de la seal------------------------------------
-- en este proceso se selecciona la velocidad con cont(max) o cont(max-1)
PROCESS(clk,sw, cont(max2),cont(max2-1))
begin
if(rising_edge(clk)) then -- reloj 50MHz
if sw='0' then clkdiv <= CONT(max2); -- reloj lento
else clkdiv <= CONT(max2-1); -- reloj rpido
end if;
end if;
end process;


---------------------contador (seal rampa)------------------------------------
-- en este proceso se genera un contador de 8 bits que depende
-- de clkdiv que sirve para generar una seal rampa
PROCESS(btn0, oneusclk,cont2)
begin
if btn0='1' then

CONT2<=(others=>'0');
elsif(rising_edge(oneusclk)) then -- reloj clkdiv

CONT2<=CONT2+'1'; -- contador ascendente

end if;
end process;

----SALIDA A LAS DACS---------------------------------------------------------------------------------------------
sine <= Datos_seno(Datos_seno_ptr);
ramp <= CONT2(max2 downto 0);

end Behavioral;

