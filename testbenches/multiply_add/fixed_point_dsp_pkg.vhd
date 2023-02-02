library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package fixed_point_dsp_pkg is
------------------------------------------------------------------------
    type fixed_point_dsp_record is record
        a,b,c, multiply_add_output : integer;
        ready_pipeline : std_logic_vector(1 downto 0);
    end record;

    constant init_fixed_point_dsp : fixed_point_dsp_record := (0,0,0,0, (others => '0'));
------------------------------------------------------------------------
    procedure create_fixed_point_dsp (
        signal self : inout fixed_point_dsp_record);
------------------------------------------------------------------------
    function get_dsp_result ( dsp_object : fixed_point_dsp_record)
    return integer;
------------------------------------------------------------------------
    procedure multiply_add (
        signal dsp_object : out fixed_point_dsp_record;
        a, b, c : in integer);

    function fixed_point_dsp_is_ready (
        dsp_object : fixed_point_dsp_record)
    return boolean;

end package fixed_point_dsp_pkg;


package body fixed_point_dsp_pkg is
------------------------------------------------------------------------
------------------------------------------------------------------------
    procedure create_fixed_point_dsp
    (
        signal self : inout fixed_point_dsp_record
    ) is
        function "*"
        (
            left, right : integer
        )
        return integer
        is
        begin
            return work.multiplier_pkg.radix_multiply(left, right, 32, 16);
        end "*";
    begin
        self.multiply_add_output <= self.a * self.b + self.c;
        self.ready_pipeline <= self.ready_pipeline(self.ready_pipeline'left-1 downto 0) & '0';
        
    end create_fixed_point_dsp;
------------------------------------------------------------------------
    function get_dsp_result
    (
        dsp_object : fixed_point_dsp_record
    )
    return integer
    is
    begin
        return dsp_object.multiply_add_output;
    end get_dsp_result;
------------------------------------------------------------------------
    procedure multiply_add
    (
        signal dsp_object : out fixed_point_dsp_record;
        a, b, c : in integer
    ) is
    begin
        dsp_object.a <= a;
        dsp_object.b <= b;
        dsp_object.c <= c;
        dsp_object.ready_pipeline(0) <= '1';
    end multiply_add;
------------------------------------------------------------------------
    procedure multiply
    (
        signal dsp_object : out fixed_point_dsp_record;
        a, b: in integer
    ) is
    begin
        dsp_object.a <= a;
        dsp_object.b <= b;
        dsp_object.c <= 0;
        dsp_object.ready_pipeline(0) <= '1';
    end multiply;
------------------------------------------------------------------------
    function fixed_point_dsp_is_ready
    (
        dsp_object : fixed_point_dsp_record
    )
    return boolean
    is
    begin
        return dsp_object.ready_pipeline(dsp_object.ready_pipeline'left) = '1';
    end fixed_point_dsp_is_ready;
------------------------------------------------------------------------

end package body fixed_point_dsp_pkg;

