module KeyExpansionRound #(parameter Nk = 4, Nr = 10)(clk, roundCount, keyIn, keyOut);
    input clk;
    input [3:0] roundCount;
    input [32 * Nk - 1:0] keyIn;
    
    output reg [32 * Nk - 1:0] keyOut;

    genvar i;

    // Split the key into Nk words
    wire [31:0] words[Nk-1:0];
    
    generate
        for (i = 0; i < Nk; i = i + 1) begin: KeySplitLoop
            assign words[i] = keyIn[(32 * Nk - 1) - i * 32 -: 32];
        end
    endgenerate

    // Rotate last word
    wire [31:0] w3Rot = {words[Nk-1][23:0], words[Nk-1][31:24]};

    // SubWord for rotated word
    wire [31:0] w3Sub;
    generate
        for (i = 0; i < 4; i = i + 1) begin: SubWordLoop
            SubTable subTableInst(w3Rot[8*i +: 8], w3Sub[8*i +: 8]);
        end
    endgenerate

    // Round constant
    reg [7:0] rc;
    always @* begin
        case (roundCount)
            4'd1:  rc = 8'h01;
            4'd2:  rc = 8'h02;
            4'd3:  rc = 8'h04;
            4'd4:  rc = 8'h08;
            4'd5:  rc = 8'h10;
            4'd6:  rc = 8'h20;
            4'd7:  rc = 8'h40;
            4'd8:  rc = 8'h80;
            4'd9:  rc = 8'h1B;
            4'd10: rc = 8'h36;
            default: rc = 8'h00;
        endcase
    end
    wire [31:0] roundConstant = {rc, 24'h0};

    // First word of next key
    wire [31:0] w0_next = words[0] ^ w3Sub ^ roundConstant;

    // Remaining words
    wire [31:0] words_next [0:Nk-1];
    generate
        for (i = 1; i < Nk; i = i + 1) begin: KeyExpansionLoop
            // keep your intended logic; for AES-256 (Nk==8) special-case is retained
            assign words_next[i] = words[i] ^ ((Nk==8 && i==4) ? w3Sub : (i==1 ? w0_next : words_next[i-1]));
        end
    endgenerate

    // Combine words into 128/256-bit output (works for Nk==4)
    wire [32*Nk-1:0] keyOut_comb;
    assign keyOut_comb = {w0_next, words_next[1], words_next[2], words_next[3]};

    // Pipeline register: register the produced key
    always @(posedge clk) begin
        keyOut <= keyOut_comb;
    end

endmodule