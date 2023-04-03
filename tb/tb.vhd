library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb is
end tb;

architecture behavioral of tb is

file fid_stim1 : text open read_mode is "ar0231_macbeth_demosaic_only_small.dat";
file fid_stim2 : text open read_mode is "ar0231_rgb_cereal_small.dat";

constant CLK_PER : time := 10 ns;

signal clk : std_logic := '0';
signal rst : std_logic := '1';
signal c00 : std_logic_vector (7 downto 0) := (others => '0');
signal c01 : std_logic_vector (7 downto 0) := (others => '0');
signal c02 : std_logic_vector (7 downto 0) := (others => '0');
signal c10 : std_logic_vector (7 downto 0) := (others => '0');
signal c11 : std_logic_vector (7 downto 0) := (others => '0');
signal c12 : std_logic_vector (7 downto 0) := (others => '0');
signal c20 : std_logic_vector (7 downto 0) := (others => '0');
signal c21 : std_logic_vector (7 downto 0) := (others => '0');
signal c22 : std_logic_vector (7 downto 0) := (others => '0');
signal hblank_in : std_logic := '0';
signal vblank_in : std_logic := '0';
signal din : std_logic_vector(23 downto 0) := (others => '0');
signal hblank_out : std_logic := '0';
signal vblank_out : std_logic := '0';
signal dout : std_logic_vector(23 downto 0);

signal din_r : std_logic_vector(7 downto 0) := (others => '0');
signal din_g : std_logic_vector(7 downto 0) := (others => '0');
signal din_b : std_logic_vector(7 downto 0) := (others => '0');

begin

	c00 <= std_logic_vector(to_signed(569,  c00'length));
	c01 <= std_logic_vector(to_signed(-24,  c01'length));
	c02 <= std_logic_vector(to_signed(41,   c02'length));
	c10 <= std_logic_vector(to_signed(-204, c10'length));
	c11 <= std_logic_vector(to_signed(503,  c11'length));
	c12 <= std_logic_vector(to_signed(61,   c12'length));
	c20 <= std_logic_vector(to_signed(102,  c20'length));
	c21 <= std_logic_vector(to_signed(-270, c21'length));
	c22 <= std_logic_vector(to_signed(345,  c22'length));
	din <= din_b & din_g & din_r;

	-- Instantiate UUT
	uut : entity work.ccm
	port map
	(
		clk => clk,
		rst => rst,
		
		c00 => c00,
		c01 => c01,
		c02 => c02,
		c10 => c10,
		c11 => c11,
		c12 => c12,
		c20 => c20,
		c21 => c21,
		c22 => c22,
		
		hblank_in => hblank_in,
		vblank_in => hblank_in,
		din => din,
		
		hblank_out => hblank_out,
		vblank_out => vblank_out,
		dout => dout
	);
	
	-- Generate clock
	clk <= not clk after CLK_PER/2;
	
	-- Read test vector from file
	main : process
        variable text_line : line;
        variable ok : boolean;
        variable text_vblank : vblank_in'subtype;
        variable text_hblank : hblank_in'subtype;
        variable text_r : din_r'subtype;
        variable text_g : din_g'subtype;
        variable text_b : din_b'subtype;
	begin
		wait for 100 ns; -- GSR
		wait for CLK_PER*10; -- Reset period
		rst <= '0';
		
		while not endfile(fid_stim1) loop
			readline(fid_stim1, text_line);
			
			read(text_line, text_vblank, ok);
			read(text_line, text_hblank, ok);
			read(text_line, text_b, ok);
			read(text_line, text_g, ok);
			read(text_line, text_r, ok);
			
			vblank_in <= text_vblank;
			hblank_in <= text_hblank;
			din_r <= text_r;
			din_g <= text_g;
			din_b <= text_b;
		end loop;
		
		
		
	end process;
	
	
	
end behavioral;