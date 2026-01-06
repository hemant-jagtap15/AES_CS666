module AESEncrypt #(parameter Nk=4, Nr=10)(
    input clk, reset,
    input  [127:0] data_in,
    input  [((Nr+1)*128)-1:0] allKeys,
    output [127:0] data_out
);

    reg  [127:0] state_pipe [0:Nr];  // pipeline registers for each stage
    wire [127:0] stage_out [0:Nr];   // stage outputs

    integer i;

    // Stage 0: initial AddRoundKey
    AddRoundKey rk0(data_in, allKeys[((Nr+1)*128)-1 -: 128], stage_out[0]);

    // Stages 1 to Nr-1
    genvar r;
    generate
        for (r=1; r<Nr; r=r+1) begin: AES_ROUNDS
            wire [127:0] sb, sr, mc;
            SubBytes  sbm(state_pipe[r-1], sb);
            ShiftRows srm(sb, sr);
            MixColumns mcm(sr, mc);
            AddRoundKey akm(mc, allKeys[((Nr+1-r)*128)-1 -: 128], stage_out[r]);
        end
    endgenerate

    // Final round: no MixColumns
    wire [127:0] sb_last, sr_last;
    SubBytes  sb_final(state_pipe[Nr-1], sb_last);
    ShiftRows sr_final(sb_last, sr_last);
    AddRoundKey rk_final(sr_last, allKeys[127:0], stage_out[Nr]);

    // Pipeline registers
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i=0; i<=Nr; i=i+1)
                state_pipe[i] <= 0;
        end else begin
            state_pipe[0] <= stage_out[0];
            for (i=1; i<=Nr; i=i+1)
                state_pipe[i] <= stage_out[i];
        end
    end

    assign data_out = state_pipe[Nr];

endmodule

module AESEncrypt128_DUT(data,key,clk,reset,out);
	localparam Nk = 4;
	localparam Nr = 10;

	input [127:0] data;
	input [Nk * 32 - 1:0] key;
	input clk,reset;
	output [127:0] out;
	
	wire [((Nr + 1) * 128) - 1:0] allKeys;
	
	

	KeyExpansion #(Nk, Nr) ke(key, allKeys);
	AESEncrypt #(Nk, Nr) aes(clk, reset, data, allKeys, out);

endmodule



