library verilog;
use verilog.vl_types.all;
entity processador is
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        program_counter : out    vl_logic_vector(7 downto 0);
        register_A      : out    vl_logic_vector(15 downto 0);
        memory_data_register_out: out    vl_logic_vector(15 downto 0);
        instruction_register: out    vl_logic_vector(15 downto 0)
    );
end processador;
