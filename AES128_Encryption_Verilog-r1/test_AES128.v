
module AESEncrypt128_DUT_tb;

    // DUT Parameters
    localparam Nk = 4;
    localparam Nr = 10;
    localparam NUM_INPUTS = 4;

    // Inputs
    reg clk;
    reg reset;
    reg [127:0] data;
    reg [127:0] key;
    
    reg [127:0] data_inputs [0:NUM_INPUTS-1];
    integer cycle = 0;

    // Outputs
    wire [127:0] out;

    // Clock Generation
    always #1 clk = ~clk;

    // Instantiate the DUT
    AESEncrypt128_DUT dut (
        .data(data),
        .key(key),
        .clk(clk),
        .reset(reset),
        .out(out)
    );

    // Cycle counter
    integer cycle_count = 0;
    always @(posedge clk) begin
        if (reset)
            cycle_count <= 0;
        else
            cycle_count <= cycle_count + 1;
    end

    // Test process
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        data = 0;

        data_inputs[0] = 128'h00112233445566778899aabbccddeeff;
        data_inputs[1] = 128'h00000000000000000000000000000000;
        data_inputs[2] = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        data_inputs[3] = 128'h0123456789ABCDEF0123456789ABCDEF;

        key  = 128'h000102030405060708090a0b0c0d0e0f;

        // Apply reset
        #10;
        reset = 0;
        
        // Feed new input every clock cycle
        for (cycle = 0; cycle < NUM_INPUTS; cycle = cycle + 1) begin
            
            data = data_inputs[cycle];

            @(posedge clk);
        end

        // Wait enough time for pipeline flush
        #200;
        $finish;
    end

    // Monitor outputs with cycle count
    initial begin
        $display("Cycle\tReset\tOutput Data (Hex)");
        $monitor("%0d\t%b\t%h", cycle_count, reset, out);
    end

endmodule


