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

    SIGNAL dice_value : unsigned(3 DOWNTO 0);
    SIGNAL dice_mode : unsigned(2 DOWNTO 0);
    SIGNAL dice_select, dice_old, dice_op : STD_LOGIC;
    signal dice_max : unsigned(5 downto 0);
    
    SIGNAL seven_seg : STD_LOGIC_VECTOR(6 DOWNTO 0);
    -- signal mux_counter : 
    -- dice value, from 1 to 6
    -- 7 segment display (0 to F)
    -- roll, std_logic (meant to be toggled and switch the state)
    -- dice_value (vector 2 downto 0) (8 different)
    -- 

BEGIN

    PROCESS (clk)
    begin
        if rst_n = '1' then
            dice_select <= '0';
        elsif rising_edge(clk) then
            dice_select <= ui_in(1);
            dice_old <= dice_select;
        end if;
    end process;

    dice_op <= dice_select and not dice_old;

    process(clk)
    begin
        IF rst_n = '1' THEN
            dice_mode <= (others => '0');
        elsif rising_edge(clk) then
            if dice_op = '1' then
                IF dice_mode >= 5 THEN
                    dice_mode <= 0;
                ELSE
                    dice_mode <= dice_mode + 1;
                end if;
            end if;
        end if;
    end process;

    PROCESS (dice_mode)
    BEGIN
        CASE dice_mode IS            --abcdefg   
            WHEN "000" => dice_max <= "000110"; -- D6
            WHEN "001" => dice_max <= "000100"; -- D4
            WHEN "010" => dice_max <= "001000"; -- D8
            -- WHEN "011" => dice_max <= "001010"; -- D10
            -- WHEN "100" => dice_max <= "001100"; -- D12
            -- WHEN "101" => dice_max <= "010100"; -- D20
            WHEN OTHERS => dice_max <= "111111";  --D255
        END CASE;
    END PROCESS;

    -- Increase the value of the die by 1 every clock cycle
    -- if value 6 is reached, next cycle will give 1
    -- if reset is triggered, restore die counter to 1
    PROCESS (clk)
    BEGIN
        IF rst_n = '1' THEN
            dice_value <= 1;
            seven_seg <= "0110000";
        ELSIF rising_edge(clk) THEN
        -- If receivning input from a button, increment the counter
            if ui_in(0) = '1' then
                IF dice_value >= dice_max THEN
                    dice_value <= 1;
                ELSE
                    dice_value <= dice_value + 1;
                end if;
            end if;
        END IF;
    END PROCESS;

    PROCESS (dice_value)
    BEGIN
        CASE dice_value IS            --abcdefg   
            WHEN "0001" => seven_seg <= "0110000"; -- 1
            WHEN "0010" => seven_seg <= "1101101"; -- 2
            WHEN "0011" => seven_seg <= "1111001"; -- 3
            WHEN "0100" => seven_seg <= "0110011"; -- 4
            WHEN "0101" => seven_seg <= "1011011"; -- 5
            WHEN "0110" => seven_seg <= "1011111"; -- 6
            WHEN "0111" => seven_seg <= "1110000"; -- 7
            WHEN "1000" => seven_seg <= "1111111"; -- 8
            WHEN OTHERS => seven_seg <= "0000001"; -- Minus
        END CASE;
    END PROCESS;
    

    -- Multiplexed 7 segment displays
    -- Muxes a set of 4 with a counter
    -- case mux_dice is
    -- when
    -- seven_seg_out


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

END Behavioral;