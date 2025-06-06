module combined
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		  HEX0,
		  HEX1,
		  HEX2,
		  HEX3,
		  HEX4,
		  HEX5,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock      
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire boxwriteEn, dinowriteEn, writeEn;
	wire [7:0] outx3, outx2, outx1, outx0;
	wire [6:0] outy3, outy2, outy1, outy0, box_y;
	wire clock4out, clock60out, erase_box, draw0, draw1, draw2, draw3, draw_dino;
	wire [3:0] box_en;
	wire [3:0] x_column;
	wire column_erase_en, new_y_en;
	wire [6:0] generated_y;
	wire jump_sig;
	wire [3:0] counter10, hex1out, hex2out, hex3out, hex4out, hex5out;
	wire hex1sig, hex2sig, hex3sig, hex4sig, hex5sig;
	wire [6:0] h0out, h1out, h2out, h3out, h4out, h5out;
	wire collided;
	wire [7:0] dino_x;
	wire [6:0] dino_y;
	wire [2:0] dino_c;
	wire game_en;
	wire pause_dino;
	wire load_colour, enable;
	wire enable_hexes;
	wire enable2;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	

module collision(inx3, iny3, inx2, iny2, inx1, iny1, inx0, iny0, dino_x, dino_y, collision_detected);
	input [7:0] inx3, inx2, inx1, inx0;
	input [6:0] iny3, iny2, iny1, iny0;
	input [7:0] dino_x;
	input [6:0] dino_y;
	output reg collision_detected;
	
	always @(*) begin
		if (inx3 == dino_x + 3) begin
			if (dino_y + 3 > iny3)
				collision_detected = 1'b1;
			else 
				collision_detected = 1'b0;
		end
		else if (inx2 == dino_x + 3) begin
			if (dino_y + 3 > iny2)
				collision_detected = 1'b1;
			else 
				collision_detected = 1'b0;
		end
		else if (inx1 == dino_x + 3) begin
			if (dino_y + 3 > iny1)
				collision_detected = 1'b1;
			else 
				collision_detected = 1'b0;
		end
		else if (inx0 == dino_x + 3) begin
			if (dino_y + 3 > iny0)
				collision_detected = 1'b1;
			else 
				collision_detected = 1'b0;
		end
		else
			collision_detected = 1'b0;
	end

endmodule
			
	

module box_dino(inx3, iny3, inx2, iny2, inx1, iny1, inx0, iny0, inx_erase, iny_erase, dino_x, dino_y, dino_c, clock50mil, resetn, draw0, draw1, draw2, draw3, column_en, dinowriteEn, boxwriteEn, writeEn, outx, outy, outc);
	input [7:0] inx3, inx2, inx1, inx0;
	input [6:0] iny3, iny2, iny1, iny0;
	input [3:0] inx_erase;
	input [6:0] iny_erase;
	input draw0, draw1, draw2, draw3, column_en, clock50mil, resetn, dinowriteEn, boxwriteEn;
	
	output reg [7:0] outx;
	output reg [6:0] outy;
	output reg [2:0] outc;
	output reg writeEn;
	
	input [7:0] dino_x;
	input [6:0] dino_y;
	input [2:0] dino_c;
	wire [7:0] box_x;
	wire [6:0] box_y;
	wire [2:0] box_c;
	
	combined_boxdatapaths cb(inx3, iny3, inx2, iny2, inx1, iny1, inx0, iny0, inx_erase, iny_erase, clock50mil, resetn, draw0, draw1, draw2, draw3, column_en, box_x, box_y, box_c);

	always @(*) begin
		if (draw0 || draw1 || draw2 || draw3 || column_en) begin
			outx = box_x;
			outy = box_y;
			outc = box_c;
		end
		else if (dinowriteEn) begin
			outx = dino_x;
			outy = dino_y;
			outc = dino_c;
		end
		else begin
			outx = 0;
			outy = 0;
			outc = 0;
		end
	end
	
	always @(*) begin
		if (dinowriteEn || boxwriteEn)
			writeEn = 1'b1;
		else 
			writeEn = 1'b0;
	end
endmodule




