module SubBytes(clk, oriBytes, subBytes);
    input clk;
    input [127:0] oriBytes;
    output reg [127:0] subBytes; // This is now the 2nd stage register
    
    wire [127:0] subBytes_comb;
    reg  [127:0] subBytes_stage1; // ADDED: 1st stage register

    genvar i;
    generate  
        // No changes here
        for (i=7; i<128; i=i+8) begin: SubTableLoop
            SubTable s(oriBytes[i -:8], subBytes_comb[i -:8]);
        end
    endgenerate

    // Pipeline registers: output now takes 2 cycles
    always @(posedge clk) begin
        subBytes_stage1 <= subBytes_comb; // 1st cycle: S-box result is latched
        subBytes <= subBytes_stage1;      // 2nd cycle: Data is passed to the output
    end
endmodule
