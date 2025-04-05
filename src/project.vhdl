library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tt_um_example is
    port (
        ui_in   : in  std_logic_vector(7 downto 0);
        uo_out  : out std_logic_vector(7 downto 0);
        uio_in  : in  std_logic_vector(7 downto 0);
        uio_out : out std_logic_vector(7 downto 0);
        uio_oe  : out std_logic_vector(7 downto 0);
        ena     : in  std_logic;
        clk     : in  std_logic;
        rst_n   : in  std_logic
    );
end tt_um_example;

architecture Behavioral of tt_um_example is

    signal dice_value : unsigned(7 downto 0);
    signal roll : std_logic;
    signal seven_seg : std_logic_vector(6 downto 0);
    signal dice_mode : std_logic_vector(2 downto 0);
    -- signal mux_counter : 
    -- dice value, from 1 to 6
    -- 7 segment display (0 to F)
    -- roll, std_logic (meant to be toggled and switch the state)
    -- dice_value (vector 2 downto 0) (8 different)
    -- 

begin

    -- If receivning input from a button, stop the counter
    -- process(clk)

    -- Increase the value of the die by 1 every clock cycle
    -- if value 6 is reached, next cycle will give 1
    -- if reset is triggered, restore die counter to 1
    process(clk)
    begin
        if rst_n = '1' then
            dice_value <= 1;
        elsif rising_edge(clk) then
            dice_value <= dice_value + 1;
            if dice_value > 6 then
                dice_value <= 1;
            else
                dice_value <= dice_value + 1;
            end if;
        end if;
    end
    
    seven_seg <=
   --abcdefg
    "0110000" when dice_value="0001" else  --1
    "1101101" when dice_value="0010" else  --2
    "1111001" when dice_value="0011" else  --3
    "0110011" when dice_value="0100" else  --4
    "1011011" when dice_value="0101" else  --5
    "1011111" when dice_value="0110" else  --6
    "1111111" when others; 

    uo_out(6 downto 0) <= seven_seg;

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

end Behavioral;