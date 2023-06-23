//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MEXILOGICS: CONTROL DE UN MÓDULO BLUETOOTH PARA ENCENDER UNA CARGA
//Rx BT HC-06 con salida a leds y display
module receptor(
input clk, //50MHz
input reset, //reset
input rx, //entrada de datos del modulo bluetooth (a DO)
output reg carga, //Salida hacia la carga 
output reg[7:0] leds=8'b00000000, //salida a leds
output reg[7:0] dsply=8'b11111110, //salida a display 7seg
output reg[7:0] anode=8'b1110 //salida a nodos
); //fin del mdulo receptor

//fsm states
reg [1:0] presentstate, nextstate;
parameter EDO_1 = 2'b00;
parameter EDO_2 = 2'b10;
//seales
reg control=0; //indica cuando ocurre el bit de start
reg done=0; // bandera que indica que termino de recibir los datos
reg[8:0]tmp=9'b000000000; //registro que recibe los datos enviados


//contadores para los retardos
reg[3:0]i = 4'b0000; //contador de los bits recibidos
reg[9:0]c = 10'b1111111111; //contador de retardos
reg delay = 0; //algoritmo para los retardos
reg[1:0]c2 = 2'b11;
reg capture = 0;

//proceso de retardo al triple de la frecuencia
//868*20ns=17.36us
//17.36us*3=58.08us
//58.08us*2=104.16us=1/9600baudios o bits/seg
always@(posedge clk)
begin
	if(c<868)
		c = c + 1;
	else
begin
		c=0;
		delay = ~delay;
end

end
//proceso para el contador C2 para la captura
always@(posedge delay)
begin
	if (c2>1)
	c2=0;
else
	c2 = c2 + 1;

end
//proceso para capturar en el bit de en medio (capture)
always@(c2)
begin
	if (c2==1)
	capture=1;
else
	capture=0;

end

//FSM actualizacin
always@(posedge capture, posedge reset)
if (reset) presentstate <= EDO_1;
else presentstate <= nextstate;

//FSM
always@(*)
begin
case(presentstate)
	EDO_1: begin
		if(rx==1 && done==0)
		begin
			control=0;
			nextstate= EDO_1;
		end
		else if(rx==0 && done==0)
		begin
			control=1;
			nextstate= EDO_2;
		end
		else
		begin
			control=0;
			nextstate= EDO_1;
		end
	end
	
	EDO_2: begin
		if(done==0)
		begin
			control=1;
			nextstate= EDO_2;
		end
		else
		begin
			control=0;
			nextstate= EDO_1;
		end
	end
	
	default
		nextstate= EDO_1;
endcase
end
//proceso de recepcin de datos
always@(posedge capture)
begin
	if (control==1 && done==0)
	begin
		tmp <= {rx,tmp[8:1]};
	end
end

//proceso que cuenta los bits que llegan (9 bits)
always@(posedge capture)
begin
if (reset)
begin
// abcdefgP
	leds<=8'b00000000;
	anode<=8'b01111111;
end
else if (control) begin
	if(i>=9)
	begin
	i=0;
	done=1;
	leds<=tmp[8:1];
	case (tmp[8:1]) // abcdefgp
		8'h30 : dsply <= 8'b00000011; // 0
		8'h31 : dsply <= 8'b10011111; // 1
		8'h32 : dsply <= 8'b00100101; // 2
		8'h33 : dsply <= 8'b00001101; // 3
		8'h34 : dsply <= 8'b10011001; // 4
		8'h35 : dsply <= 8'b01001001; // 5
		8'h36 : dsply <= 8'b01000001; // 6
		8'h37 : dsply <= 8'b00011111; // 7
		8'h38 : dsply <= 8'b00000001; // 8
		8'h39 : dsply <= 8'b00001001; // 9
		8'h42 : dsply <= 8'b11000001; // B
		8'h43 : dsply <= 8'b01100011; // C
		8'h44 : dsply <= 8'b10000101; // D
		8'h45 : dsply <= 8'b01100001; // E
		8'h46 : dsply <= 8'b01110001; // F
		8'h47 : dsply <= 8'b01000001; // G = 6.
		8'h48 : dsply <= 8'b10010001; // H
		8'h49 : dsply <= 8'b11011111; // I
		8'h2B : dsply <= 8'b10011101; // +
		8'h2F : dsply <= 8'b10110101; // /
		8'h41 : begin carga<= 1'b1; dsply <= 8'b00010001; end 
		8'h61 : begin carga<= 1'b1; dsply <= 8'b00010001; end
		8'h50 : begin carga<= 1'b0; dsply <= 8'b00110001; end 
		8'h70 : begin carga<= 1'b0; dsply <= 8'b00110001; end
		default : dsply <= 8'b11101111; // _
	endcase
	end
else
begin
	i=i+1;
	done=0;
end
end

else
	done=0;
end
endmodule // fin del mdulo receptor de BT