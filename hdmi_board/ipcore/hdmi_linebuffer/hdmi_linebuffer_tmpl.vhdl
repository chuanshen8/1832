-- Created by IP Generator (Version 2022.1 build 99559)
-- Instantiation Template
--
-- Insert the following codes into your VHDL file.
--   * Change the_instance_name to your own instance name.
--   * Change the net names in the port map.


COMPONENT hdmi_linebuffer
  PORT (
    wr_data : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    wr_addr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    wr_rst : IN STD_LOGIC;
    rd_addr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    rd_data : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
    rd_clk : IN STD_LOGIC;
    rd_rst : IN STD_LOGIC
  );
END COMPONENT;


the_instance_name : hdmi_linebuffer
  PORT MAP (
    wr_data => wr_data,
    wr_addr => wr_addr,
    wr_en => wr_en,
    wr_clk => wr_clk,
    wr_rst => wr_rst,
    rd_addr => rd_addr,
    rd_data => rd_data,
    rd_clk => rd_clk,
    rd_rst => rd_rst
  );
