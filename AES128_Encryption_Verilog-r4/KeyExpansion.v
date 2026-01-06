module KeyExpansionRound #(parameter Nk = 4, Nr = 10)(clk, roundCount, keyIn, keyOut);
    input clk;
    input [3:0] roundCount;
    input [32 * Nk - 1:0] keyIn;
    
    // This output is still the final register, making the module 2-cycle
    output reg [32 * Nk - 1:0] keyOut;

    genvar i;

    // Split the key into Nk words
    wire [31:0] words[Nk-1:0];
    
    generate
        // No changes here
        for (i = 0; i < Nk; i = i + 1) begin: KeySplitLoop
            assign words[i] = keyIn[(32 * Nk - 1) - i * 32 -: 32];
        end
    endgenerate

    // --- STAGE 1 LOGIC (Combinational) ---

    // Rotate last word
    wire [31:0] w3Rot = {words[Nk-1][23:0], words[Nk-1][31:24]};

    // SubWord for rotated word
    wire [31:0] w3Sub_comb; // CHANGED: Renamed to _comb
    generate
        for (i = 0; i < 4; i = i + 1) begin: SubWordLoop
            // CHANGED: Output to _comb wire
            SubTable subTableInst(w3Rot[8*i +: 8], w3Sub_comb[8*i +: 8]);
        end
    endgenerate

    // Round constant logic
    reg [7:0] rc;
    always @* begin
        // No changes here
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
    wire [31:0] roundConstant_comb = {rc, 24'h0}; // CHANGED: Renamed to _comb

    // --- PIPELINE REGISTER (Breaks the critical path) ---
    reg [31:0] w3Sub_reg;           // ADDED: Register for S-box result
    reg [31:0] words_reg [0:Nk-1];  // ADDED: Registers for all input words
    reg [31:0] roundConstant_reg;   // ADDED: Register for round constant

    integer j;
    always @(posedge clk) begin
        // Latch all combinational results from Stage 1
        w3Sub_reg <= w3Sub_comb;
        roundConstant_reg <= roundConstant_comb;
        for (j = 0; j < Nk; j = j + 1) begin
             words_reg[j] <= words[j];
        end
    end

    // --- STAGE 2 LOGIC (Combinational) ---

    // First word of next key
    // CHANGED: Uses registered values from Stage 1
    wire [31:0] w0_next = words_reg[0] ^ w3Sub_reg ^ roundConstant_reg;

    // Remaining words
    wire [31:0] words_next [0:Nk-1];
    generate
        for (i = 1; i < Nk; i = i + 1) begin: KeyExpansionLoop
            // CHANGED: Uses registered values from Stage 1
            // (Note: This logic is still serial, but it's just fast XORs)
            assign words_next[i] = words_reg[i] ^ ((Nk==8 && i==4) ? w3Sub_reg : (i==1 ? w0_next : words_next[i-1]));
        end
    endgenerate

    // Combine words (works for Nk==4)
    wire [32*Nk-1:0] keyOut_comb;
    assign keyOut_comb = {w0_next, words_next[1], words_next[2], words_next[3]};

    // Final Pipeline register (This is the 2nd stage register)
    always @(posedge clk) begin
        keyOut <= keyOut_comb; // Latch the result of the Stage 2 logic
    end

endmodule
