----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:13:32 05/20/2014 
-- Design Name: 
-- Module Name:    IODELAY_EXP - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
Library UNISIM;
use UNISIM.vcomponents.all;
-- IDELAYCTRL : Input Delay Element Control

Library UNISIM;
use UNISIM.vcomponents.all;

entity IODELAY_CTRL is
generic(
		delay_chnl_num : integer := 3
	);
port(
	sys_clk_500M 	: in std_logic;
	sys_clk_200M 	: in std_logic;
	sys_clk_250M 	: in std_logic;

	sys_rst_n 		: in std_logic;
	
	delay_in 	: in std_logic_vector(delay_chnl_num-1 downto 0);
--	Hits_n 		: in std_logic_vector(19 downto 0);
	delay_out_p	: out std_logic_vector(delay_chnl_num-1 downto 0);
	delay_out_n	: out std_logic_vector(delay_chnl_num-1 downto 0);
	
	CNTVALUEIN  : IN std_logic_vector(delay_chnl_num*5-1 downto 0);
	
	CNTVALUEOUT   : OUT std_logic_vector(delay_chnl_num*5-1 downto 0)
);

end IODELAY_CTRL;

architecture Behavioral of IODELAY_CTRL is
	
	signal rst_in : std_logic;
	signal RDY : std_logic;
	signal DATAOUT : std_logic;
	signal DATAOUT_and : std_logic;

begin
------------------------------------------------------------
------apply IDELAYCTRL, data sheet require This design element 
------must be instantiated when using the IODELAYE1 in virtex 6
------but when using two IODELAYE1, this will be an error occur
------------------------------------------------------------
IDELAYCTRL_inst : IDELAYCTRL
port map (
RDY => RDY,
-- 1-bit output indicates validity of the REFCLK
REFCLK => sys_clk_200M, -- 1-bit reference clock input
RST => rst_in
-- 1-bit reset input
);
rst_in	<= not sys_rst_n;
------------------------------------------------------------
------apply IO delay 1
------------------------------------------------------------
IODELAYE1_inst_1 : IODELAYE1
generic map (
	CINVCTRL_SEL => FALSE,
	-- Enable dynamic clock inversion ("TRUE"/"FALSE")
	DELAY_SRC => "DATAIN",--O Data input for IODELAYE1 from the OSERDES/OLOGIC
	-- Delay input ("I", "CLKIN", "DATAIN", "IO", "O")
	HIGH_PERFORMANCE_MODE => TRUE, -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
	IDELAY_TYPE => "VAR_LOADABLE",
	-- "DEFAULT", "FIXED", "VARIABLE", or "VAR_LOADABLE"
	--IDELAY_VALUE => 3,
	-- Input delay tap setting (0-32)
	--ODELAY_TYPE => "FIXED",
	-- "FIXED", "VARIABLE", or "VAR_LOADABLE"
	--ODELAY_VALUE => 0,
	-- Output delay tap setting (0-32)
	REFCLK_FREQUENCY => 200.0,
	-- IDELAYCTRL clock input frequency in MHz
	SIGNAL_PATTERN => "DATA"
	-- "DATA" or "CLOCK" input signal
)
port map (
	CNTVALUEOUT => CNTVALUEOUT, -- 5-bit output - Counter value for monitoring purpose
	DATAOUT => DATAOUT,
	-- 1-bit output - Delayed data output
	C =>  sys_clk_250M,
	-- 1-bit input - Clock input
	CE => '0',
	-- 1-bit input - Active high enable increment/decrement function
	CINVCTRL => '0',
	-- 1-bit input - Dynamically inverts the Clock (C) polarity
	CLKIN => '0',
	-- 1-bit input - Clock Access into the IODELAY
	CNTVALUEIN => CNTVALUEIN,
	-- 5-bit input - Counter value for loadable counter application
	DATAIN => delay_in,
	-- 1-bit input - Internal delay data Data input for IODELAYE1 from the FPGA logic
	IDATAIN => '0',--clk_in,
	-- 1-bit input - Delay data input Data input for IODELAYE1 from the IOB
	INC => '0',
	-- 1-bit input - Increment / Decrement tap delay
	ODATAIN => '0',
	-- 1-bit input - Data input for the output datapath from the device Data input for IODELAYE1 from the OSERDES/OLOGIC
	RST => rst_in,
	-- 1-bit input - Active high, synchronous reset, resets delay chain to IDELAY_VALUE/
	-- ODELAY_VALUE tap. If no value is specified, the default is 0.
	T => '0'
	-- 1-bit input - 3-state input control. Tie high for input-only or internal delay or
	-- tie low for output only.
);

process(DATAOUT, sys_clk_500M,DATAOUT_and)
begin
	DATAOUT_and	<= DATAOUT and sys_clk_500M;
end process;

OBUFDS_inst : OBUFDS
   generic map (
      IOSTANDARD => "DEFAULT")
   port map (
      O => delay_out_p,     -- Diff_p output (connect directly to top-level port)
      OB => delay_out_n,   -- Diff_n output (connect directly to top-level port)
      I => DATAOUT_and      -- Buffer input 
   );

end Behavioral;

