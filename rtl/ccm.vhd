library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ccm is
	port
	(
		clk : in std_logic;
		rst : in std_logic;
		
		c00 : in std_logic_vector (7 downto 0);
		c01 : in std_logic_vector (7 downto 0);
		c02 : in std_logic_vector (7 downto 0);
		c10 : in std_logic_vector (7 downto 0);
		c11 : in std_logic_vector (7 downto 0);
		c12 : in std_logic_vector (7 downto 0);
		c20 : in std_logic_vector (7 downto 0);
		c21 : in std_logic_vector (7 downto 0);
		c22 : in std_logic_vector (7 downto 0);
		
		hblank_in : in std_logic;
		vblank_in : in std_logic;
		din : in std_logic_vector(23 downto 0);
		
		hblank_out : out std_logic;
		vblank_out : out std_logic;
		dout : out std_logic(23 downto 0);
	);
end ccm;

architecture behavioral of ccm is
	signal r_in : std_logic_vector (7 downto 0) := (others => '0');
	signal g_in : std_logic_vector (7 downto 0) := (others => '0');
	signal b_in : std_logic_vector (7 downto 0) := (others => '0');
	signal m00 : signed (15 downto 0) := (others => '0');
	signal m01 : signed (15 downto 0) := (others => '0');
	signal m02 : signed (15 downto 0) := (others => '0');
	signal m02_1 : signed (15 downto 0) := (others => '0');
	signal m10 : signed (15 downto 0) := (others => '0');
	signal m11 : signed (15 downto 0) := (others => '0');
	signal m12 : signed (15 downto 0) := (others => '0');
	signal m12_1 : signed (15 downto 0) := (others => '0');
	signal m20 : signed (15 downto 0) := (others => '0');
	signal m21 : signed (15 downto 0) := (others => '0');
	signal m22 : signed (15 downto 0) := (others => '0');
	signal m22_1 : signed (15 downto 0) := (others => '0');
	signal adder_r_1 : signed (15 downto 0) := (others => '0');
	signal adder_r_2 : signed (15 downto 0) := (others => '0');
	signal adder_g_1 : signed (15 downto 0) := (others => '0');
	signal adder_g_2 : signed (15 downto 0) := (others => '0');
	signal adder_b_1 : signed (15 downto 0) := (others => '0');
	signal adder_b_2 : signed (15 downto 0) := (others => '0');
	signal adder_r_2_scaled : signed (7 downto 0) := (others => '0');
	signal adder_g_2_scaled : signed (7 downto 0) := (others => '0');
	signal adder_b_2_scaled : signed (7 downto 0) := (others => '0');
begin

	process (clk) begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				r_in <= (others => '0');
				g_in <= (others => '0');
				b_in <= (others => '0');
			else
				-- Input registers
				r_in <= din(7 downto 0);
				g_in <= din(15 downto 8);
				b_in <= din(23 downto 16);
				
				-- Coefficient multiplication
				m00 <= c00 * to_signed(r_in);
				m01 <= c01 * to_signed(g_in);
				m02 <= c02 * to_signed(b_in);
				m10 <= c10 * to_signed(r_in);
				m11 <= c11 * to_signed(g_in);
				m12 <= c12 * to_signed(b_in);
				m20 <= c20 * to_signed(r_in);
				m21 <= c21 * to_signed(g_in);
				m22 <= c22 * to_signed(b_in);
				
				-- Delay to match adder pipelines
				m02_1 <= m02;
				m12_1 <= m12;
				m22_1 <= m22;
				
				-- Addition
				adder_r_1 <= m00 + m01;
				adder_r_2 <= adder_r_1 + m02_1;
				adder_g_1 <= m10 + m11;
				adder_g_2 <= adder_g_1 + m12_1;
				adder_b_1 <= m20 + m21;
				adder_b_2 <= adder_b_1 + m22_1;
			end if;
		end if;
	end process;
	
	-- Scale back to 8 bits per component
	adder_r_2_scaled <= adder_r_2(15 downto 8);
	adder_g_2_scaled <= adder_g_2(15 downto 8);
	adder_b_2_scaled <= adder_b_2(15 downto 8);

	-- Assign output wire
	dout <= std_logic_vector(addr_b_2) & std_logic_vector(addr_g_2) & std_logic_vector(addr_b_2);

end behavioral
