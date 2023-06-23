`timescale 1ns / 1ps

module Escaleras_elec(
	clk,
	motor,
	sensor,
	leds
    );

input wire clk;
input wire sensor;
output reg [3:0] motor;
output reg [3:0] leds;

parameter frec = 50000000;
parameter frec_out = 4;
parameter max_count = frec/(2*frec_out);

reg clk_out;
reg [1:0] sel;
reg [22:0] count;

always@(posedge clk) begin

	if(count ==(max_count)) begin
	clk_out = ~clk_out;
	count = 0;
	end

	else begin
	count = count + 1;
	end
end

always@(clk_out) begin

	if(clk_out && clk_out == 1) begin
	sel = sel + 1'b1;
	end

end

always@(sel) begin
case(sel)
	2'b00 : begin motor = 4'b0001; leds = 4'b0001; end //1
	2'b01 : begin motor = 4'b0010; leds = 4'b0010; end
	2'b10 : begin motor = 4'b0100; leds = 4'b0100; end
	2'b11 : begin motor = 4'b1000; leds = 4'b1000; end
	default : begin motor = 4'b0000; leds = 4'b1000; end
endcase
end



endmodule
