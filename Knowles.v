module Knowles(
    input  [15:0] A, B,
    input         Cin,
    output [15:0] Sum,
    output        Cout
);

    // Initial generate/propagate
    wire [15:0] G0, P0;
    assign G0 = A & B;
    assign P0 = A ^ B;

    // Prefix levels
    wire [15:0] G1, P1;
    wire [15:0] G2, P2;
    wire [15:0] G3, P3;
    wire [15:0] G4, P4;  // final stage

    // -----------------------
    // Level 1: distance = 1
    // -----------------------
    assign G1[0] = G0[0];   // Buffers
    assign P1[0] = P0[0];   // Buffers
    genvar i;
    generate
        for (i = 1; i < 16; i = i + 1) begin
          assign G1[i] = G0[i] | (P0[i] & G0[i-1]);
          assign P1[i] = P0[i] & P0[i-1];
        end
    endgenerate

    // -----------------------
    // Level 2: distance = 2
    // -----------------------
    assign G2[1:0] = G1[1:0];   // Buffers
    assign P2[1:0] = P1[1:0];   // Buffers
    generate
        for (i = 2; i < 16; i = i + 1) begin
            assign G2[i] = G1[i] | (P1[i] & G1[i-2]);
            assign P2[i] = P1[i] & P1[i-2];
        end
    endgenerate

    // -----------------------
    // Level 3: distance = 4
    // -----------------------
    assign G3[3:0] = G2[3:0];   // Buffers
    assign P3[3:0] = P2[3:0];   // Buffers
    generate
        for (i = 4; i < 16; i = i + 1) begin
          assign G3[i] = G2[i] | (P2[i] & G2[i-4]);
          assign P3[i] = P2[i] & P2[i-4];
        end
    endgenerate

    // -----------------------
    // Level 4: distance = 8
    // -----------------------
    assign G4[7:0] = G3[7:0];   // Buffers  
    assign P4[7:0] = P3[7:0];   // Buffers
    generate
        for (i = 8; i < 16; i = i + 1) begin
            if(i%2 == 0) begin
                assign G4[i] = G3[i] | (P3[i] & G3[i-7]);
                assign P4[i] = P3[i] & P3[i-7];
            end
            else begin
                assign G4[i] = G3[i] | (P3[i] & G3[i-8]);
                assign P4[i] = P3[i] & P3[i-8];
            end   
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
