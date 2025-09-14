module BrentKung(
    input [15:0] A, B,
    input Cin,
    output [15:0] Sum,
    output Cout
);

    // Initial generate and propagate
    wire [15:0] G0, P0;
    assign G0 = A & B;
    assign P0 = A ^ B;

    // Prefix levels
    wire [15:0] G1, P1;
    wire [15:0] G2, P2;
    wire [15:0] G3, P3;
    wire [15:0] G4, P4;
    wire [15:0] G5, P5;
    wire [15:0] G6, P6; // Final Stage

    genvar i;

    // Level 1:
    generate
        for(i=0; i<16; i=i+1) begin
            if (i%2 != 0) begin 
                assign G1[i] = G0[i] | (P0[i] & G0[i-1]);
                assign P1[i] = P0[i] & P0[i-1];
            end else begin 
                assign G1[i] = G0[i];
                assign P1[i] = P0[i];
            end
        end
    endgenerate

    // Level 2:
    generate
        for(i=0; i<16; i=i+1) begin
            if ((i+1)%4 == 0 && i>0) begin
                assign G2[i] = G1[i] | (P1[i] & G1[i-2]);
                assign P2[i] = P1[i] & P1[i-2];
            end else begin
                assign G2[i] = G1[i];
                assign P2[i] = P1[i];
            end
        end
    endgenerate

    // Level 3:
    generate
        for(i=0; i<16; i=i+1) begin
            if ((i+1)%8 == 0 && i>0) begin
                assign G3[i] = G2[i] | (P2[i] & G2[i-4]);
                assign P3[i] = P2[i] & P2[i-4];
            end else begin
                assign G3[i] = G2[i];
                assign P3[i] = P2[i];
            end
        end
    endgenerate

    // Level 4:
    generate
        for(i=0; i<16; i=i+1) begin
            if (i == 11 || i == 15) begin
                assign G4[i] = G3[i] | (P3[i] & G3[7]);
                assign P4[i] = P3[i] & P3[7];
            end else begin
                assign G4[i] = G3[i];
                assign P4[i] = P3[i];
            end
        end
    endgenerate

    // Level 5:
    generate
        for(i=0; i<16; i=i+1) begin
            if (i == 5) begin
                assign G5[i] = G4[i] | (P4[i] & G4[3]);
                assign P5[i] = P4[i] & P4[3];
            end else if (i == 9) begin
                assign G5[i] = G4[i] | (P4[i] & G4[7]);
                assign P5[i] = P4[i] & P4[7];
            end else if (i == 13) begin
                assign G5[i] = G4[i] | (P4[i] & G4[11]);
                assign P5[i] = P4[i] & P4[11];
            end else begin
                assign G5[i] = G4[i];
                assign P5[i] = P4[i];
            end
        end
    endgenerate

    // Level 6:
    generate
        for(i=0; i<16; i=i+1) begin
            if (i%2 == 0 && i>0) begin 
                assign G6[i] = G5[i] | (P5[i] & G5[i-1]);
                assign P6[i] = P5[i] & P5[i-1];
            end else begin 
                assign G6[i] = G5[i];
                assign P6[i] = P5[i];
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
            assign C[i+1] = G6[i] | (P6[i] & Cin);
        end
    endgenerate
    
    // -----------------------
    // Sum and Cout
    // -----------------------
    assign Sum  = P0 ^ C[15:0];
    assign Cout = C[16];
 
endmodule