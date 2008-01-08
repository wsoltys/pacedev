library IEEE;
use IEEE.std_logic_1164.all;
Use IEEE.numeric_std.all;
--use IEEE.std_logic_unsigned.all;

package conversion is
   function to_uint (a: std_ulogic_vector) return integer;
    function to_uint (a: std_ulogic) return integer;
   function to_vector (size: integer; num: integer) return std_logic_vector;
end conversion;

package body conversion is
   -- Convert a std_ulogic_vector to an unsigned integer
    function to_uint (a: std_ulogic_vector) return integer is
        alias av: std_ulogic_vector (1 to a'length) is a;
        variable val: integer := 0;
        variable b: integer := 1;
    begin
        for i in a'length downto 1 loop
            if (av(i) = '1') then    -- if LSB is '1',
                val := val + b;       -- add value for current bit position
            end if;
            b := b * 2;    -- Shift left 1 bit
        end loop;
 
        return val;
    end to_uint;
    
    function to_uint (a: std_ulogic) return integer is
       variable ret: integer;
    begin
        if( a = '1' ) then
            ret := 1;
        else
           ret := 0;
       end if;
       return ret;
    end to_uint;
 
	-- Convert an integer to std_ulogic_vector type
    function to_vector(size: integer; num: integer) return std_logic_vector is
		variable conv: std_logic_vector(1 to size);
		variable a: integer;
		variable neg: boolean;
    begin
        a := num;
		if a < 0 then
			neg := true;
			a := -a;
		else
			neg := false;
		end if;

		conv := not std_logic_vector(to_unsigned(natural(a),size));
--		if neg then
--			conv := not conv + "1";
--		end if;
		return conv;
    end to_vector;
end conversion;



