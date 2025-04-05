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

    SIGNAL display_one : unsigned(7 DOWNTO 0);
    SIGNAL display_two : unsigned(7 DOWNTO 0);
    SIGNAL display_three : unsigned(7 DOWNTO 0);
    SIGNAL display_four : unsigned(7 DOWNTO 0);
    SIGNAL dice_value : unsigned(7 DOWNTO 0);
    SIGNAL dice_mode : unsigned(2 DOWNTO 0);
    SIGNAL dice_amount : unsigned(1 DOWNTO 0);
    SIGNAL dice_roll_pos : unsigned(1 DOWNTO 0);
    SIGNAL dice_mode_select, dice_mode_old, dice_mode_op : STD_LOGIC;
    SIGNAL dice_amount_select, dice_amount_old, dice_amount_op : STD_LOGIC;
    SIGNAL dice_roll_select, dice_roll_old, dice_roll_op : STD_LOGIC;
    SIGNAL dice_value_max : unsigned(5 DOWNTO 0);
    SIGNAL disp_mux_cntr : unsigned(1 DOWNTO 0);
    SIGNAL disp_mux_out : STD_LOGIC_VECTOR(3 DOWNTO 0);

    SIGNAL seven_seg : STD_LOGIC_VECTOR(6 DOWNTO 0);

BEGIN

    -- Synchronize signals
    PROCESS (clk)
    BEGIN
        IF rst_n = '1' THEN
            dice_roll_select <= '0';
            dice_mode_select <= '0';
            dice_amount_select <= '0';
        ELSIF rising_edge(clk) THEN

            dice_roll_select <= ui_in(0);
            dice_roll_old <= dice_roll_select;
            dice_mode_select <= ui_in(1);
            dice_mode_old <= dice_mode_select;
            dice_amount_select <= ui_in(2);
            dice_amount_old <= dice_amount_select;

        END IF;
    END PROCESS;

    dice_roll_op <= dice_roll_select AND NOT dice_roll_old;
    dice_amount_op <= dice_amount_select AND NOT dice_amount_old;
    dice_mode_op <= dice_mode_select AND NOT dice_mode_old;

    -- Dice mode selection process
    PROCESS (clk)
    BEGIN
        IF rst_n = '1' THEN
            dice_mode <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF dice_mode_op = '1' THEN
                -- FIXME: Temporarily set to 2 before enabling higher dice
                IF dice_mode >= 2 THEN
                    dice_mode <= to_unsigned(0, 3);
                ELSE
                    dice_mode <= dice_mode + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- No. of dice selection process
    PROCESS (clk)
    BEGIN
        IF rst_n = '1' THEN
            dice_amount <= "1";
        ELSIF rising_edge(clk) THEN
            IF dice_amount_op = '1' THEN
                IF dice_amount >= 4 THEN
                    dice_amount <= to_unsigned(1, 2);
                ELSE
                    dice_amount <= dice_amount + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    PROCESS (dice_mode)
    BEGIN
        CASE dice_mode IS --abcdefg   
            WHEN "000" => dice_value_max <= "000110"; -- D6
            WHEN "001" => dice_value_max <= "000100"; -- D4
            WHEN "010" => dice_value_max <= "001000"; -- D8
                -- WHEN "011" => dice_value_max <= "001010"; -- D10
                -- WHEN "100" => dice_value_max <= "001100"; -- D12
                -- WHEN "101" => dice_value_max <= "010100"; -- D20
            WHEN OTHERS => dice_value_max <= "111111"; --D255
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
            -- This cannot be synchronized as a variable
            IF ui_in(0) = '1' THEN
                IF dice_value >= dice_value_max THEN
                    dice_value <= to_unsigned(1, 8);
                ELSE
                    dice_value <= dice_value + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    -- Roll multiple dice
    PROCESS (clk)
    BEGIN
        IF rst_n = '1' THEN
            dice_roll_pos <= '0';

        ELSIF rising_edge(clk) THEN
            IF dice_roll_op = '1' THEN
                IF dice_roll_pos >= dice_amount THEN
                    dice_roll_pos <= to_unsigned(0, 2);
                ELSE
                    dice_roll_pos <= dice_roll_pos + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;


    -- 2-bit (4 decimal) counter for multiplexing which seven segment display to show
    PROCESS (clk) BEGIN
        IF (rst_n = '1') THEN
            disp_mux_cntr <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF disp_mux_cntr >= dice_amount THEN
                disp_mux_cntr <= (OTHERS => '0');
            ELSE
                disp_mux_cntr <= disp_mux_cntr + 1;
            END IF;
        END IF;
    END PROCESS;

    -- FIXME: Add a separate clock for the mux signal, otherwise it will clock itself to death
    PROCESS (disp_mux_cntr)
    BEGIN
        CASE disp_mux_cntr IS
            WHEN "00" => disp_mux_out <= "0001";
            WHEN "01" => disp_mux_out <= "0010";
            WHEN "10" => disp_mux_out <= "0100";
            WHEN "11" => disp_mux_out <= "1000";
            WHEN OTHERS => disp_mux_out <= "0000";
        END CASE;
    END PROCESS;

    uio_out(3 DOWNTO 0) <= disp_mux_out;

    process(dice_roll_pos)
    begin
        case dice_roll_pos is
        when 0 => display_one <= dice_value;
        when 1 => display_two <= dice_value;
        when 2 => display_three <= dice_value;
        when 3 => display_four <= dice_value;
        end case;
    end process;


    PROCESS (dice_value)
    BEGIN
        CASE dice_value IS              --abcdefg   
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

    uo_out(6 DOWNTO 0) <= seven_seg;


END Behavioral;