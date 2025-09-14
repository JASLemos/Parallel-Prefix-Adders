`timescale 1ns / 1ps

module testbench();

    // Inputs
    reg  [15:0] A, B;
    reg         Cin;

    // Outputs
    wire [15:0] Sum;
    wire        Cout;

    // Variables for the self-verifying logic

    reg  [15:0] expected_sum;
    reg         expected_cout;
    integer     i;
    integer     error_count = 0;

    localparam N = 1000000;

    Sklanksy DUT(
    .A(A),
    .B(B),
    .Cin(Cin),
    .Sum(Sum),
    .Cout(Cout)
    );

    initial begin

        // Loop to run N random test cases
        for (i = 0; i < N; i = i + 1) begin
            A   = $random;
            B   = $random;
            Cin = $random % 2;

            {expected_cout, expected_sum} = A + B + Cin;

            #10;

            if ({Cout, Sum} !== {expected_cout, expected_sum}) begin
                error_count = error_count + 1;
            end
        end

        #10;
        if (error_count == 0) begin
            $display("SUCCESS: All %0d random tests passed!", i);
        end else begin
            $display("FAILURE: %0d out of %0d tests failed.", error_count, i);
        end

        $finish;

    end

endmodule

