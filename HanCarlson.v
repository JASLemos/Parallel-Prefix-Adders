module HanCarlson(
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
    wire [15:0] G4, P4;
    wire [15:0] G5, P5; // Final Stage

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
    assign G2[2:0] = G1[2:0];
    assign P2[2:0] = P1[2:0];
    generate
        for (i=3;i<16;i=i+1) begin
            if (i%2==0) begin
                assign G2[i] = G1[i];
                assign P2[i] = P1[i];
            end
            else begin
                assign G2[i] = G1[i] | (P1[i] & G1[i-2]);
                assign P2[i] = P1[i] & P1[i-2];
            end
        end
    endgenerate
    
    // Level 3
    assign G3[4:0] = G2[4:0];
    assign P3[4:0] = P2[4:0];
    generate
        for (i=5;i<16;i=i+1) begin
            if (i%2==0) begin
                assign G3[i] = G2[i];
                assign P3[i] = P2[i];
            end
            else begin
                assign G3[i] = G2[i] | (P2[i] & G2[i-4]);
                assign P3[i] = P2[i] & P2[i-4];
            end
        end
    endgenerate

    // Level 4
    assign G4[8:0] = G3[8:0];
    assign P4[8:0] = P3[8:0];
    generate
        for (i=9;i<16;i=i+1) begin
            if (i%2 == 0) begin
                assign G4[i] = G3[i];
                assign P4[i] = P3[i];
            end
            else begin
                assign G4[i] = G3[i] | (P3[i] & G3[i-8]);
                assign P4[i] = P3[i] & P3[i-8];
            end
        end
    endgenerate

    // Level 5
    assign G5[0] = G4[0];
    assign P5[0] = P4[0];
    generate
        for (i=1;i<16;i=i+1) begin
            if (i%2 == 0) begin
                assign G5[i] = G4[i] | (P4[i] & G4[i-1]);
                assign P5[i] = P4[i] & P4[i-1];
            end
            else begin
                assign G5[i] = G4[i];
                assign P5[i] = P4[i];
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
            assign C[i+1] = G5[i] | (P5[i] & Cin);
        end
    endgenerate
    
    // -----------------------
    // Sum and Cout
    // -----------------------
    assign Sum  = P0 ^ C[15:0];
    assign Cout = C[16];

endmodule