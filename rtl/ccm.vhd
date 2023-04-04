library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ccm is
	port
	(
		clk : in std_logic;
		rst : in std_logic;
		
		c00 : in std_logic_vector (15 downto 0);
		c01 : in std_logic_vector (15 downto 0);
		c02 : in std_logic_vector (15 downto 0);
		c10 : in std_logic_vector (15 downto 0);
		c11 : in std_logic_vector (15 downto 0);
		c12 : in std_logic_vector (15 downto 0);
		c20 : in std_logic_vector (15 downto 0);
		c21 : in std_logic_vector (15 downto 0);
		c22 : in std_logic_vector (15 downto 0);
		
		hblank_in : in std_logic;
		vblank_in : in std_logic;
		din : in std_logic_vector(23 downto 0);
		
		hblank_out : out std_logic;
		vblank_out : out std_logic;
		dout : out std_logic_vector(23 downto 0)
	);
end ccm;

architecture behavioral of ccm is
	constant SAT_MIN : signed (15 downto 0) := X"0000";
	constant SAT_MAX : signed (15 downto 0) := X"00FF";
	signal r_in : std_logic_vector (16 downto 0) := (others => '0');
	signal g_in : std_logic_vector (16 downto 0) := (others => '0');
	signal b_in : std_logic_vector (16 downto 0) := (others => '0');
	signal m00 : signed (32 downto 0) := (others => '0');
	signal m01 : signed (32 downto 0) := (others => '0');
	signal m02 : signed (32 downto 0) := (others => '0');
	signal m02_1 : signed (32 downto 0) := (others => '0');
	signal m10 : signed (32 downto 0) := (others => '0');
	signal m11 : signed (32 downto 0) := (others => '0');
	signal m12 : signed (32 downto 0) := (others => '0');
	signal m12_1 : signed (32 downto 0) := (others => '0');
	signal m20 : signed (32 downto 0) := (others => '0');
	signal m21 : signed (32 downto 0) := (others => '0');
	signal m22 : signed (32 downto 0) := (others => '0');
	signal m22_1 : signed (32 downto 0) := (others => '0');
	signal adder_r_1 : signed (32 downto 0) := (others => '0');
	signal adder_r_2 : signed (32 downto 0) := (others => '0');
	signal adder_g_1 : signed (32 downto 0) := (others => '0');
	signal adder_g_2 : signed (32 downto 0) := (others => '0');
	signal adder_b_1 : signed (32 downto 0) := (others => '0');
	signal adder_b_2 : signed (32 downto 0) := (others => '0');
	signal adder_r_2_scaled : signed (15 downto 0) := (others => '0');
	signal adder_g_2_scaled : signed (15 downto 0) := (others => '0');
	signal adder_b_2_scaled : signed (15 downto 0) := (others => '0');
	signal adder_r_2_sat : signed (7 downto 0) := (others => '0');
	signal adder_g_2_sat : signed (7 downto 0) := (others => '0');
	signal adder_b_2_sat : signed (7 downto 0) := (others => '0');
	signal hblank_in_1 : std_logic := '0';
	signal vblank_in_1 : std_logic := '0';
	signal hblank_in_2 : std_logic := '0';
	signal vblank_in_2 : std_logic := '0';
	signal hblank_in_3 : std_logic := '0';
	signal vblank_in_3 : std_logic := '0';
	signal hblank_in_4 : std_logic := '0';
	signal vblank_in_4 : std_logic := '0';
begin

	process (clk) begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				r_in <= (others => '0');
				g_in <= (others => '0');
				b_in <= (others => '0');
				m00 <= (others => '0');
				m01 <= (others => '0');
				m02 <= (others => '0');
				m02_1 <= (others => '0');
				m10 <= (others => '0');
				m11 <= (others => '0');
				m12 <= (others => '0');
				m12_1 <= (others => '0');
				m20 <= (others => '0');
				m21 <= (others => '0');
				m22 <= (others => '0');
				m22_1 <= (others => '0');
				adder_r_1 <= (others => '0');
				adder_r_2 <= (others => '0');
				adder_g_1 <= (others => '0');
				adder_g_2 <= (others => '0');
				adder_b_1 <= (others => '0');
				adder_b_2 <= (others => '0');
			else
				-- Input registers
				r_in <= '0' & din(7 downto 0) & X"00";
				g_in <= '0' & din(15 downto 8) & X"00";
				b_in <= '0' & din(23 downto 16) & X"00";
				
				-- Coefficient multiplication
				m00 <= signed(c00) * signed(r_in);
				m01 <= signed(c01) * signed(g_in);
				m02 <= signed(c02) * signed(b_in);
				m10 <= signed(c10) * signed(r_in);
				m11 <= signed(c11) * signed(g_in);
				m12 <= signed(c12) * signed(b_in);
				m20 <= signed(c20) * signed(r_in);
				m21 <= signed(c21) * signed(g_in);
				m22 <= signed(c22) * signed(b_in);
				
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
	adder_r_2_scaled <= adder_r_2(adder_r_2'left downto adder_r_2'left-15);
	adder_g_2_scaled <= adder_g_2(adder_g_2'left downto adder_g_2'left-15);
	adder_b_2_scaled <= adder_b_2(adder_b_2'left downto adder_b_2'left-15);

	-- Saturate to 8 bits
	adder_r_2_sat <= SAT_MAX when adder_r_2_scaled > SAT_MAX else
									 SAT_MIN when adder_r_2_scaled < SAT_MIN else
									 adder_r_2_scaled(7 downto 0);

	adder_g_2_sat <= SAT_MAX when adder_g_2_scaled > SAT_MAX else
									 SAT_MIN when adder_g_2_scaled < SAT_MIN else
									 adder_g_2_scaled(7 downto 0);

	adder_b_2_sat <= SAT_MAX when adder_b_2_scaled > SAT_MAX else
									 SAT_MIN when adder_b_2_scaled < SAT_MIN else
									 adder_b_2_scaled(7 downto 0);

	-- Assign output wire
	dout <= std_logic_vector(adder_b_2_sat) & std_logic_vector(adder_g_2_sat) & std_logic_vector(adder_r_2_sat);

	-- Match blanking signal delays with datapath delays
	process (clk) begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				hblank_in_1 <= '0';
				vblank_in_1 <= '0';
				hblank_in_2 <= '0';
				vblank_in_2 <= '0';
				hblank_in_3 <= '0';
				vblank_in_3 <= '0';
				hblank_in_4 <= '0';
				vblank_in_4 <= '0';
			else
				hblank_in_1 <= hblank_in;
				vblank_in_1 <= vblank_in;
				hblank_in_2 <= hblank_in_1;
				vblank_in_2 <= vblank_in_1;
				hblank_in_3 <= hblank_in_2;
				vblank_in_3 <= vblank_in_2;
				hblank_in_4 <= hblank_in_3;
				vblank_in_4 <= vblank_in_3;
			end if;
		end if;
	end process;
	
	hblank_out <= hblank_in_4;
	vblank_out <= vblank_in_4;

end behavioral;
