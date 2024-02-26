library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Coefficients of the FIR filter, in our case of order 12 so 13 coefficients
entity filter_pipeline is
  generic (a0  : integer;
           a1  : integer;
           a2  : integer;
           a3  : integer;
           a4  : integer;
           a5  : integer;
           a6  : integer;
           a7  : integer;
           a8  : integer;
           a9  : integer;
           a10 : integer;
           a11 : integer;
           a12 : integer
           );

  port (Clk     : in  std_logic;        --100MHz so we can count in 10ns
        Reset   : in  std_logic;
        DataIn  : in  signed (7 downto 0);
        Enable  : in  std_logic;
        DataOut : out signed (7 downto 0));

end filter_pipeline;


architecture behavioural of filter_pipeline is
  constant N_COEFFICIENTS : integer := 12;
  constant N_BITS_DATA : integer := 8;
  constant N_BITS_TEMP: integer:= 16;
  constant N_DIVISION: integer := 8; -- 2**N_DIVISION to divide the filter

  type shift_register_type is array (0 to N_COEFFICIENTS) of signed ((N_BITS_DATA - 1) downto 0);
  signal shift_registers : shift_register_type := (others => (others => '0'));

  type temp_type is array (0 to N_COEFFICIENTS) of signed ((N_BITS_TEMP - 1) downto 0);
  signal temp_registers : temp_type := (others => (others => '0'));

  constant COEFFICIENTS : shift_register_type := (
    to_signed(a0, N_BITS_DATA),
    to_signed(a1, N_BITS_DATA),
    to_signed(a2, N_BITS_DATA),
    to_signed(a3, N_BITS_DATA),
    to_signed(a4, N_BITS_DATA),
    to_signed(a5, N_BITS_DATA),
    to_signed(a6, N_BITS_DATA),
    to_signed(a7, N_BITS_DATA),
    to_signed(a8, N_BITS_DATA),
    to_signed(a9, N_BITS_DATA),
    to_signed(a10, N_BITS_DATA),
    to_signed(a11, N_BITS_DATA),
    to_signed(a12, N_BITS_DATA)
    );
begin
  process(Clk, Reset)
  begin
    if Reset = '1' then
      shift_registers <= (others => (others => '0'));
      temp_registers  <= (others => (others => '0'));
    elsif rising_edge(clk) then
      if enable = '1' then
        shift_registers(0)  <= DataIn;
        shift_registers(1)  <= shift_registers(0);
        shift_registers(2)  <= shift_registers(1);
        shift_registers(3)  <= shift_registers(2);
        shift_registers(4)  <= shift_registers(3);
        shift_registers(5)  <= shift_registers(4);
        shift_registers(6)  <= shift_registers(5);
        shift_registers(7)  <= shift_registers(6);
        shift_registers(8)  <= shift_registers(7);
        shift_registers(9)  <= shift_registers(8);
        shift_registers(10) <= shift_registers(9);
        shift_registers(11) <= shift_registers(10);
        shift_registers(12) <= shift_registers(11);

        -- can I use for loops better?
        -- for i in 1 to N_COEFFICIENTS loop
        --   shift_registers(i) <= shift_registers(i-1);
        -- end loop;
      end if;
    end if;
  end process;

  temp_registers(0)  <= resize(resize(shift_registers(0) * COEFFICIENTS(0), N_BITS_TEMP), N_BITS_TEMP);
  temp_registers(1)  <= resize(temp_registers(0) + resize(shift_registers(1) * COEFFICIENTS(1), N_BITS_TEMP), N_BITS_TEMP);
  temp_registers(2)  <= resize(temp_registers(1) + resize(shift_registers(2) * COEFFICIENTS(2), N_BITS_TEMP), N_BITS_TEMP);
  temp_registers(3)  <= resize(temp_registers(2) + resize(shift_registers(3) * COEFFICIENTS(3), N_BITS_TEMP), N_BITS_TEMP);
  temp_registers(4)  <= resize(temp_registers(3) + resize(shift_registers(4) * COEFFICIENTS(4), N_BITS_TEMP), N_BITS_TEMP);
  temp_registers(5)  <= resize(temp_registers(4) + resize(shift_registers(5) * COEFFICIENTS(5), N_BITS_TEMP), N_BITS_TEMP);
  temp_registers(6)  <= resize(temp_registers(5) + resize(shift_registers(6) * COEFFICIENTS(6), N_BITS_TEMP), N_BITS_TEMP);
  temp_registers(7)  <= resize(temp_registers(6) + resize(shift_registers(7) * COEFFICIENTS(7), N_BITS_TEMP), N_BITS_TEMP);
  temp_registers(8)  <= resize(temp_registers(7) + resize(shift_registers(8) * COEFFICIENTS(8), N_BITS_TEMP), N_BITS_TEMP);
  temp_registers(9)  <= resize(temp_registers(8) + resize(shift_registers(9) * COEFFICIENTS(9), N_BITS_TEMP), N_BITS_TEMP);
  temp_registers(10) <= resize(temp_registers(9) + resize(shift_registers(10) * COEFFICIENTS(10), N_BITS_TEMP), N_BITS_TEMP);
  temp_registers(11) <= resize(temp_registers(10) + resize(shift_registers(11) * COEFFICIENTS(11), N_BITS_TEMP), N_BITS_TEMP);
  temp_registers(12) <= resize(temp_registers(11) + resize(shift_registers(12) * COEFFICIENTS(12), N_BITS_TEMP), N_BITS_TEMP);

  DataOut <= temp_registers(12)((N_DIVISION + N_BITS_DATA) downto (N_DIVISION + 1));

end behavioural;
