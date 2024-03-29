library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;

entity TRNG_E is
    generic (
        C_N_PDL_BLOCKS: natural := 3; -- 2 ** (POW + 1) lines, 2 ** (POW + 1) - 1 PDLs
        C_PORTS_PER_LUT: natural := 6;
        C_RAND_VECT_LEN: natural := 32
    );
    port (
        I_CLK: std_logic;
        I_PROPAG_BIT: in std_logic;
        I_SEND_RAND_VECT: in std_logic;
        O_PROPAB_ERR: out std_logic;
        O_RAND_VECT: out std_logic_vector(C_RAND_VECT_LEN - 1 downto 0)
    );
end entity TRNG_E;

architecture TRNG_STRUCT_A of TRNG_E is
    signal D_PROPAG_BIT: std_logic_vector(C_N_PDL_BLOCKS downto 0);
    signal CLK_PROPAG_BIT: std_logic_vector(C_N_PDL_BLOCKS downto 0);
    signal DELAY_CTRL: std_logic_vector((C_N_PDL_BLOCKS - 1) downto 0);
    signal A_RAND_BIT: std_logic;
    signal RAND_VECT: std_logic_vector(C_RAND_VECT_LEN - 1 downto 0);

begin

    I_PROPAB_CTRL: entity work.PROPAB_CTRL
        generic map (
            C_DELAY_CTRL_LEN => C_N_PDL_BLOCKS
        )
        port map (
            I_CLK        => I_CLK,
            I_RAND_BIT   => RAND_VECT(RAND_VECT'high),
            O_DELAY_CTRL => DELAY_CTRL, --todo
            O_PROPAB_ERR => O_PROPAB_ERR
        );
    GEN_PDL_BLOCKS: for i in 0 to C_N_PDL_BLOCKS - 1 generate
    begin
        I_PDL_BLOCK: entity work.PDL_BLOCK_E
            generic map (
                C_N_PDLS        => 2 ** i,
                C_PORTS_PER_LUT => C_PORTS_PER_LUT
            )
            port map (
                I_D_PROPAG_BIT   => D_PROPAG_BIT(i),
                I_CLK_PROPAG_BIT => CLK_PROPAG_BIT(i),
                O_D_PROPAG_BIT   => D_PROPAG_BIT(i + 1),
                O_CLK_PROPAG_BIT => CLK_PROPAG_BIT(i + 1),
                I_DELAY_CTRL     => ((C_PORTS_PER_LUT - 1) downto 1 => DELAY_CTRL(i)) --TODO now for entire block and differential
                    -- DELAY_CTRL : C_N_PDLS x [(C_PORTS_PER_LUT - 1) downto 1]
            );
    end generate GEN_PDL_BLOCKS;

    D_PROPAG_BIT(0) <= I_PROPAG_BIT;
    CLK_PROPAG_BIT(0) <= I_PROPAG_BIT;

    A_RAND_BIT <= D_PROPAG_BIT(C_N_PDL_BLOCKS) when rising_edge(CLK_PROPAG_BIT(C_N_PDL_BLOCKS));

    P_SYNC: process(I_CLK)
    begin
        if rising_edge(I_CLK) then
            RAND_VECT <= A_RAND_BIT & RAND_VECT(RAND_VECT'high downto 1);
            if (I_SEND_RAND_VECT = '1') then
                O_RAND_VECT <= RAND_VECT;
            end if;
        end if;
    end process P_SYNC;
end architecture TRNG_STRUCT_A;
