LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tt_um_example IS
    PORT (
        ui_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        uo_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        uio_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        uio_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        uio_oe : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        ena : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        rst_n : IN STD_LOGIC
    );
END tt_um_example;

ARCHITECTURE Behavioral OF tt_um_example IS

    SIGNAL dice_value : unsigned(2 DOWNTO 0);
    SIGNAL roll : STD_LOGIC;
    SIGNAL seven_seg : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL dice_mode : STD_LOGIC_VECTOR(2 DOWNTO 0);
    -- signal mux_counter : 
    -- dice value, from 1 to 6
    -- 7 segment display (0 to F)
    -- roll, std_logic (meant to be toggled and switch the state)
    -- dice_value (vector 2 downto 0) (8 different)
    -- 

BEGIN

    -- If receivning input from a button, stop the counter
    -- process(clk)

    -- Increase the value of the die by 1 every clock cycle
    -- if value 6 is reached, next cycle will give 1
    -- if reset is triggered, restore die counter to 1
    PROCESS (clk)
    BEGIN
        IF rst_n = '1' THEN
            dice_value <= 1;
            seven_seg <= "1111111";
        ELSIF rising_edge(clk) THEN
            IF dice_value >= 6 THEN
                dice_value <= 1;
            ELSE
                dice_value <= dice_value + 1;
            END IF;
        END IF;
    END PROCESS;

    PROCESS (dice_value)
    BEGIN
        CASE dice_value IS            --abcdefg   
            WHEN "001" => seven_seg <= "0110000"; -- 1
            WHEN "010" => seven_seg <= "1101101"; -- 2
            WHEN "011" => seven_seg <= "1111001"; -- 3
            WHEN "100" => seven_seg <= "0110011"; -- 4
            WHEN "101" => seven_seg <= "1011011"; -- 5
            WHEN "110" => seven_seg <= "1011111"; -- 6
            WHEN OTHERS => seven_seg <= "1111111";
        END CASE;
    END PROCESS;
        
    -- uo_out(2 downto 0) <= dice_value;
    -- out_out(7 downto 6) <= (others => '0');
    uo_out(6 DOWNTO 0) <= seven_seg;
    


    -- "1111000" when HEX="0111" else--7
    -- "0000000" when HEX="1000" else--8
    -- "0010000" when HEX="1001" else--9
    -- "0001000" when HEX="1010" else--A
    -- "0000011" when HEX="1011" else--b
    -- "1000110" when HEX="1100" else--C
    -- "0100001" when HEX="1101" else--d
    -- "0000110" when HEX="1110" else--E
    -- "0001110" when HEX="1111" else--F
    --uo_out <= std_logic_vector(unsigned(ui_in) + unsigned(uio_in));
    -- uo_out <= not (ui_in and uio_in);
    -- uio_out <= "00000000";
    -- uio_oe <= "00000000";

    -- 
    -- 
    -- 
    -- 

END Behavioral;