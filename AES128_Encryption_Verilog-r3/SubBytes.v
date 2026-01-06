module SubBytes(clk, oriBytes, subBytes);
    input clk;
    input [127:0] oriBytes;
    output reg [127:0] subBytes;
    wire [127:0] subBytes_comb;

    genvar i;
    generate 
        // your original indexing style retained
        for (i=7; i<128; i=i+8) begin: SubTableLoop
            SubTable s(oriBytes[i -:8], subBytes_comb[i -:8]);
        end
    endgenerate

    // Pipeline register: output updates on clock
    always @(posedge clk) begin
        subBytes <= subBytes_comb;
    end
endmodule