module combined_boxdatapaths(inx3, iny3, inx2, iny2, inx1, iny1, inx0, iny0, inx_erase, iny_erase, clock50mil, resetn, draw0, draw1, draw2, draw3, column_en, x, y, c);
	input [7:0] inx3, inx2, inx1, inx0;
	input [6:0] iny3, iny2, iny1, iny0;
	input [3:0] inx_erase;
	input [6:0] iny_erase;
	input draw0, draw1, draw2, draw3;
	input column_en;
	input clock50mil, resetn;
	output reg [7:0] x;
	output reg [6:0] y;
	output reg [2:0] c;
	
	wire [7:0] erasex; 
	wire [7:0] x1, x2, x3, x0, x_erase;
	wire [6:0] y1, y2, y3, y0, y_erase;
	wire [2:0] c0, c1, c2, c3;
	wire [2:0] c_erase;
	wire [2:0] white;
	assign white = 3'b011;
	assign erasex = {4'b0000, inx_erase};
	
	datapath d0(draw0, inx0, iny0, white, clock50mil, resetn, x0, y0, c0);	
	datapath d1(draw1, inx1, iny1, white, clock50mil, resetn, x1, y1, c1);
	datapath d2(draw2, inx2, iny2, white, clock50mil, resetn, x2, y2, c2);
	datapath d3(draw3, inx3, iny3, white, clock50mil, resetn, x3, y3, c3);
	draw_column e0(clock50mil, erasex, iny_erase, 1'b0, resetn, column_en, x_erase, y_erase, c_erase); //create a column eraser
	
	
	always @(*) begin
		if (draw0) begin
			x = x0;
			y = y0;
			c = c0;
		end
		else if (draw1) begin
			x = x1;
			y = y1;
			c = c1;
		end
		else if (draw2) begin
			x = x2;
			y = y2;
			c = c2;
		end
		else if (draw3) begin
			x = x3;
			y = y3;
			c = c3;
		end
		else if (column_en) begin
			x = x_erase;
			y = y_erase;
			c = c_erase;
		end
		else begin
			x = 0;
			y = 0;
			c = 0;
		end
	end
endmodule
		

module box_control(clock4ps, enable, erase_box, clock50mil, resetn, draw0, draw1, draw2, draw3, erase_en, plot, pause_dino);
	input [3:0]enable; // enable signal for each box
	input clock4ps, clock50mil, resetn, erase_box;
	
	output reg plot;
	output reg draw0, draw1, draw2, draw3, erase_en, pause_dino;
	
	reg [2:0] current_state, next_state;
	
	wire [9:0] q;
	wire clock_200;
	
	counter c200(clock50mil, resetn, 1'b1, q);
	assign clock_200 = (q == 10'd0) ? 1 : 0; // one high for every 200 pixels 
	
	localparam hold = 3'd0, box0 = 3'd1, box1 = 3'd2, box2 = 3'd3, box3 = 3'd4, erase = 3'd5, pause = 3'd6;
	
	always @(*)
		begin : state_table
			case (current_state)
				hold: next_state = (clock4ps) ? box0 : hold;
				box0: next_state = box1;
				box1: next_state = box2;
				box2: next_state = box3;
				box3: next_state = erase_box ? erase : pause; // if there is a box to erase go to erase state, else skip to pause state
				erase: next_state = pause;
				pause: next_state = clock4ps ? pause : hold; 
			default: next_state = hold;
		endcase
	end
	
	always @(*) begin
		plot = 1'b0;
		pause_dino = 1'b0;
		draw0 = 1'b0;
		draw1 = 1'b0;
		draw2 = 1'b0;
		draw3 = 1'b0;
		erase_en = 1'b0;
		
		case (current_state)
			hold: begin
				plot = 1'b0;
				pause_dino = 1'b0;
				draw0 = 1'b0;
				draw1 = 1'b0;
				draw2 = 1'b0;
				draw3 = 1'b0;
				erase_en = 1'b0;
			end
			box0: begin
				if (enable[0]) begin
					plot = 1'b1;
					pause_dino = 1'b1;
					draw0 = 1'b1;
					draw1 = 1'b0;
					draw2 = 1'b0;
					draw3 = 1'b0;
					erase_en = 1'b0;
				end
			end
			box1: begin
				if (enable[1]) begin
					plot = 1'b1;
					pause_dino = 1'b1;
					draw0 = 1'b0;
					draw1 = 1'b1;
					draw2 = 1'b0;
					draw3 = 1'b0;
					erase_en = 1'b0;
				end
			end
			box2: begin
				if (enable[2]) begin
					plot = 1'b1;
					pause_dino = 1'b1;
					draw0 = 1'b0;
					draw1 = 1'b0;
					draw2 = 1'b1;
					draw3 = 1'b0;
					erase_en = 1'b0;
				end
			end
			box3: begin	
				if (enable[3]) begin
					plot = 1'b1;
					pause_dino = 1'b1;
					draw0 = 1'b0;
					draw1 = 1'b0;
					draw2 = 1'b0;
					draw3 = 1'b1;
					erase_en = 1'b0;
				end
			end
			erase: begin
				plot = 1'b1;
				pause_dino = 1'b1;
				draw0 = 1'b0;
				draw1 = 1'b0;
				draw2 = 1'b0;
				draw3 = 1'b0;
				erase_en = 1'b1;
			end
			pause: begin
				plot = 1'b0;
				pause_dino = 1'b0;
				draw0 = 1'b0;
				draw1 = 1'b0;
				draw2 = 1'b0;
				draw3 = 1'b0;
				erase_en = 1'b0;
			end
		endcase
	end
		
			
	always @(posedge clock_200)
	begin: state_FFs
		if (!resetn)
			current_state <= hold;
		else
			current_state <= next_state;
	end
	
endmodule

module datapath(box_en, inx, iny, inc, clock50mil, resetn, outx, outy, outc);
	input [7:0] inx;
	input [6:0] iny;
	input [2:0] inc;
	input box_en, clock50mil, resetn;
	output reg [7:0] outx;
	output reg [6:0] outy;
	output reg [2:0] outc;
	reg [7:0] tempx;
	reg [6:0] tempy;
	reg [2:0] tempc;
	
	wire [3:0] c1;
	wire [5:0] c2;
	
	wire [7:0] dx;
	wire [6:0] dy;
	wire [2:0] dc;
	reg [5:0] height;
	// heights = y = 60 (60 pixels long), 70 (50 pixels long), 90 ( 30 pixels long) 
	
	draw_column d0(clock50mil, inx, iny, 1'b1, resetn, box_en, dx, dy, dc);
	
	always @(posedge clock50mil) begin
		if (!resetn) begin
			tempx <= 8'b0;
			tempy <= 7'b0;
		end
		else if (box_en) begin
			tempx <= inx;
			tempy <= iny;
		end
	end
	
	always @(*) begin
		if (iny == 60)
			height = 6'd60;
		else if (iny == 70)
			height = 6'd50;
		else if (iny == 90)
			height = 6'd30;
		else 
			height = 6'd0;
	end
	
	counter_x count_x(clock50mil, resetn, box_en, c1);
	assign enable1 = (c1 == 4'd11) ? 1 : 0; // y only increments if x is 0 
	counter_y count_y(clock50mil, height, resetn, enable1, c2);
	
	always @(*) begin
		if (c1 == 4'd11 || c1 == 4'd12)
			tempc = 3'b0; // colour the rightmost column black to erase it
		else if (!box_en)  // box is empty 
			tempc = 3'd0;
		else 
			tempc = inc;
	end
	
	always @(*) begin
		if (inx <= 160 && inx >= 152) begin
			outx = dx;
			outy = dy;
			outc = dc;
		end
		else begin
		   outx = tempx + c1; // needs to be 10 bits wide
		   outy = tempy + c2; // needs to be 10 bits wide  
			outc = tempc;
		end
	end
	
endmodule

module draw_column(clock50mil, inx, iny, select, resetn, draw_en, outx, outy, outc);
	input [7:0] inx; // given x, y coord, erase that column starting at (x,y)
	input [6:0] iny;
	input clock50mil, resetn, select, draw_en;
	output [7:0] outx;
	output [6:0] outy;
	output [2:0] outc;
	
	reg [7:0] tempx;
	reg [6:0] tempy;
	reg [2:0] tempc;
	wire [5:0] c2; // counts to 20
	reg [5:0] height;
	
	always @(posedge clock50mil) begin
		if (!resetn) begin
			tempx <= 8'b0;
			tempy <= 7'b0;
		end
		else if (draw_en) begin
			tempx <= inx;
			tempy <= iny;
		end
	end
	
	always @(*) begin
		if (iny == 90)
			height = 6'd30;
		else if (iny == 70)
			height = 6'd50;
		else if (iny == 60)
			height = 6'd60;
		else 
			height = 6'd10;
	end
	
	counter_y county(clock50mil, height, resetn, draw_en, c2);
	
	always @(*) begin
		if (!select)
			tempc = 3'b000; // if select == 0, we are erasing
		else if (select)
			tempc = 3'b011; // if select == 1, box appearing, colour it cyan
	end
	
	assign outx = tempx;
	assign outy = tempy + c2;
	assign outc = tempc; // column should be coloured black
			
endmodule

module column_counter(clock4ps, resetn, enable, q, column_erase_en);
	input clock4ps, resetn, enable;
	output reg [3:0] q;
	output reg column_erase_en;
	
	always @(posedge clock4ps, negedge resetn) begin
		if (!resetn) begin
			q <= 4'b0;
			column_erase_en <= 1'b0;
		end
		else if (q == 4'b0 && enable) begin
			q <= 4'd11;
			column_erase_en <= 1;
		end
		else if (q != 4'b0) begin
			q <= q - 1;
			column_erase_en <= 1;
		end
		else
			column_erase_en <= 0;
	end
endmodule


module boxes_tracker(collided, enablenew, iny, clock_4ps, resetn, outx3, outy3, outx2, outy2, outx1, outy1, outx0, outy0, box, erase_box, box_y); 
	input enablenew, clock_4ps, resetn, collided;
	input [6:0]iny;
	output reg [7:0] outx3, outx2, outx1, outx0; 
	output reg [6:0] outy3, outy2, outy1, outy0; // 19:10 = x, 9:0 = y
	output reg [3:0]box;
	output reg [6:0] box_y;
	output reg erase_box;
	wire [7:0] y;
	reg [7:0] box_array [0:3][0:1]; // 
	integer i;
	
	assign y = {1'b0, iny};
	
	initial begin // initialize box array with values all 0
		for (i = 0; i < 4; i = i + 1) begin
			box_array[i][1] = 7'd0;
			box_array[i][0] = 7'd0;
			box[i] = 0;
		end
		erase_box = 1'b0;
	end
		
	// x is [0], y is [1]
	// NOTE: x coord shifting happens on neg clock edge. Adding new value/ shifting box values occurs on posedge
	always @(posedge clock_4ps) begin
		if (collided) begin
		end
		
		else if (enablenew) begin // if enable new is high, put in box leaving screen, else look for empty box to put in
			if (box[3] && box_array[3][0] == 0) begin
				erase_box <= 1'b1; 
				box_array[3][0] <= 8'd160;
				box_array[3][1] <= y;
				for (i = 0; i < 4; i = i + 1) begin // left shift non empty boxes
					if (i != 3 && box[i])
						box_array[i][0] <= box_array[i][0] - 1'b1;
				end
			end
			else if (box[2] && box_array[2][0] == 0) begin
				erase_box <= 1'b1;	
				box_array[2][0] <= 8'd160;
				box_array[2][1] <= y;
				for (i = 0; i < 4; i = i + 1) begin
					if (i != 2 && box[i])
						box_array[i][0] <= box_array[i][0] - 1'b1;
				end
			end
			else if (box[1] && box_array[1][0] == 0) begin
				erase_box <= 1'b1;
				box_array[1][0] <= 8'd160;
				box_array[1][1] <= y;
				for (i = 0; i < 4; i = i + 1) begin
					if (i != 1 && box[i])
						box_array[i][0] <= box_array[i][0] - 1'b1;
				end
			end
			else if (box[0] && box_array[0][0] == 0) begin
				erase_box <= 1'b1;
				box_array[0][0] <= 8'd160;
				box_array[0][1] <= y;
				for (i = 0; i < 4; i = i + 1) begin
					if (i != 0 && box[i])
						box_array[i][0] <= box_array[i][0] - 1'b1;
				end
			end
			else if (!box[3]) begin// else put in one of the empty boxes
				erase_box <= 1'b0;
				box_array[3][0] <= 8'd160;
				box_array[3][1] <= y;
				box[3] <= 1;
				for (i = 0; i < 4; i = i + 1) begin
					if (i != 3 && box[i])
						box_array[i][0] <= box_array[i][0] - 1'b1;
				end
			end
			else if (!box[2]) begin
				erase_box <= 1'b0;
				box_array[2][0] <= 8'd160;
				box_array[2][1] <= y;
				box[2] <= 1;
				for (i = 0; i < 4; i = i + 1) begin
					if (i != 2 && box[i])
						box_array[i][0] <= box_array[i][0] - 1'b1;
				end
			end
			else if (!box[1]) begin
				erase_box <= 1'b0;
				box_array[1][0] <= 8'd160;
				box_array[1][1] <= y;
				box[1] <= 1;
				for (i = 0; i < 4; i = i + 1) begin
					if (i != 1 && box[i])
						box_array[i][0] <= box_array[i][0] - 1'b1;
				end
			end
			else if (!box[0]) begin
				erase_box <= 1'b0;
				box_array[0][0] <= 8'd160;
				box_array[0][1] <= y;
				box[0] <= 1;
				for (i = 0; i < 4; i = i + 1) begin
					if (i != 0 && box[i])
						box_array[i][0] <= box_array[i][0] - 1'b1;
				end
			end
			else if (box[0] && box[1] && box[2] && box[3] && box_array[3][0] != 0 && box_array[2][0] != 0 && box_array[1][0] != 0 && box_array[0][0] != 0)
			begin
				for (i = 0; i < 4; i = i + 1) begin
					if (i != 0 && box[i])
						box_array[i][0] <= box_array[i][0] - 1'b1;
				end
				erase_box <= 1'b0;
			end
		end
		else begin// enable new not high, nothing new to add -> shift existing boxes
			if (box[3] && box_array[3][0] == 0) begin
				erase_box <= 1'b1;
				box_array[3][0] <= 8'd0;
				box_array[3][1] <= 8'd0;
				box[3] <= 0;
				for (i = 0; i < 3; i = i + 1) begin
					if (box[i])
						box_array[i][0] <= box_array[i][0] - 1'b1;
				end
			end
			else if (box[2] && box_array[2][0] == 0) begin
				erase_box <= 1'b1;
				box_array[2][0] <= 8'd0;
				box_array[2][1] <= 8'd0;
				box[2] <= 0;
				for (i = 0; i < 4; i = i + 1) begin
					if (i != 2 && box[i])
						box_array[i][0] <= box_array[i][0] - 1'b1;
				end
			end
			else if (box[1] && box_array[1][0] == 0) begin
				erase_box <= 1'b1;
				box_array[1][0] <= 8'd0;
				box_array[1][1] <= 8'd0;
				box[1] <= 0;
				for (i = 0; i < 4; i = i + 1) begin
					if (i != 1 && box[i])
						box_array[i][0] <= box_array[i][0] - 1'b1;
				end
			end
			else if (box[0] && box_array[0][0] == 0) begin
				erase_box <= 1'b1;
				box_array[0][0] <= 8'd0;
				box_array[0][1] <= 8'd0;
				box[0] <= 0;
				for (i = 0; i < 4; i = i + 1) begin
					if (i != 0 && box[i])
						box_array[i][0] <= box_array[i][0] - 1'b1;
				end
			end
			else begin // no box leaving, increment each by 1
				erase_box <= 1'b0;
				for (i = 0; i < 4; i = i + 1) begin
					if (box[i]) // box i not empty
						box_array[i][0] <= box_array[i][0] - 1'b1;
				end
			end
		end
	end
	
	always @(negedge clock_4ps) begin
		if (box_array[3][0] - 1 == 0)
			box_y = box_array[3][1];
		else if (box_array[2][0] - 1 == 0)
			box_y = box_array[2][1];
		else if (box_array[1][0] - 1 == 0)
			box_y = box_array[1][1];
		else if (box_array[0][0] - 1 == 0)
			box_y = box_array[0][1];
	end

	always @(*) begin
		outx3 = box_array[3][0]; 
		outx2 = box_array[2][0]; 
		outx1 = box_array[1][0]; 
		outx0 = box_array[0][0];
		
		outy3 = box_array[3][1][6:0]; 
		outy2 = box_array[2][1][6:0]; 
		outy1 = box_array[1][1][6:0]; 
		outy0 = box_array[0][1][6:0]; 
		
	end
	
endmodule

module clock60ps(clock,resetn,enable,out); // one high every 1/60th second
	input clock, resetn, enable;
	reg [19:0] q;
	output reg out;
		
	always @(posedge clock, negedge resetn) begin
		if(!resetn) begin
			q <= 20'd833333; //one high every 833,333 cycles
//			q <= 20'd2000;
			out <= 0;
		end
		else if (enable == 1'b1) begin
			if ( q == 0 ) begin
				q <= 20'd83333;
//				q <= 20'd2000;
				out <= 1;
			end
			else begin
				q <= q - 1;
				out <= 0;
			end
		end
	end
endmodule

module clock4ps(clock60ps, resetn, enable, out); // rate counter 4 pixels per second 
	input clock60ps, resetn, enable;
	reg [3:0] q;
	output reg out;
		
	always @(posedge clock60ps, negedge resetn) begin
		if (!resetn) begin
			q <= 4'b1111; // 15
			out <= 0;
		end
		else if (enable == 1'b1) begin
			if (q == 0) begin
				q <= 4'b1111;
				out <= 1;
			end
			else begin
				q <= q - 1;
				out <= 0;
			end
		end
	end
endmodule
					
module clocktest(clock50, resetn, enable, out60, out4);
	input clock50, resetn, enable;
	output out60, out4;
	wire outc60, outc4;
	
	clock60ps c60(clock50, resetn, enable, outc60);
	clock4ps c4(outc60, resetn, enable, outc4);
	
	assign out60 = outc60;
	assign out4 = outc4;
endmodule

module counter_x(clock, reset_n, enable, q); // count to 10 + 1 TEMP WIDTH 
	input clock, reset_n, enable;
	output reg 	[3:0] q;
	
	always @(posedge clock) begin
		if(reset_n == 1'b0)
			q <= 4'd12;
		else if (enable == 1'b1)
		begin
		  if (q == 4'd11)
			  q <= 4'd0;
			else if (q == 4'd12)
				q <= 4'd0;
		  else
			  q <= q + 1;
		end
   end
endmodule

module counter_y(clock, height, reset_n, enable, q); // count to 20 TEMP HEIGHT
	input clock, reset_n, enable;
	input [5:0] height;
	output reg 	[5:0] q;
	
	always @(posedge clock) begin
		if(reset_n == 1'b0)
			q <= 6'd0;
		else if (enable == 1'b1)
		begin
		  if (q == height)
			  q <= 6'd0;
		  else
			  q <= q + 1;
		end
   end
endmodule
	
module counter(clock, resetn, enable, q); // counts to 240 i.e. amount of time to draw 1 box
	input clock, resetn, enable;
	output reg [9:0] q;
	
	always @(posedge clock) begin
		if (!resetn)
			q <= 10'd0;
		else if (enable) begin
			if (q == 10'd800)
			 q <= 10'd0;
			else
				q <= q + 1;
		end
	end
endmodule

module count_box_enable(clock4ps, resetn, enable, q);// counts 60 cycles of 4ps i.e. amount of time between boxes
	input clock4ps, resetn, enable;
	output reg [7:0] q;
	
	always @(posedge clock4ps) begin
		if (!resetn)
			q <= 8'd0;
		else if (enable) begin
			if (q == 8'd60)
			 q <= 8'd0;
			else
				q <= q + 1;
		end
	end
endmodule

module random_height(CLOCK_50, clock4ps, resetn, enable, out_random_y, new_y_enable);
	input CLOCK_50, clock4ps, resetn, enable;
	output reg [6:0] out_random_y;
	output reg new_y_enable;
	wire [27:0] out50;
	wire [9:0] q;
	
	rate_divider rd(enable, 10'd60, clock4ps, resetn, q);
	counterto50mil c50(CLOCK_50, resetn, enable, out50);
	
	always @(posedge clock4ps) begin
		if (!resetn) begin
			new_y_enable <= 0;
			out_random_y <= 0;
		end
	
		else if (q == 10'd59) begin
			new_y_enable <= 1;
			if (out50 >= 0 && out50 <= 16666667)
				out_random_y <= 7'd60;
			else if (out50 > 16666667 && out50 <= 33333333)
				out_random_y <= 7'd70;
			else if (out50 > 33333333)
				out_random_y <= 7'd90;
		end
		else 
			new_y_enable <= 0;
	end
	
endmodule

module rate_divider(enable, data, clk, reset, q);
	input enable, clk, reset;
	input [9:0] data;
	output reg [9:0] q;
	
	always @(posedge clk, negedge reset)
	begin
		if (~reset)
			q <= data;
		else if (enable)
			begin
				if (q == 0)
					q <= data;
				else
					q <= q - 1'b1;
			end
	end
endmodule

module counterto50mil(CLOCK_50, resetn, enable, q);
	input CLOCK_50, resetn, enable;
	output reg [27:0] q;
	
	always @(posedge CLOCK_50, negedge resetn) begin
		if (!resetn)
			q <= 0;
		else if (enable) begin
			if (q == 28'd50000000)
				q <= 0;
			else
				q = q + 1;
		end
	end
endmodule


module count10seconds(CLOCK_50, resetn, enable, tencounter, enable_hexes); // outputs how many seconds have passed up to 10
	input CLOCK_50, resetn, enable;
	reg [27:0] q;
	output reg [3:0] tencounter;
	output reg enable_hexes;
//	output reg [3:0] h1, h2, h3, h4, h5;
	
	always @(posedge CLOCK_50) begin
		if (!resetn)
			q <= 0;
		else if (enable) begin
			if (q == 28'd49999999)
				q <= 0;
			else
				q = q + 1;
		end
	end
	
	always @(posedge CLOCK_50) begin
		if (!resetn) begin
			tencounter <= 0;
			enable_hexes <= 0;
		end
//			h1 <= 0;
//			h2 <= 0;
//			h3 <= 0;
//			h4 <= 0;
//			h5 <= 0;
		else if (enable) begin
			if (q == 28'd49999999) begin
				if (tencounter == 4'd9) begin
					tencounter <= 0;
					enable_hexes <= 1;
				end
//					h1 <= h1 + 1;
//				end
//				if (h1 == 4'd9) begin
//					h1 <= 0;
//					h2 <= h2 + 1;
//				end
//				if (h2 == 4'd9) begin
//					h2 <= 0;
//					h3 <= h3 + 1;
//				end
//				if (h3 == 4'd9) begin
//					h3 <= 0;
//					h4 <= h4 + 1;
//				end
//				if (h4 == 4'd9) begin
//					h4 <= 0;
//					h5 <= h5 + 1;
//				end
//				if (h5 == 4'd9) begin
//					tencounter <= 0;
//					h1 <= 0;
//					h2 <= 0;
//					h3 <= 0;
//					h4 <= 0;
//					h5 <= 0;
				else begin
				 tencounter <= tencounter + 1;
				 enable_hexes <= 1;
				end
			end
		end
	end	
endmodule

module counttens(clock, resetn, enable, q);
	input clock, resetn, enable;
	output reg [3:0] q;
	
	always @(posedge clock, negedge resetn) begin
		if (!resetn)
			q <= 0;
		else if (enable) begin
			if (q == 4'd9)
				q <= 0;
			else 
				q = q + 1;
		end
	end
endmodule


module test_rh(CLOCK_50, resetn, out_y, out_enable);
	input CLOCK_50, resetn;
	output [6:0] out_y;
	output out_enable;
	
	wire clock4out, clock60out;
	wire [6:0] y;
	wire en;
	
	clock4ps clock_4(clock60out, resetn, 1'b1, clock4out);
	clock60ps clock_60(CLOCK_50, resetn, 1'b1, clock60out);
	random_height rh(CLOCK_50, clock4out, resetn, 1'b1, y, en);
	
	assign out_y = y;
	assign out_enable = en;
endmodule

module control_combined_datapath(inx3, iny3, inx2, iny2, inx1, iny1, inx0, iny0, CLOCK_50, resetn, box_en, x, y, c, plot);
	input [7:0] inx3, inx2, inx1, inx0;
	input [6:0] iny3, iny2, iny1, iny0;
	input [3:0] box_en;
	input CLOCK_50, resetn;
	
	output [7:0] x;
	output [6:0] y;
	output [2:0] c;
	output plot;
	
	wire [7:0] xout;
	wire [6:0] yout;
	wire [2:0] cout;
	wire draw0, draw1, draw2, draw3;
	wire clock4out, clock60out;
	
	clock60ps c60(CLOCK_50, resetn, 1'b1, clock60out);
	clock4ps c4(clock60out, resetn, 1'b1, clock4out);
	box_control control(clock4out, box_en, CLOCK_50, resetn, draw0, draw1, draw2, draw3, plot);
	combined_boxdatapaths c_datapaths0(inx3, iny3, inx2, iny2, inx1, iny1, inx0, iny0, CLOCK_50, resetn, draw0, draw1, draw2, draw3, xout, yout, cout);
	assign x = xout;
	assign y = yout;
	assign c = cout;
	
endmodule

module all (CLOCK_50, resetn, draw_new, key, x, y, colour, writeEn);
	input CLOCK_50, resetn, draw_new, key;
	output [7:0] x;
	output [6:0] y;
	output [2:0] colour;
	output writeEn;
	wire boxwriteEn, dinowriteEn;
	wire [7:0] outx3, outx2, outx1, outx0;
	wire [6:0] outy3, outy2, outy1, outy0, box_y;
	wire clock4out, clock60out, erase_box, draw0, draw1, draw2, draw3, draw_dino;
	wire [3:0] box_en;
	wire [3:0] x_column;
	wire column_erase_en, new_y_en;
	wire [6:0] generated_y;
	wire jump_sig;
//	wire [3:0] counter10, hex1out, hex2out, hex3out, hex4out, hex5out;
//	wire hex1sig, hex2sig, hex3sig, hex4sig, hex5sig;
//	wire [3:0] h0out, h1out, h2out, h3out, h4out, h5out;
	
	clock4ps clock_4(clock60out, resetn, 1'b1, clock4out);
	clock60ps clock_60(CLOCK_50, resetn, 1'b1, clock60out);
	column_counter cc0(clock4out, resetn, erase_box, x_column, column_erase_en);
	
	box_dino bd0(outx3, outy3, outx2, outy2, outx1, outy1, outx0, outy0, x_column, box_y, jump_sig, load_colour, enable, CLOCK_50, resetn, draw_dino, draw0, draw1, draw2, draw3, draw_erase, dinowriteEn, boxwriteEn, writeEn, x, y, colour);
		
		box_control bc0(clock4out, box_en, column_erase_en, dinowriteEn, CLOCK_50, resetn, draw_dino, draw0, draw1, draw2, draw3, draw_erase, boxwriteEn);
		boxes_tracker b0(new_y_en, generated_y, clock4out, resetn, outx3, outy3, outx2, outy2, outx1, outy1, outx0, outy0, box_en, erase_box, box_y);
		
		random_height rh0(CLOCK_50, clock4out, resetn, 1'b1, generated_y, new_y_en);
		
		dino_control c(enable, CLOCK_50, resetn, key, load_colour, dinowriteEn); 

		assign jump_sig = 1'b1;
		
	
endmodule

module hexdecoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule

