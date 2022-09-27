library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity BIAS_FILTER_E is
    generic(
        C_FILTER_LEN: natural := 5;
        C_SAMPLE_LEN: natural := 16;
        C_N_PDLS : natural := 32
    )
    port(
        I_BIT_CNT: in unsigned(C_N_PDLS - 1 downto 0);
        I_CLK : in std_logic;
        I_RESET : in std_logic;
        I_RAND_BIT : in std_logic
    );
end BIAS_FILTER_E;

architecture BIAS_FILTER_BEHAV_A of BIAS_FILTER_E is
    type t_cnt_bias is array (C_FILTER_LEN - 1 downto 0) of unsigned(C_SAMPLE_LEN - 1 downto 0);
    signal CNT_BIAS : t_cnt_bias := (others => (others => '0'));
begin
end architecture BIAS_FILTER_BEHAV_A;