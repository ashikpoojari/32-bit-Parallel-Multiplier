// Multiplier 32x32 Paralle pipeline
//          7 Series
// Xilinx HDL Libraries Guide, version 14.7

module mult35x35_parallel_pipe (CLK, RST, A_IN, B_IN, PROD_OUT);

input           CLK, RST;
input   [34:0]  A_IN, B_IN;
output  [69:0]  PROD_OUT;


wire    [17:0]  BCOUT_1, BCOUT_3;
wire    [47:0]  PCOUT_1, PCOUT_2, PCOUT_3;
wire    [47:0]  POUT_1, POUT_3, POUT_4;
reg     [16:0]  POUT_1_REG1, POUT_1_REG2, POUT_1_REG3, POUT_3_REG1;

reg     [16:0]  A_IN_3_REG1;
reg     [17:0]  A_IN_4_REG1, A_IN_4_REG2, B_IN_3_REG1;
wire    [34:0]  A_IN_WIRE, B_IN_WIRE;
//
// Product[16:0] Instantiation block 1
//

assign A_IN_WIRE = A_IN;
assign B_IN_WIRE = B_IN;

//
// Instantiation block 1
//

DSP48E1 #(
   // Feature Control Attributes: Data Path Selection
   .A_INPUT("DIRECT"),               // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
   .B_INPUT("DIRECT"),               // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
   .USE_DPORT("FALSE"),              // Select D port usage (TRUE or FALSE)
   .USE_MULT("MULTIPLY"),            // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
   .USE_SIMD("ONE48"),               // SIMD selection ("ONE48", "TWO24", "FOUR12")
   // Pattern Detector Attributes: Pattern Detection Configuration
   .AUTORESET_PATDET("NO_RESET"),    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
   .MASK(48'h3fffffffffff),          // 48-bit mask value for pattern detect (1=ignore)
   .PATTERN(48'h000000000000),       // 48-bit pattern match for pattern detect
   .SEL_MASK("MASK"),                // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
   .SEL_PATTERN("PATTERN"),          // Select pattern value ("PATTERN" or "C")
   .USE_PATTERN_DETECT("NO_PATDET"), // Enable pattern detect ("PATDET" or "NO_PATDET")
   // Register Control Attributes: Pipeline Register Configuration
   .ACASCREG(1),                     // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
   .ADREG(1),                        // Number of pipeline stages for pre-adder (0 or 1)
   .ALUMODEREG(1),                   // Number of pipeline stages for ALUMODE (0 or 1)
   .AREG(1),                         // Number of pipeline stages for A (0, 1 or 2)
   .BCASCREG(1),                     // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
   .BREG(1),                         // Number of pipeline stages for B (0, 1 or 2)
   .CARRYINREG(0),                   // Number of pipeline stages for CARRYIN (0 or 1)
   .CARRYINSELREG(0),                // Number of pipeline stages for CARRYINSEL (0 or 1)
   .CREG(0),                         // Number of pipeline stages for C (0 or 1)
   .DREG(0),                         // Number of pipeline stages for D (0 or 1)
   .INMODEREG(1),                    // Number of pipeline stages for INMODE (0 or 1)
   .MREG(1),                         // Number of multiplier pipeline stages (0 or 1)
   .OPMODEREG(0),                    // Number of pipeline stages for OPMODE (0 or 1)
   .PREG(1)                          // Number of pipeline stages for P (0 or 1)
)

DSP48E1_1 (
   // Cascade: 30-bit (each) output: Cascade Ports
   .ACOUT(),                     // 30-bit output: A port cascade output
   .BCOUT(BCOUT_1),                   // 18-bit output: B port cascade output
   .CARRYCASCOUT(),                   // 1-bit output: Cascade carry output
   .MULTSIGNOUT(),                    // 1-bit output: Multiplier sign cascade output
   .PCOUT(PCOUT_1),                    // 48-bit output: Cascade output
   // Control: 1-bit (each) output: Control Inputs/Status Bits
   .OVERFLOW(),                       // 1-bit output: Overflow in add/acc output
   .PATTERNBDETECT(),                 // 1-bit output: Pattern bar detect output
   .PATTERNDETECT(),                  // 1-bit output: Pattern detect output
   .UNDERFLOW(),           // 1-bit output: Underflow in add/acc output
   // Data: 4-bit (each) output: Data Ports
   .CARRYOUT(),             // 4-bit output: Carry output
   .P(POUT_1),                           // 48-bit output: Primary data output
   // Cascade: 30-bit (each) input: Cascade Ports
   .ACIN(30'b0),                     // 30-bit input: A cascade data input
   .BCIN(18'b0),                     // 18-bit input: B cascade input
   .CARRYCASCIN(1'b0),       // 1-bit input: Cascade carry input
   .MULTSIGNIN(),         // 1-bit input: Multiplier sign input
   .PCIN(48'b0),                     // 48-bit input: P cascade input
   // Control: 4-bit (each) input: Control Inputs/Status Bits
   .ALUMODE(4'b0000),               // 4-bit input: ALU control input
   .CARRYINSEL(3'b0),         // 3-bit input: Carry select input
   .CLK(CLK),                       // 1-bit input: Clock input
   .INMODE(5'b00000),                 // 5-bit input: INMODE control input
   .OPMODE(7'b0000101),                 // 7-bit input: Operation mode input
   // Data: 30-bit (each) input: Data Ports
   .A({13'b0,A_IN_WIRE[16:0]}),                           // 30-bit input: A data input
   .B({1'b0,B_IN_WIRE[16:0]}),                           // 18-bit input: B data input
   .C(48'b0),                           // 48-bit input: C data input
   .CARRYIN(1'b0),               // 1-bit input: Carry input signal
   .D(25'b0),                           // 25-bit input: D data input
   // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
   .CEA1(1'b0),                     // 1-bit input: Clock enable input for 1st stage AREG
   .CEA2(1'b1),                     // 1-bit input: Clock enable input for 2nd stage AREG
   .CEAD(1'b0),                     // 1-bit input: Clock enable input for ADREG
   .CEALUMODE(1'b1),           // 1-bit input: Clock enable input for ALUMODE
   .CEB1(1'b1),                     // 1-bit input: Clock enable input for 1st stage BREG
   .CEB2(1'b1),                     // 1-bit input: Clock enable input for 2nd stage BREG
   .CEC(1'b0),                       // 1-bit input: Clock enable input for CREG
   .CECARRYIN(1'b0),           // 1-bit input: Clock enable input for CARRYINREG
   .CECTRL(1'b1),                 // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
   .CED(1'b0),                       // 1-bit input: Clock enable input for DREG
   .CEINMODE(1'b1),             // 1-bit input: Clock enable input for INMODEREG
   .CEM(1'b1),                       // 1-bit input: Clock enable input for MREG
   .CEP(1'b1),                       // 1-bit input: Clock enable input for PREG
   .RSTA(RST),                     // 1-bit input: Reset input for AREG
   .RSTALLCARRYIN(RST),   // 1-bit input: Reset input for CARRYINREG
   .RSTALUMODE(RST),         // 1-bit input: Reset input for ALUMODEREG
   .RSTB(RST),                     // 1-bit input: Reset input for BREG
   .RSTC(RST),                     // 1-bit input: Reset input for CREG
   .RSTCTRL(RST),               // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
   .RSTD(RST),                     // 1-bit input: Reset input for DREG and ADREG
   .RSTINMODE(RST),           // 1-bit input: Reset input for INMODEREG
   .RSTM(RST),                     // 1-bit input: Reset input for MREG
   .RSTP(RST)                      // 1-bit input: Reset input for PREG
);

// End of DSP48E1_1 instantiation

//synthesis translate_on

always @ (posedge CLK or posedge RST)
   begin
   if (RST)
       begin POUT_1_REG1 <= 17'b0;
             POUT_1_REG2 <= 17'b0;
             POUT_1_REG3 <= 17'b0; end

   else
       begin POUT_1_REG1 <= POUT_1[16:0];
             POUT_1_REG2 <= POUT_1_REG1;
             POUT_1_REG3 <= POUT_1_REG2; end

   end

assign PROD_OUT[16:0] = POUT_1_REG3;

//
// Instantiation block 2
//

DSP48E1 #(
   // Feature Control Attributes: Data Path Selection
   .A_INPUT("DIRECT"),               // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
   .B_INPUT("CASCADE"),               // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
   .USE_DPORT("FALSE"),              // Select D port usage (TRUE or FALSE)
   .USE_MULT("MULTIPLY"),            // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
   .USE_SIMD("ONE48"),               // SIMD selection ("ONE48", "TWO24", "FOUR12")
   // Pattern Detector Attributes: Pattern Detection Configuration
   .AUTORESET_PATDET("NO_RESET"),    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
   .MASK(48'h3fffffffffff),          // 48-bit mask value for pattern detect (1=ignore)
   .PATTERN(48'h000000000000),       // 48-bit pattern match for pattern detect
   .SEL_MASK("MASK"),                // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
   .SEL_PATTERN("PATTERN"),          // Select pattern value ("PATTERN" or "C")
   .USE_PATTERN_DETECT("NO_PATDET"), // Enable pattern detect ("PATDET" or "NO_PATDET")
   // Register Control Attributes: Pipeline Register Configuration
   .ACASCREG(1),                     // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
   .ADREG(1),                        // Number of pipeline stages for pre-adder (0 or 1)
   .ALUMODEREG(1),                   // Number of pipeline stages for ALUMODE (0 or 1)
   .AREG(2),                         // Number of pipeline stages for A (0, 1 or 2)
   .BCASCREG(1),                     // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
   .BREG(1),                         // Number of pipeline stages for B (0, 1 or 2)
   .CARRYINREG(0),                   // Number of pipeline stages for CARRYIN (0 or 1)
   .CARRYINSELREG(1),                // Number of pipeline stages for CARRYINSEL (0 or 1)
   .CREG(1),                         // Number of pipeline stages for C (0 or 1)
   .DREG(1),                         // Number of pipeline stages for D (0 or 1)
   .INMODEREG(1),                    // Number of pipeline stages for INMODE (0 or 1)
   .MREG(1),                         // Number of multiplier pipeline stages (0 or 1)
   .OPMODEREG(0),                    // Number of pipeline stages for OPMODE (0 or 1)
   .PREG(1)                          // Number of pipeline stages for P (0 or 1)
)

DSP48E1_2 (
   // Cascade: 30-bit (each) output: Cascade Ports
   .ACOUT(),                     // 30-bit output: A port cascade output
   .BCOUT(),                   // 18-bit output: B port cascade output
   .CARRYCASCOUT(),                   // 1-bit output: Cascade carry output
   .MULTSIGNOUT(),                    // 1-bit output: Multiplier sign cascade output
   .PCOUT(PCOUT_2),                    // 48-bit output: Cascade output
   // Control: 1-bit (each) output: Control Inputs/Status Bits
   .OVERFLOW(),                       // 1-bit output: Overflow in add/acc output
   .PATTERNBDETECT(),                 // 1-bit output: Pattern bar detect output
   .PATTERNDETECT(),                  // 1-bit output: Pattern detect output
   .UNDERFLOW(),           // 1-bit output: Underflow in add/acc output
   // Data: 4-bit (each) output: Data Ports
   .CARRYOUT(),             // 4-bit output: Carry output
   .P(),                           // 48-bit output: Primary data output
   // Cascade: 30-bit (each) input: Cascade Ports
   .ACIN(30'b0),                     // 30-bit input: A cascade data input
   .BCIN(BCOUT_1),                     // 18-bit input: B cascade input
   .CARRYCASCIN(1'b0),       // 1-bit input: Cascade carry input
   .MULTSIGNIN(),         // 1-bit input: Multiplier sign input
   .PCIN(PCOUT_1),                     // 48-bit input: P cascade input
   // Control: 4-bit (each) input: Control Inputs/Status Bits
   .ALUMODE(4'b0000),               // 4-bit input: ALU control input
   .CARRYINSEL(3'b0),         // 3-bit input: Carry select input
   .CLK(CLK),                       // 1-bit input: Clock input
   .INMODE(5'b00000),                 // 5-bit input: INMODE control input
   .OPMODE(7'b1010101),                 // 7-bit input: Operation mode input
   // Data: 30-bit (each) input: Data Ports
   .A({12'b0,A_IN[34:17]}),                           // 30-bit input: A data input
   .B(18'b0),                           // 18-bit input: B data input
   .C(48'b0),                           // 48-bit input: C data input
   .CARRYIN(1'b0),               // 1-bit input: Carry input signal
   .D(25'b0),                           // 25-bit input: D data input
   // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
   .CEA1(1'b1),                     // 1-bit input: Clock enable input for 1st stage AREG
   .CEA2(1'b1),                     // 1-bit input: Clock enable input for 2nd stage AREG
   .CEAD(1'b0),                     // 1-bit input: Clock enable input for ADREG
   .CEALUMODE(1'b1),           // 1-bit input: Clock enable input for ALUMODE
   .CEB1(1'b0),                     // 1-bit input: Clock enable input for 1st stage BREG
   .CEB2(1'b1),                     // 1-bit input: Clock enable input for 2nd stage BREG
   .CEC(1'b0),                       // 1-bit input: Clock enable input for CREG
   .CECARRYIN(1'b0),           // 1-bit input: Clock enable input for CARRYINREG
   .CECTRL(1'b1),                 // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
   .CED(1'b0),                       // 1-bit input: Clock enable input for DREG
   .CEINMODE(1'b1),             // 1-bit input: Clock enable input for INMODEREG
   .CEM(1'b1),                       // 1-bit input: Clock enable input for MREG
   .CEP(1'b1),                       // 1-bit input: Clock enable input for PREG
   .RSTA(RST),                     // 1-bit input: Reset input for AREG
   .RSTALLCARRYIN(RST),   // 1-bit input: Reset input for CARRYINREG
   .RSTALUMODE(RST),         // 1-bit input: Reset input for ALUMODEREG
   .RSTB(RST),                     // 1-bit input: Reset input for BREG
   .RSTC(RST),                     // 1-bit input: Reset input for CREG
   .RSTCTRL(RST),               // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
   .RSTD(RST),                     // 1-bit input: Reset input for DREG and ADREG
   .RSTINMODE(RST),           // 1-bit input: Reset input for INMODEREG
   .RSTM(RST),                     // 1-bit input: Reset input for MREG
   .RSTP(RST)                      // 1-bit input: Reset input for PREG
);

// End of DSP48E1_2 instantiation

//
// Product[33:17] Instantiation block 3
//


always @ (posedge CLK or posedge RST)
   begin
   if (RST)
       begin A_IN_3_REG1 <= 17'b0;
             B_IN_3_REG1 <= 17'b0; end
   else
       begin A_IN_3_REG1 <= (A_IN_WIRE[16:0]);
             B_IN_3_REG1 <= B_IN_WIRE[34:17]; end
   end

//
// Instantiation block 3
//

   DSP48E1 #(
      // Feature Control Attributes: Data Path Selection
      .A_INPUT("DIRECT"),               // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
      .B_INPUT("DIRECT"),               // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
      .USE_DPORT("FALSE"),              // Select D port usage (TRUE or FALSE)
      .USE_MULT("MULTIPLY"),            // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
      .USE_SIMD("ONE48"),               // SIMD selection ("ONE48", "TWO24", "FOUR12")
      // Pattern Detector Attributes: Pattern Detection Configuration
      .AUTORESET_PATDET("NO_RESET"),    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
      .MASK(48'h3fffffffffff),          // 48-bit mask value for pattern detect (1=ignore)
      .PATTERN(48'h000000000000),       // 48-bit pattern match for pattern detect
      .SEL_MASK("MASK"),                // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
      .SEL_PATTERN("PATTERN"),          // Select pattern value ("PATTERN" or "C")
      .USE_PATTERN_DETECT("NO_PATDET"), // Enable pattern detect ("PATDET" or "NO_PATDET")
      // Register Control Attributes: Pipeline Register Configuration
      .ACASCREG(1),                     // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
      .ADREG(1),                        // Number of pipeline stages for pre-adder (0 or 1)
      .ALUMODEREG(1),                   // Number of pipeline stages for ALUMODE (0 or 1)
      .AREG(2),                         // Number of pipeline stages for A (0, 1 or 2)
      .BCASCREG(1),                     // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
      .BREG(2),                         // Number of pipeline stages for B (0, 1 or 2)
      .CARRYINREG(0),                   // Number of pipeline stages for CARRYIN (0 or 1)
      .CARRYINSELREG(0),                // Number of pipeline stages for CARRYINSEL (0 or 1)
      .CREG(0),                         // Number of pipeline stages for C (0 or 1)
      .DREG(0),                         // Number of pipeline stages for D (0 or 1)
      .INMODEREG(1),                    // Number of pipeline stages for INMODE (0 or 1)
      .MREG(1),                         // Number of multiplier pipeline stages (0 or 1)
      .OPMODEREG(0),                    // Number of pipeline stages for OPMODE (0 or 1)
      .PREG(1)                          // Number of pipeline stages for P (0 or 1)
   )

   DSP48E1_3 (
      // Cascade: 30-bit (each) output: Cascade Ports
      .ACOUT(),                     // 30-bit output: A port cascade output
      .BCOUT(BCOUT_3),                   // 18-bit output: B port cascade output
      .CARRYCASCOUT(),                   // 1-bit output: Cascade carry output
      .MULTSIGNOUT(),                    // 1-bit output: Multiplier sign cascade output
      .PCOUT(PCOUT_3),                    // 48-bit output: Cascade output
      // Control: 1-bit (each) output: Control Inputs/Status Bits
      .OVERFLOW(),                       // 1-bit output: Overflow in add/acc output
      .PATTERNBDETECT(),                 // 1-bit output: Pattern bar detect output
      .PATTERNDETECT(),                  // 1-bit output: Pattern detect output
      .UNDERFLOW(),           // 1-bit output: Underflow in add/acc output
      // Data: 4-bit (each) output: Data Ports
      .CARRYOUT(),             // 4-bit output: Carry output
      .P(POUT_3),                           // 48-bit output: Primary data output
      // Cascade: 30-bit (each) input: Cascade Ports
      .ACIN(30'b0),                     // 30-bit input: A cascade data input
      .BCIN(18'b0),                     // 18-bit input: B cascade input
      .CARRYCASCIN(),       // 1-bit input: Cascade carry input
      .MULTSIGNIN(),         // 1-bit input: Multiplier sign input
      .PCIN(PCOUT_2),                     // 48-bit input: P cascade input
      // Control: 4-bit (each) input: Control Inputs/Status Bits
      .ALUMODE(4'b0000),               // 4-bit input: ALU control input
      .CARRYINSEL(3'b0),         // 3-bit input: Carry select input
      .CLK(CLK),                       // 1-bit input: Clock input
      .INMODE(5'b00000),                 // 5-bit input: INMODE control input
      .OPMODE(7'b0010101),                 // 7-bit input: Operation mode input
      // Data: 30-bit (each) input: Data Ports
      .A({13'b0,A_IN_3_REG1}),                           // 30-bit input: A data input
      .B(B_IN_3_REG1),                           // 18-bit input: B data input
      .C(48'b0),                           // 48-bit input: C data input
      .CARRYIN(1'b0),               // 1-bit input: Carry input signal
      .D(25'b0),                           // 25-bit input: D data input
      // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
      .CEA1(1'b1),                     // 1-bit input: Clock enable input for 1st stage AREG
      .CEA2(1'b1),                     // 1-bit input: Clock enable input for 2nd stage AREG
      .CEAD(1'b0),                     // 1-bit input: Clock enable input for ADREG
      .CEALUMODE(1'b1),           // 1-bit input: Clock enable input for ALUMODE
      .CEB1(1'b1),                     // 1-bit input: Clock enable input for 1st stage BREG
      .CEB2(1'b1),                     // 1-bit input: Clock enable input for 2nd stage BREG
      .CEC(1'b0),                       // 1-bit input: Clock enable input for CREG
      .CECARRYIN(1'b0),           // 1-bit input: Clock enable input for CARRYINREG
      .CECTRL(1'b1),                 // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
      .CED(1'b0),                       // 1-bit input: Clock enable input for DREG
      .CEINMODE(1'b1),             // 1-bit input: Clock enable input for INMODEREG
      .CEM(1'b1),                       // 1-bit input: Clock enable input for MREG
      .CEP(1'b1),                       // 1-bit input: Clock enable input for PREG
      .RSTA(RST),                     // 1-bit input: Reset input for AREG
      .RSTALLCARRYIN(RST),   // 1-bit input: Reset input for CARRYINREG
      .RSTALUMODE(RST),         // 1-bit input: Reset input for ALUMODEREG
      .RSTB(RST),                     // 1-bit input: Reset input for BREG
      .RSTC(RST),                     // 1-bit input: Reset input for CREG
      .RSTCTRL(RST),               // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
      .RSTD(RST),                     // 1-bit input: Reset input for DREG and ADREG
      .RSTINMODE(RST),           // 1-bit input: Reset input for INMODEREG
      .RSTM(RST),                     // 1-bit input: Reset input for MREG
      .RSTP(RST)                      // 1-bit input: Reset input for PREG
   );

   // End of DSP48E1_3 instantiation

   always @ (posedge CLK or posedge RST)
      begin
      if (RST)
          begin POUT_3_REG1 <= 17'b0; end
      else
          begin POUT_3_REG1 <= POUT_3[16:0]; end
      end

   assign PROD_OUT[33:17] = POUT_3_REG1;

   //
   // Product[69:34] Instantiation block 4
   //

   always @ (posedge CLK or posedge RST)
      begin
      if (RST)
          begin A_IN_4_REG1 <= 17'b0;
                A_IN_4_REG2 <= 17'b0; end

      else
          begin A_IN_4_REG1 <= A_IN[34:17];
                A_IN_4_REG2 <= A_IN_4_REG1; end
      end

   //
   // Instantiation block 4
   //
   DSP48E1 #(
      // Feature Control Attributes: Data Path Selection
      .A_INPUT("DIRECT"),               // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
      .B_INPUT("CASCADE"),               // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
      .USE_DPORT("FALSE"),              // Select D port usage (TRUE or FALSE)
      .USE_MULT("MULTIPLY"),            // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
      .USE_SIMD("ONE48"),               // SIMD selection ("ONE48", "TWO24", "FOUR12")
      // Pattern Detector Attributes: Pattern Detection Configuration
      .AUTORESET_PATDET("NO_RESET"),    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
      .MASK(48'h3fffffffffff),          // 48-bit mask value for pattern detect (1=ignore)
      .PATTERN(48'h000000000000),       // 48-bit pattern match for pattern detect
      .SEL_MASK("MASK"),                // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
      .SEL_PATTERN("PATTERN"),          // Select pattern value ("PATTERN" or "C")
      .USE_PATTERN_DETECT("NO_PATDET"), // Enable pattern detect ("PATDET" or "NO_PATDET")
      // Register Control Attributes: Pipeline Register Configuration
      .ACASCREG(1),                     // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
      .ADREG(1),                        // Number of pipeline stages for pre-adder (0 or 1)
      .ALUMODEREG(1),                   // Number of pipeline stages for ALUMODE (0 or 1)
      .AREG(2),                         // Number of pipeline stages for A (0, 1 or 2)
      .BCASCREG(1),                     // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
      .BREG(2),                         // Number of pipeline stages for B (0, 1 or 2)
      .CARRYINREG(0),                   // Number of pipeline stages for CARRYIN (0 or 1)
      .CARRYINSELREG(0),                // Number of pipeline stages for CARRYINSEL (0 or 1)
      .CREG(0),                         // Number of pipeline stages for C (0 or 1)
      .DREG(0),                         // Number of pipeline stages for D (0 or 1)
      .INMODEREG(1),                    // Number of pipeline stages for INMODE (0 or 1)
      .MREG(1),                         // Number of multiplier pipeline stages (0 or 1)
      .OPMODEREG(0),                    // Number of pipeline stages for OPMODE (0 or 1)
      .PREG(1)                          // Number of pipeline stages for P (0 or 1)
   )

   DSP48E1_4 (
      // Cascade: 30-bit (each) output: Cascade Ports
      .ACOUT(),                     // 30-bit output: A port cascade output
      .BCOUT(),                   // 18-bit output: B port cascade output
      .CARRYCASCOUT(),                   // 1-bit output: Cascade carry output
      .MULTSIGNOUT(),                    // 1-bit output: Multiplier sign cascade output
      .PCOUT(),                    // 48-bit output: Cascade output
      // Control: 1-bit (each) output: Control Inputs/Status Bits
      .OVERFLOW(),                       // 1-bit output: Overflow in add/acc output
      .PATTERNBDETECT(),                 // 1-bit output: Pattern bar detect output
      .PATTERNDETECT(),                  // 1-bit output: Pattern detect output
      .UNDERFLOW(),           // 1-bit output: Underflow in add/acc output
      // Data: 4-bit (each) output: Data Ports
      .CARRYOUT(),             // 4-bit output: Carry output
      .P(POUT_4),                           // 48-bit output: Primary data output
      // Cascade: 30-bit (each) input: Cascade Ports
      .ACIN(30'b0),                     // 30-bit input: A cascade data input
      .BCIN(BCOUT_3),                     // 18-bit input: B cascade input
      .CARRYCASCIN(),       // 1-bit input: Cascade carry input
      .MULTSIGNIN(),         // 1-bit input: Multiplier sign input
      .PCIN(PCOUT_3),                     // 48-bit input: P cascade input
      // Control: 4-bit (each) input: Control Inputs/Status Bits
      .ALUMODE(4'b0000),               // 4-bit input: ALU control input
      .CARRYINSEL(3'b0),         // 3-bit input: Carry select input
      .CLK(CLK),                       // 1-bit input: Clock input
      .INMODE(5'b00000),                 // 5-bit input: INMODE control input
      .OPMODE(7'b1010101),                 // 7-bit input: Operation mode input
      // Data: 30-bit (each) input: Data Ports
      .A({12'b0,A_IN_4_REG2}),                           // 30-bit input: A data input
      .B(18'b0),                           // 18-bit input: B data input
      .C(48'b0),                           // 48-bit input: C data input
      .CARRYIN(1'b0),               // 1-bit input: Carry input signal
      .D(25'b0),                           // 25-bit input: D data input
      // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
      .CEA1(1'b1),                     // 1-bit input: Clock enable input for 1st stage AREG
      .CEA2(1'b1),                     // 1-bit input: Clock enable input for 2nd stage AREG
      .CEAD(1'b0),                     // 1-bit input: Clock enable input for ADREG
      .CEALUMODE(1'b1),           // 1-bit input: Clock enable input for ALUMODE
      .CEB1(1'b1),                     // 1-bit input: Clock enable input for 1st stage BREG
      .CEB2(1'b1),                     // 1-bit input: Clock enable input for 2nd stage BREG
      .CEC(1'b0),                       // 1-bit input: Clock enable input for CREG
      .CECARRYIN(1'b0),           // 1-bit input: Clock enable input for CARRYINREG
      .CECTRL(1'b1),                 // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
      .CED(1'b0),                       // 1-bit input: Clock enable input for DREG
      .CEINMODE(1'b1),             // 1-bit input: Clock enable input for INMODEREG
      .CEM(1'b1),                       // 1-bit input: Clock enable input for MREG
      .CEP(1'b1),                       // 1-bit input: Clock enable input for PREG
      .RSTA(RST),                     // 1-bit input: Reset input for AREG
      .RSTALLCARRYIN(RST),   // 1-bit input: Reset input for CARRYINREG
      .RSTALUMODE(RST),         // 1-bit input: Reset input for ALUMODEREG
      .RSTB(RST),                     // 1-bit input: Reset input for BREG
      .RSTC(RST),                     // 1-bit input: Reset input for CREG
      .RSTCTRL(RST),               // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
      .RSTD(RST),                     // 1-bit input: Reset input for DREG and ADREG
      .RSTINMODE(RST),           // 1-bit input: Reset input for INMODEREG
      .RSTM(RST),                     // 1-bit input: Reset input for MREG
      .RSTP(RST)                      // 1-bit input: Reset input for PREG
   );

   // End of DSP48E1_4 instantiation

   assign PROD_OUT[69:34] = POUT_4[35:0];
   endmodule
