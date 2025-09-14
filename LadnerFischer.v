module LadnerFischer(
    input [15:0] A, B,
    input Cin,
    output [15:0] Sum,
    output Cout
);

    // Initial generate/propagate
    wire [15:0] G0, P0;
    assign G0 = A & B;
    assign P0 = A ^ B;

    // Prefix levels
    wire [15:0] G1, P1;
    wire [15:0] G2, P2;
    wire [15:0] G3, P3;
    wire [15:0] G4, P4; // Final Stage

    genvar i;

    // Level 1:
    assign G1[0] = G0[0];
    assign P1[0] = P0[0];
    generate
        for (i=1; i<16; i=i+1) begin
            if (i%2 == 0) begin // Even bits are buffered
                assign G1[i] = G0[i];
                assign P1[i] = P0[i];
            end
            else begin // Odd bits combine with previous bit
                assign G1[i] = G0[i] | (P0[i] & G0[i-1]);
                assign P1[i] = P0[i] & P0[i-1];
            end
        end
    endgenerate
    
    // Level 2:
    assign G2[1:0] = G1[1:0];
    assign P2[1:0] = P1[1:0];
    generate
        for (i=2; i<16; i=i+1) begin
            if ((i % 4) < 2) begin // Buffer bits 4,5, 8,9, 12,13
                assign G2[i] = G1[i];
                assign P2[i] = P1[i];
            end
            else begin // Operator for bits 2,3, 6,7, 10,11, 14,15
                localparam from_bit = (i/4)*4 + 1;
                assign G2[i] = G1[i] | (P1[i] & G1[from_bit]);
                assign P2[i] = P1[i] & P1[from_bit];
            end
        end
    endgenerate

    // Level 3:
    assign G3[3:0] = G2[3:0];
    assign P3[3:0] = P2[3:0];
    generate
        for (i=4; i<16; i=i+1) begin
            if ((i % 8) < 4) begin // Buffer bits 8,9,10,11
                assign G3[i] = G2[i];
                assign P3[i] = P2[i];
            end
            else begin // Operator for bits 4-7 and 12-15
                localparam from_bit = (i/8)*8 + 3;
                assign G3[i] = G2[i] | (P2[i] & G2[from_bit]);
                assign P3[i] = P2[i] & P2[from_bit];
            end
        end
    endgenerate

    // Level 4:
    assign G4[7:0] = G3[7:0];
    assign P4[7:0] = P3[7:0];
    generate
        for (i=8; i<16; i=i+1) begin
            assign G4[i] = G3[i] | (P3[i] & G3[7]);
            assign P4[i] = P3[i] & P3[7];
        end
    endgenerate

    // -----------------------
    // Carry computation
    // -----------------------
    wire [16:0] C;
    assign C[0] = Cin;
    
    generate
        for (i = 0; i < 16; i = i + 1) begin
            assign C[i+1] = G4[i] | (P4[i] & Cin);
        end
    endgenerate
    
    // -----------------------
    // Sum and Cout
    // -----------------------
    assign Sum  = P0 ^ C[15:0];
    assign Cout = C[16];

endmodule