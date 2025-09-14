module Sklanksy(
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

    // Level 1
    assign G1[0] = G0[0];
    assign P1[0] = P0[0];

    genvar i;
    generate
        for(i=1;i<16;i=i+1)begin
            if(i%2 == 0) begin
                assign G1[i] = G0[i];
                assign P1[i] = P0[i];
            end
            else begin
                assign G1[i] = G0[i] | (P0[i] & G0[i-1]);
                assign P1[i] = P0[i] & P0[i-1];
            end
        end
    endgenerate

    // Level 2

    // Buffers
    assign G2[1:0] = G1[1:0];
    assign P2[1:0] = P1[1:0];

    assign G2[5:4] = G1[5:4];
    assign P2[5:4] = P1[5:4];

    assign G2[9:8] = G1[9:8];
    assign P2[9:8] = P1[9:8];

    assign G2[13:12] = G1[13:12];
    assign P2[13:12] = P1[13:12];

    // Dot operators
    assign G2[2] = G1[2] | (P1[2] & G1[1]);
    assign P2[2] = P1[2] & P1[1];

    assign G2[3] = G1[3] | (P1[3] & G1[1]);
    assign P2[3] = P1[3] & P1[1];

    assign G2[6] = G1[6] | (P1[6] & G1[5]);
    assign P2[6] = P1[6] & P1[5];

    assign G2[7] = G1[7] | (P1[7] & G1[5]);
    assign P2[7] = P1[7] & P1[5];

    assign G2[10] = G1[10] | (P1[10] & G1[9]);
    assign P2[10] = P1[10] & P1[9];

    assign G2[11] = G1[11] | (P1[11] & G1[9]);
    assign P2[11] = P1[11] & P1[9];

    assign G2[14] = G1[14] | (P1[14] & G1[13]);
    assign P2[14] = P1[14] & P1[13];

    assign G2[15] = G1[15] | (P1[15] & G1[13]);
    assign P2[15] = P1[15] & P1[13];

    // Level 3

    // Buffers
    assign G3[3:0] = G2[3:0];
    assign P3[3:0] = P2[3:0];

    assign G3[11:8] = G2[11:8];
    assign P3[11:8] = P2[11:8];
    
    // Dot operators
    assign G3[4] = G2[4] | (P2[4] & G2[3]);
    assign P3[4] = P2[4] & P2[3];

    assign G3[5] = G2[5] | (P2[5] & G2[3]);
    assign P3[5] = P2[5] & P2[3];

    assign G3[6] = G2[6] | (P2[6] & G2[3]);
    assign P3[6] = P2[6] & P2[3];

    assign G3[7] = G2[7] | (P2[7] & G2[3]);
    assign P3[7] = P2[7] & P2[3];

    assign G3[12] = G2[12] | (P2[12] & G2[11]);
    assign P3[12] = P2[12] & P2[11];

    assign G3[13] = G2[13] | (P2[13] & G2[11]);
    assign P3[13] = P2[13] & P2[11];

    assign G3[14] = G2[14] | (P2[14] & G2[11]);
    assign P3[14] = P2[14] & P2[11];

    assign G3[15] = G2[15] | (P2[15] & G2[11]);
    assign P3[15] = P2[15] & P2[11];

    // Level 4

    // Buffers
    assign G4[7:0] = G3[7:0];
    assign P4[7:0] = P3[7:0];

    generate;
        for (i=8;i<16;i=i+1) begin
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