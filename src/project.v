/*
 * Copyright (c) 2024 Devesh Bhaskaran
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_db_MAC (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

reg [7:0] reg_a,reg_b;
wire [15:0] W,Sum;
reg [15:0] Out;


assign uio_oe = clk ? 8'hFF : 8'h00;
  
always @(posedge clk or negedge rst_n) begin
      
        if (!rst_n) begin
            reg_a <= 0;
				reg_b <= 0;
        end else begin
            reg_a<=ui_in;
				reg_b<=uio_in;
        end
    end

vedic_8bit_multiplier m1(reg_a, reg_b, W);
reversible_16bit_adder a1 (
    .A(Out),
    .B(W),
    .Cin(1'b0),      // Assuming the adder has a carry-in input
    .Sum(Sum)     // Assuming the adder has a carry-out output
);

always @(negedge clk or negedge rst_n) begin
	     
        if (!rst_n) begin
            Out<=0;
        end else begin
            Out<=Sum;
        end
    end

	 assign {uio_out,uo_out}= Out;
	 
wire _unused = &{ena, 1'b0};
   
endmodule


module BVPPG_gate (
    input  wire A,   
    input  wire B,  
    input  wire C,
	 input  wire D,
	 input  wire E,
    output reg P,
	 output reg Q, 
	 output reg R,
	 output reg S,
	 output reg T
);

wire [1:0]X;

buf b1(P, A);
buf b2(Q, B);
and a1(X[0], A, B);
xor x1(R, X[0], C);
buf b3(S, D);
and a2(X[1], A, D);
xor x3(T, X[1], E);

   
endmodule


module feynman_gate (
    input  wire A,   
    input  wire B,    
    output reg P,
	 output reg Q 
);

buf b1(P, A);
xor x1(Q, A, B);
   
endmodule


module peres_gate (
    input  wire A,   
    input  wire B,  
    input  wire C,   
    output reg P,
	 output reg Q, 
	 output reg R     
);

wire X;

buf b1(P, A);
xor x1(Q, A, B);
and a1(X, A, B);
xor x2(R, X, C);

   
endmodule

module reversible_12bit_adder (
    input  wire [11:0] A,   // 12-bit input A
    input  wire [11:0] B,   // 12-bit input B
    input  wire [11:0] C,   // 12-bit input C
    output      [11:0] Sum  // 12-bit Sum
);

// Intermediate wires for full adders
wire [11:0] sum1, carry1;
wire [2:0] carry2;

// First stage of full adders
reversible_full_adder fa[11:0](A[11:0], B[11:0], C[11:0], 1'b0, sum1[11:0], carry1[11:0]);

assign Sum[0] = sum1[0];


// Second stage of full adders
    reversible_6bit_adder fa13(sum1[6:1], carry1[5:0], 6'b0, Sum[6:1], carry2[0]);
    reversible_6bit_adder fa14({1'b0, sum1[11:7]}, carry1[11:6], {5'b0,carry2[0]}, {carry2[2], Sum[11:7]}, carry2[1]);

    wire _unused = &{carry2[2:1]};
endmodule


module reversible_16bit_adder (
    input  wire [15:0] A,   // 6-bit input A
    input  wire [15:0] B,   // 6-bit input B
    input  wire        Cin,   // 6-bit input C
    output reg [15:0] Sum
);

// Intermediate wires for full adders
    wire [3:0]C;

// First stge of full adders
    reversible_4bit_adder fa[3:0](A[15:0], B[15:0], {C[2:0], Cin}, Sum[15:0], {C[3:0]});

    wire _unused = &{C[3]};
endmodule


module reversible_4bit_adder (
    input  wire [3:0] A,   // 6-bit input A
    input  wire [3:0] B,   // 6-bit input B
    input  wire       Cin,   // 6-bit input C
    output reg [3:0] Sum, // 6-bit Sum
    output reg       Carry // 6-bit Carry
);

// Intermediate wires for full adders
wire [2:0] C;

// Instantiation of reversible full adders
    reversible_full_adder fa0 (A[0], B[0], Cin,  1'b0, Sum[0], C[0]);
    reversible_full_adder fa1 (A[1], B[1], C[0], 1'b0, Sum[1], C[1]);
    reversible_full_adder fa2 (A[2], B[2], C[1], 1'b0, Sum[2], C[2]);
    reversible_full_adder fa3 (A[3], B[3], C[2], 1'b0, Sum[3], Carry);

endmodule



module reversible_6bit_adder (
    input  wire [5:0] A,   // 6-bit input A
    input  wire [5:0] B,   // 6-bit input B
    input  wire [5:0] C,   // 6-bit input C
    output      [5:0] Sum, // 6-bit Sum
    output            Carry
);

// Intermediate wires for full adders
wire [5:0] sum1, carry1;
wire [5:0] carry2;


// First stage of full adders
reversible_full_adder fa0(A[0], B[0], C[0], 1'b0, sum1[0], carry1[0]);
reversible_full_adder fa1(A[1], B[1], C[1], 1'b0, sum1[1], carry1[1]);
reversible_full_adder fa2(A[2], B[2], C[2], 1'b0, sum1[2], carry1[2]);
reversible_full_adder fa3(A[3], B[3], C[3], 1'b0, sum1[3], carry1[3]);
reversible_full_adder fa4(A[4], B[4], C[4], 1'b0, sum1[4], carry1[4]);
reversible_full_adder fa5(A[5], B[5], C[5], 1'b0, sum1[5], carry1[5]);

buf b1(Sum[0], sum1[0]);

// Second stage of full adders
reversible_full_adder fa7(sum1[1], carry1[0], 1'b0, 1'b0, Sum[1], carry2[0]);
reversible_full_adder fa8(sum1[2], carry1[1], carry2[0], 1'b0, Sum[2], carry2[1]);
reversible_full_adder fa9(sum1[3], carry1[2], carry2[1], 1'b0, Sum[3], carry2[2]);
reversible_full_adder fa10(sum1[4], carry1[3], carry2[2], 1'b0, Sum[4], carry2[3]);
reversible_full_adder fa11(sum1[5], carry1[4], carry2[3], 1'b0, Sum[5], carry2[4]);
reversible_full_adder fa12(1'b0, carry1[5], carry2[4], 1'b0,  Carry, carry2[5]);

	wire _unused = &{carry2[5]};
endmodule


// Reversible full adder
module reversible_full_adder (
    input  wire A,     // Input A
    input  wire B,     // Input B
    input  wire Cin,   // Carry-in
	 input  wire Ctrl,
    output reg S,     // Sum
    output reg Cout   // Carry-out
);

wire [1:0]g;
wire [1:0]n;

peres_gate p1(A, B, Ctrl, g[0], n[0], n[1]);
peres_gate p2(n[0], Cin,  n[1], g[1], S, Cout);

wire _unused = &{g[1:0]};


endmodule


module vedic_2bit_multiplier(
    input wire [1:0] A, B,
    output reg [3:0] P
);

	wire [4:0]g;
	wire [3:1]i;
	wire [3:0]a;
	 
	 BVPPG_gate b1(A[0], B[0], 1'b0, B[1], 1'b0, g[0], i[1], P[0], i[2], a[0]);
	 peres_gate p1(A[1], i[1], 1'b0, i[3], g[1], a[1]);
	 peres_gate p2(i[3], i[2], 1'b0, g[2], g[3], a[2]);
	 peres_gate p3(a[0], a[1], 1'b0, g[4], P[1], a[3]);
	 feynman_gate f1(a[3], a[2], P[3], P[2]);

	wire _unused = &{g[4:0]};
	 

endmodule

// 4x4 Vedic Multiplier used for partial products
module vedic_4bit_multiplier (
    input  wire [3:0] A, // 4-bit input A
    input  wire [3:0] B, // 4-bit input B
    output  [7:0] P  // 8-bit output product
);

    // Intermediate partial products
    wire [3:0] P1, P2, P3;
    wire [3:2] P0;
    wire temp;

    // 2x2 Vedic Multipliers for 4x4 multiplication
    vedic_2bit_multiplier U0 (A[1:0], B[1:0], {P0[3:2], P[1:0]});
    vedic_2bit_multiplier U1 (A[1:0], B[3:2], P1[3:0]);
    vedic_2bit_multiplier U2 (A[3:2], B[1:0], P2[3:0]);
    vedic_2bit_multiplier U3 (A[3:2], B[3:2], P3[3:0]);
    
    reversible_6bit_adder a1({P3, P0[3:2]}, {2'b0, P2}, {2'b0, P1}, P[7:2], temp);
    
    wire _unused = &{temp};

endmodule


module vedic_8bit_multiplier (
    input  wire [7:0] A, // 8-bit input A
    input  wire [7:0] B, // 8-bit input B
    output  [15:0] P // 16-bit output product
);

    // Intermediate partial products
	wire [7:0]  P1, P2, P3;
	wire [7:4]  P0;

    // 4x4 multipliers for partial products
    vedic_4bit_multiplier U0 (A[3:0], B[3:0], {P0[7:4], P[3:0]});
    vedic_4bit_multiplier U1 (A[3:0], B[7:4], P1[7:0]);
    vedic_4bit_multiplier U2 (A[7:4], B[3:0], P2[7:0]);
    vedic_4bit_multiplier U3 (A[7:4], B[7:4], P3[7:0]);

	 
	 reversible_12bit_adder a1({P3, P0[7:4]}, {4'b0, P2}, {4'b0, P1}, P[15:4]);

endmodule
