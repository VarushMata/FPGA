//--------------------------------------------------------------------------------
//--MEXILOGICS
//--PUNTO 1 CONTROL DE UN MOTOR A PASOS UTILIZANDO UN ENCODER
//MECANICO. EL MOTOR GIRA HACIA DONDE SE GIRA EL ENCODER
//----------------------------------------------------------------------------------
`timescale 1ns / 1ps

module Motor_PAP_rotENC(
	Ain,Bin,Shaft, //rotary encoder to lower JA
	Aout,Bout,Shaftout, //LD0,LD1,LD2
	Anot,Bnot,Shaftnot, //LD5,LD6,LD7
	seg,AN,
	motor
    );
//input and output
input wire Ain,Bin,Shaft;
output reg Aout,Bout,Shaftout;
output reg Anot,Bnot,Shaftnot;
output reg [7:0] seg;
output reg [7:0] AN;
output reg [3:0] motor;

//signal
wire [2:0] ShAB; //join shaft, Ain and Bin

assign ShAB = {Shaft,Ain, Bin};
//La entrada A y B indican la direccion a la que se gira el encoder 
always@(Ain,Bin,Shaft) begin
	Aout = Ain;
	Anot = ~Ain;
	Bout = Bin;
	Bnot = ~Bin;
	Shaftout = Shaft;
	Shaftnot = ~Shaft;

end

always@(ShAB) begin
	//Para cada valor del encoder se aumenta o decrementa la fase del motor, haciendolo
	//girar en el sentido en el que se gira el encoder
	case(ShAB)
	3'b011 : begin seg<=8'b11111001; AN <= 8'b11111110; motor <= 4'b0001;  end //1
	3'b010 : begin seg<=8'b10100100; AN <= 8'b11111101; motor <= 4'b0010;  end //2
	3'b000 : begin seg<=8'b10110000; AN <= 8'b11111011; motor <= 4'b0100;  end //3
	3'b001 : begin seg<=8'b10011001; AN <= 8'b11110111; motor <= 4'b1000;  end //4
	3'b111 : begin seg<= 8'b10001001; AN <= 8'b11110111; motor <= 4'b1000; end // H
	default : begin seg<=8'b01111111; AN <= 8'b11110000; motor <= 4'b0000;  end //punto
	endcase;
end


endmodule
