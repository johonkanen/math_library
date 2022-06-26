library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    use work.lookup_table_generator_pkg.all;
    use work.ram_read_port_pkg.all;

package lut_sine_pkg is

    subtype ram_record is ram_read_port_record;

------------------------------------------------------------------------
    procedure create_lut_sine (
        signal ram_object : inout ram_record);
------------------------------------------------------------------------
    function calculate_sine_lut (
        number_of_entries : natural;
        number_of_bits : natural range 8 to 32)
    return integer_array;
------------------------------------------------------------------------
    function sine_lut_is_ready ( ram_object : ram_record)
        return boolean;
------------------------------------------------------------------------
    function get_sine_from_lut ( ram_object : ram_record)
        return integer;
------------------------------------------------------------------------
    procedure request_sine_from_lut (
        signal ram_object : out ram_record;
        address : integer);
------------------------------------------------------------------------

    constant sine_table_entries : integer_array(0 to lookup_table_bits-1) := calculate_sine_lut(lookup_table_bits,16); 

------------------------------------------------------------------------
end package lut_sine_pkg;


package body lut_sine_pkg is
------------------------------------------------------------------------
    function calculate_sine_lut
    (
        number_of_entries : natural;
        number_of_bits : natural range 8 to 32
    )
    return integer_array
    is
        variable sine_lut : integer_array(0 to number_of_entries-1);
        variable index : real := 0.0;
        variable angle : real := 0.0;
        variable calculated_sine : real := 0.0;
        variable sine_scaled_to_integer : real := 0.0;

    begin
        for i in 0 to number_of_entries-1 loop
            index := real(i);
            angle := 1.0/real(number_of_entries)*index;
            calculated_sine := lookup_table_generator(angle);
            sine_scaled_to_integer := calculated_sine*(2.0**number_of_bits-1.0);
            sine_lut(i) := integer(sine_scaled_to_integer);

        end loop;
        return sine_lut;

    end calculate_sine_lut;
------------------------------------------------------------------------
    procedure create_lut_sine
    (
        signal ram_object : inout ram_record
    ) is
        constant sines : integer_array := sine_table_entries;
    begin

        create_ram_read_port(ram_object, sines);
        
    end create_lut_sine;
------------------------------------------------------------------------
    procedure request_sine_from_lut
    (
        signal ram_object : out ram_record;
        address : integer
    ) is
    begin
        request_data_from_ram(ram_object, address);
    end request_sine_from_lut;
------------------------------------------------------------------------
    function sine_lut_is_ready
    (
        ram_object : ram_record
    )
    return boolean
    is
    begin
        return ram_read_is_ready(ram_object);
    end sine_lut_is_ready;
------------------------------------------------------------------------
    function get_sine_from_lut
    (
        ram_object : ram_record
    )
    return integer
    is
    begin
        return ram_object.data;
    end get_sine_from_lut;
------------------------------------------------------------------------
end package body lut_sine_pkg;
