`timescale 1ns / 1ps
//MEXILOGICS
//Programa para controlar un banco de doble puerta
module doblepuerta(
//Declaramos el reloj, los inputs(interruptores de carrera)
//Y las salidas que controlaran las cerraduras 
input clk, input [1:0] switches, output servo, servo2
    );
	 
//Variable de contador	 
reg [17:0] counter =0;
//Variables para controlar la posicion de los servomotores
reg [17:0] position1 = 0;
reg [17:0] position2 = 0;

//Monitorear las caidas de reloj
always @(posedge clk)
begin
//Obtener el valor de los sensores de las puertas
  if (switches == 2'b01) //Si se abre la 1er puerta
   begin
	position1 <= 27000; //Puerta abierta
	position2 <= 77000; //Puerta cerrada
	end
	else if (switches == 2'b10)//Si se abre 2da 1er puerta
	 begin
	position2 <= 27000;
	position1 <= 77000;
	 end
	else if (switches == 2'b11)//Si se abren las dos puertas
	begin
	position1 <= 77000;
	position2 <= 77000;
	end
	else //Cuando las dos puertas estan cerradas, las puertas estan abiertas
	begin
	position1 <= 27000;
	position2 <= 27000;
	end


end


// Reloj de 50Hz

always @(posedge clk)

begin
//Comienza un contador de 20ms
  if (counter < 240000) counter <= counter + 1;

  else counter <= 0;

end
//Dependiendo del valor de la posicion, el pwm es alto por el tiempo se introdujo en la posicion 
assign servo = (counter < position1) ? 1:0;
assign servo2 = (counter < position2) ? 1:0;


endmodule
