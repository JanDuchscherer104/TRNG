-- C_MUX_NUM multiplexers with 1bit selcetion signal.

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity MUX_E is
    generic(
        C_MUX_NUM: natural := 3
    );
    port(
        I_BITS_A  : in std_logic_vector(C_MUX_NUM - 1 downto 0);
        I_BITS_B  : in std_logic_vector(C_MUX_NUM - 1 downto 0);
        I_SELECT  : in std_logic;
        O_PDL    : out std_logic_vector(C_MUX_NUM - 1 downto 0)
    );
end entity MUX_E;

architecture MUX_BEHAV_A of MUX_E is
begin
    O_PDL   <= I_BITS_A when I_SELECT = '1' else
               I_BITS_B;
end architecture MUX_A;
