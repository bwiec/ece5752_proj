library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use std.env.all;

entity tb is
end tb;

architecture behavioral of tb is

constant fname_stim1 : string := "ar0231_macbeth_demosaic_only_small.dat";
constant fname_stim2 : string := "ar0231_rgb_cereal_small.dat";

constant CLK_PER : time := 10 ns;

signal clk : std_logic := '0';
signal rst : std_logic := '1';
signal c00 : std_logic_vector (15 downto 0) := (others => '0');
signal c01 : std_logic_vector (15 downto 0) := (others => '0');
signal c02 : std_logic_vector (15 downto 0) := (others => '0');
signal c10 : std_logic_vector (15 downto 0) := (others => '0');
signal c11 : std_logic_vector (15 downto 0) := (others => '0');
signal c12 : std_logic_vector (15 downto 0) := (others => '0');
signal c20 : std_logic_vector (15 downto 0) := (others => '0');
signal c21 : std_logic_vector (15 downto 0) := (others => '0');
signal c22 : std_logic_vector (15 downto 0) := (others => '0');
signal hblank_in : std_logic := '0';
signal vblank_in : std_logic := '0';
signal din : std_logic_vector(23 downto 0) := (others => '0');
signal hblank_out : std_logic := '0';
signal vblank_out : std_logic := '0';
signal dout : std_logic_vector(23 downto 0);

signal din_r : std_logic_vector(7 downto 0) := (others => '0');
signal din_g : std_logic_vector(7 downto 0) := (others => '0');
signal din_b : std_logic_vector(7 downto 0) := (others => '0');

--    fname : in string,
procedure read_image_from_file(
    fname : in string;
    signal vblank : out std_logic;
    signal hblank : out std_logic;
    signal r : out std_logic_vector(7 downto 0);
    signal g : out std_logic_vector(7 downto 0);
    signal b : out std_logic_vector(7 downto 0)
) is
file fid : text open read_mode is fname;
variable text_line : line;
variable ok : boolean;
variable text_vblank : std_logic;
variable text_hblank : std_logic;
variable text_r : integer;
variable text_g : integer;
variable text_b : integer;
begin
    while not endfile(fid) loop
        readline(fid, text_line);
        
        read(text_line, text_vblank, ok);
        read(text_line, text_hblank, ok);
        read(text_line, text_b, ok);
        read(text_line, text_g, ok);
        read(text_line, text_r, ok);
        
        vblank <= text_vblank;
        hblank <= text_hblank;
        r <= std_logic_vector(to_unsigned(text_r, r'length));
        g <= std_logic_vector(to_unsigned(text_g, g'length));
        b <= std_logic_vector(to_unsigned(text_b, b'length));
        
        wait for CLK_PER;
    end loop;
end procedure read_image_from_file;

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
		vblank_in => vblank_in,
		din => din,
		
		hblank_out => hblank_out,
		vblank_out => vblank_out,
		dout => dout
	);
	
	-- Generate clock
	clk <= not clk after CLK_PER/2;
	
	-- Read test vector from file
	main : process begin
		wait for 100 ns; -- GSR
		wait for CLK_PER*10; -- Reset period
		rst <= '0';
		
		read_image_from_file
		(
		  fname => fname_stim1,
		  vblank => vblank_in,
		  hblank => hblank_in,
		  r => din_r,
		  g => din_g,
		  b => din_b
		);
		
		read_image_from_file
		(
		  fname => fname_stim2,
		  vblank => vblank_in,
		  hblank => hblank_in,
		  r => din_r,
		  g => din_g,
		  b => din_b
		);

		finish;
	end process;
	
end behavioral;