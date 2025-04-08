/*
Lucas Rodrigues da Silva 834724
Murilo Oliva Mantovani 834730
Nicolas Magno Messias da Silva 834054
Ryan Augusto Ribeiro 830913
*/


//Códido para ligar o alarme (acender o LED) de acordo com os estados das lampadas(SW[1] e SW[0]),seguindo a ordem 1-2-3 (01,10,11).
module projeto2(
	KEY,
	SW,
	LEDR
);


input wire	[1:0] KEY;
input wire	[1:0] SW;
output wire	[0:0] LEDR;

//Fios
wire	AND1,AND2,AND3,AND4,AND5,AND6;
wire	CLK,RST;
wire	D0,D1;
wire	NX0,NX1;
wire	OR1;
reg 	Q0,Q1;
wire	X0,X1;

reg [1:0] y,Y;

assign y = {Q1,Q0};
assign Y = {D1,D0};

//
parameter[1:0] A = 2'b00, B = 2'b01, C = 2'b10, D = 2'b11;
assign	AND1 = Q1 & Q0;

always@(posedge CLK, negedge RST)
begin
if (!RST)
	begin
	y <= 0;
	end
else
	begin
	y <= Y;
	end
end

always @(posedge CLK, negedge RST)
begin
	case(y)
	 A: Y ? B : A;
	 B: if (C)
			Y <= C;
		 if (A || B)
			Y <= B;
		 
			
		


//Portas NOT
assign	NX1 =  ~X1;
assign	NX0 =  ~X0;

//Portas AND
assign	AND2 = X1 & Q1 & X0;
assign	AND3 = NX0 & NX1 & Q0;
assign	AND4 = NX1 & X0;
assign	AND5 = NX1 & NX0 & Q1;
assign	AND6 = X1 & NX0 & Q0;

//Portas OR
assign	OR1 = AND2 | AND1;

//Proximo es
assign	D0 = AND3 | AND4 | OR1;
assign	D1 = AND5 | AND6 | OR1;

//Associação com a placa
assign	LEDR = AND1;  //Saída
assign	RST = KEY[0];
assign	CLK = KEY[1];
assign	X1 = SW[1];
assign	X0 = SW[0];


endmodule
