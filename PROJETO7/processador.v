module processador(
  clock,
  reset,
  program_counter,
  register_A,
  memory_data_register_out,
  instruction_register
);
  input clock, reset;
  output [7:0] program_counter;
  output [15:0] register_A, memory_data_register_out, instruction_register;
  reg [15:0] register_A, instruction_register;
  reg [7:0] program_counter;
  reg [3:0] state;

  //State Encodings for Control Unit
  parameter reset_pc = 0,
            fetch = 1,
            decode = 2,
            execute_add = 3,
            execute_store = 4,
				execute_store2 = 5,
            execute_load = 6,
            execute_jump = 7,
            execute_jneg = 8;

  reg [7:0] memory_address_register;
  reg memory_write;

  wire [15:0] memory_data_register;
  wire [15:0] memory_data_register_out = memory_data_register;
  wire [15:0] memory_address_register_out = memory_address_register;
  wire memory_write_out = memory_write;
  
  altsyncram altsyncram_component (
	 .wren_a (memory_write_out),
	 .clock0 (clock),
	 .address_a (memory_address_register_out),
	 .data_a (register_A),
	 .q_a (memory_data_register));
	defparam
	 altsyncram_component.operation_mode = "SINGLE_PORT",
	 altsyncram_component.width_a = 16,
	 altsyncram_component.widthad_a = 8,
	 altsyncram_component.outdata_reg_a = "UNREGISTERED",
	 altsyncram_component.lpm_type = "altsyncram",
	// Reads in mif file for initial program and data values
	 altsyncram_component.init_file = "memoria.mif",
	 altsyncram_component.intended_device_family = "Cyclone";

  always @(posedge clock or posedge reset) begin
    if (reset)
      state = reset_pc;
    else
      case (state)
        reset_pc: begin
          program_counter = 8'b00000000;
          register_A = 16'b0000000000000000;
          state = fetch;
        end
        fetch: begin
          instruction_register = memory_data_register;
          program_counter = program_counter + 1;
          state = decode;
        end
        decode: begin
          case (instruction_register[15:8])
            8'b00000000: state = execute_add;
            8'b00000001: state = execute_store;
            8'b00000010: state = execute_load;
            8'b00000011: state = execute_jump;
				8'b00000101: state = execute_jneg;
            default: state = fetch;
          endcase
        end
        execute_add: begin
          register_A = register_A + memory_data_register;
          state = fetch;
        end
        execute_store: begin
          //write register_A to memory
          state = execute_store2;
        end
		  execute_store2: begin
          //write register_A to memory
          state = fetch;
        end
        execute_load: begin
          register_A = memory_data_register;
          state = fetch;
        end
        execute_jump: begin
          program_counter = instruction_register[7:0];
          state = fetch;
        end
		  execute_jneg: begin
          if(register_A[15] < 0)
				program_counter = instruction_register[7:0];
				state = fetch;
			end
         default: begin
          state = fetch;
			end
      endcase
  end

  always @(state or program_counter or instruction_register) begin
    case (state)
      reset_pc: memory_address_register = 8'h00;
      fetch: memory_address_register = program_counter;
      decode: memory_address_register = instruction_register[7:0];
      execute_add: memory_address_register = program_counter;
      execute_store: memory_address_register = instruction_register[7:0];
      execute_load: memory_address_register = program_counter;
      execute_jump: memory_address_register = instruction_register[7:0];
		execute_jneg: memory_address_register = instruction_register[7:0];
      default: memory_address_register = program_counter;
    endcase
    case (state)
      execute_store: memory_write = 1'b1;
      default: memory_write = 1'b0;
    endcase
  end
endmodule
