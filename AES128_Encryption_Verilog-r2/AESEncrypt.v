module AESEncrypt #(parameter Nk=4, Nr=10)(
    input clk, reset,
    input  [127:0] data_in,
    input  [127:0] key,
    output [127:0] data_out
);

    reg  [127:0] state_pipe [0:Nr];  // pipeline registers for each stage
    wire [127:0] stage_out [0:Nr];   // stage outputs
    reg [127:0] key_pipe   [0:Nr];   // pipeline registers for round keys
    wire [127:0] key_out   [0:Nr];   // key outputs

    integer i;

    // Stage 0: initial AddRoundKey
    AddRoundKey rk0(data_in, key, stage_out[0]);

    // Stages 1 to Nr-1
    genvar r;
    generate
        for (r=1; r<Nr; r=r+1) begin: AES_ROUNDS
            wire [127:0] sb, sr, mc;
            wire [3:0] rcon = r;
            SubBytes  sbm(state_pipe[r-1], sb);
            ShiftRows srm(sb, sr);
            MixColumns mcm(sr, mc);
            KeyExpansionRound #(Nk, Nr) rke(rcon, key_pipe[r-1], key_out[r]);
            AddRoundKey akm(mc, key_out[r], stage_out[r]);
        end
    endgenerate

    // Final round: no MixColumns
    wire [127:0] sb_last, sr_last;
    wire [3:0] lstr = Nr;
    SubBytes  sb_final(state_pipe[Nr-1], sb_last);
    ShiftRows sr_final(sb_last, sr_last);
    KeyExpansionRound #(Nk, Nr) rke(lstr, key_pipe[Nr-1], key_out[Nr]);
    AddRoundKey rk_final(sr_last, key_out[Nr], stage_out[Nr]);

    // Pipeline registers
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i=0; i<=Nr; i=i+1) begin
                state_pipe[i] <= 0;
                key_pipe[i] <= 0;
            end
        end 
        else begin
            state_pipe[0] <= stage_out[0];
            key_pipe[0] <= key;
            for (i=1; i<=Nr; i=i+1) begin
                state_pipe[i] <= stage_out[i];
                key_pipe[i] <= key_out[i];
            end
        end
    end

    assign data_out = state_pipe[Nr];

endmodule
