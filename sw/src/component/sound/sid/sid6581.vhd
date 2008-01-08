-------------------------------------------------------------------------------------
--
--                                 SID 6581
--
--     A fully functional SID chip implementation in VHDL
--
-------------------------------------------------------------------------------------
--	to do:		- filter
--					- smaller implementation, use multiplexed channels
--
-- Synthesize		WARNING:Xst:1988 - Unit <vic_II>: instances <Mcompar__n0411>, <Mcompar__n0337> of unit <LPM_COMPARE_15> and unit <LPM_COMPARE_13> are dual, second instance is removed
--
--"The Filter was a classic multi-mode (state variable) VCF design. There was no way to create a variable transconductance amplifier in our NMOS process, so I simply used FETs as voltage-controlled resistors to control the cutoff frequency. An 11-bit D/A converter generates the control voltage for the FETs (it's actually a 12-bit D/A, but the LSB had no audible affect so I disconnected it!)."
-- "Filter resonance was controlled by a 4-bit weighted resistor ladder. Each bit would turn on one of the weighted resistors and allow a portion of the output to feed back to the input. The state-variable design provided simultaneous low-pass, band-pass and high-pass outputs. Analog switches selected which combination of outputs were sent to the final amplifier (a notch filter was created by enabling both the high and low-pass outputs simultaneously)."
-- "The filter is the worst part of SID because I could not create high-gain op-amps in NMOS, which were essential to a resonant filter. In addition, the resistance of the FETs varied considerably with processing, so different lots of SID chips had different cutoff frequency characteristics. I knew it wouldn't work very well, but it was better than nothing and I didn't have time to make it better."
--
--	- Devide 32MHz <- Dit kun je makkelijker doen door bovenste bit van busCycle te pakken (deze deelt de klok al door 32)
--
--
--
-------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

-------------------------------------------------------------------------------------

entity sid6581 is
	port (
		clk32			: in std_logic;								--	main clock signal
		clk_DAC		: in std_logic;								--	DAC clock signal, must be as high as possible for the best results
		reset			: in std_logic;								-- high active signal (reset when reset = '1')
		cs				: in std_logic;								--	"chip select", when this signal is '1' this model can be accessed
		we				: in std_logic;								-- when '1' this model can be written to, otherwise access is considered as read

		addr			: in unsigned(4 downto 0);					-- address lines
		di				: in std_logic_vector(7 downto 0);		--	data in (to chip)
		do				: out std_logic_vector(7 downto 0);		--	data out	(from chip)

		pot_x				: inout std_logic;							-- paddle input-X
		pot_y				: inout std_logic;							--	paddle input-Y
		audio_out		: out std_logic;								-- this line holds the audio-signal in PWM format
		audio_data	: out std_logic_vector(17 downto 0)
	);
end sid6581;


architecture Behavioral of sid6581 is

	--Implementation Digital to Analog converter
	component pwm_sddac is
		port (
			clk 		: in std_logic;								-- main clock signal, the higher the better
			PWM_in 	: in std_logic_vector(17 downto 0);		--	binary input of signal to be converted
			PWM_out 	: out std_logic								--	PWM output after a simple low-pass filter this is to be considered an analog signal
			);
	end component;

	component pwm_sdadc is
	  port (
  			clk		: in std_logic;								-- main clock signal (actually the higher the better)
			reset		: in std_logic;								--
			ADC_out 	: out std_logic_vector(7 downto 0);		--	binary input of signal to be converted
			ADC_in 	: inout std_logic								--	"analog" paddle input pin
	  		);
	end component;


	-- Implementation of the SID voices (sound channels)
	component sid_voice is
		port (
			clk_1MHz		: in std_logic;							-- this line drives the oscilator
			reset			: in std_logic;							-- active high signal (i.e. registers are reset when reset=1)
			Freq_lo		: in std_logic_vector(7 downto 0);	-- 
			Freq_hi		: in std_logic_vector(7 downto 0);	--
			Pw_lo			: in std_logic_vector(7 downto 0);	--
			Pw_hi			: in std_logic_vector(3 downto 0);	--
			Control		: in std_logic_vector(7 downto 0);	--
			Att_dec		: in std_logic_vector(7 downto 0);	--
			Sus_Rel		: in std_logic_vector(7 downto 0);	--
			PA_MSB_in	: in std_logic;							--
			PA_MSB_out	: out std_logic;							--
			Osc			: out std_logic_vector(7 downto 0);	--
			Env			: out std_logic_vector(7 downto 0);	--
			voice			: out std_logic_vector(11 downto 0)	--
			);
	end component;

-------------------------------------------------------------------------------------
--constant <name>: <type> := <value>;
constant DC_offset		: std_logic_vector(13 downto 0) := "00111111111111";		-- DC offset required to play samples, this is actually a bug of the real 6581, that was converted into an advantage to play samples
-------------------------------------------------------------------------------------

signal Voice_1_Freq_lo	: std_logic_vector(7 downto 0) := "00000000";
signal Voice_1_Freq_hi	: std_logic_vector(7 downto 0) := "00000000";
signal Voice_1_Pw_lo		: std_logic_vector(7 downto 0) := "00000000";
signal Voice_1_Pw_hi		: std_logic_vector(3 downto 0) := "0000";
signal Voice_1_Control	: std_logic_vector(7 downto 0) := "00000000";
signal Voice_1_Att_dec	: std_logic_vector(7 downto 0) := "00000000";
signal Voice_1_Sus_Rel	: std_logic_vector(7 downto 0) := "00000000";
signal Voice_2_Freq_lo	: std_logic_vector(7 downto 0) := "00000000";
signal Voice_2_Freq_hi	: std_logic_vector(7 downto 0) := "00000000";
signal Voice_2_Pw_lo		: std_logic_vector(7 downto 0) := "00000000";
signal Voice_2_Pw_hi		: std_logic_vector(3 downto 0) := "0000";
signal Voice_2_Control	: std_logic_vector(7 downto 0) := "00000000";
signal Voice_2_Att_dec	: std_logic_vector(7 downto 0) := "00000000";
signal Voice_2_Sus_Rel	: std_logic_vector(7 downto 0) := "00000000";
signal Voice_3_Freq_lo	: std_logic_vector(7 downto 0) := "00000000";
signal Voice_3_Freq_hi	: std_logic_vector(7 downto 0) := "00000000";
signal Voice_3_Pw_lo		: std_logic_vector(7 downto 0) := "00000000";
signal Voice_3_Pw_hi		: std_logic_vector(3 downto 0) := "0000";
signal Voice_3_Control	: std_logic_vector(7 downto 0) := "00000000";
signal Voice_3_Att_dec	: std_logic_vector(7 downto 0) := "00000000";
signal Voice_3_Sus_Rel	: std_logic_vector(7 downto 0) := "00000000";
signal Filter_Fc_lo		: std_logic_vector(7 downto 0) := "00000000";
signal Filter_Fc_hi		: std_logic_vector(7 downto 0) := "00000000";
signal Filter_Res_Filt	: std_logic_vector(7 downto 0) := "00000000";
signal Filter_Mode_Vol	: std_logic_vector(7 downto 0) := "00000000";

signal Misc_PotX			: std_logic_vector(7 downto 0) := "00000000";
signal Misc_PotY			: std_logic_vector(7 downto 0) := "00000000";
signal Misc_Osc3_Random	: std_logic_vector(7 downto 0) := "00000000";
signal Misc_Env3			: std_logic_vector(7 downto 0) := "00000000";

signal clk_1MHz			: std_logic;
signal devide_0			: std_logic_vector(31 downto 0);
signal voice_1_PA_MSB	: std_logic;
signal voice_2_PA_MSB	: std_logic;
signal voice_3_PA_MSB	: std_logic;

signal voice_1				: std_logic_vector(11 downto 0);
signal voice_2				: std_logic_vector(11 downto 0);
signal voice_3				: std_logic_vector(11 downto 0);
signal voice_mixed		: std_logic_vector(13 downto 0);
signal voice_volume		: std_logic_vector(17 downto 0);

signal do_buf				: std_logic_vector(7 downto 0);	

-------------------------------------------------------------------------------------

begin
	digital_to_analog: pwm_sddac
		port map(
			clk			=> clk_DAC,
			PWM_in 		=> voice_volume,
			PWM_out 		=> audio_out
		   );
	audio_data <= voice_volume;
	
	paddle_x: pwm_sdadc
	  port map (
  			clk			=> clk_1MHz,
			reset			=> reset,
			ADC_out 		=> Misc_PotX,
			ADC_in 		=> pot_x
	  		);

	paddle_y: pwm_sdadc
	  port map (
  			clk			=> clk_1MHz,
			reset			=> reset,
			ADC_out 		=> Misc_PotY,
			ADC_in 		=> pot_y
	  		);

	sid_voice_1: sid_voice
		port map(
			clk_1MHz		=> clk_1MHz,
			reset			=> reset,
			Freq_lo		=> Voice_1_Freq_lo,
			Freq_hi		=> Voice_1_Freq_hi,
			Pw_lo			=> Voice_1_Pw_lo,
			Pw_hi			=> Voice_1_Pw_hi,
			Control		=> Voice_1_Control,
			Att_dec		=> Voice_1_Att_dec,
			Sus_Rel		=> Voice_1_Sus_Rel,
			PA_MSB_in	=> voice_3_PA_MSB,
			PA_MSB_out	=> voice_1_PA_MSB,
--			Osc			=> ...
--			Env			=> ...
			voice			=> voice_1
			);

	sid_voice_2: sid_voice
		port map(
			clk_1MHz		=> clk_1MHz,
			reset			=> reset,
			Freq_lo		=> Voice_2_Freq_lo,
			Freq_hi		=> Voice_2_Freq_hi,
			Pw_lo			=> Voice_2_Pw_lo,
			Pw_hi			=> Voice_2_Pw_hi,
			Control		=> Voice_2_Control,
			Att_dec		=> Voice_2_Att_dec,
			Sus_Rel		=> Voice_2_Sus_Rel,
			PA_MSB_in	=> voice_1_PA_MSB,
			PA_MSB_out	=> voice_2_PA_MSB,
--			Osc			=> ...
--			Env			=> ...
			voice			=> voice_2
			);

	sid_voice_3: sid_voice
		port map(
			clk_1MHz		=> clk_1MHz,
			reset			=> reset,
			Freq_lo		=> Voice_3_Freq_lo,
			Freq_hi		=> Voice_3_Freq_hi,
			Pw_lo			=> Voice_3_Pw_lo,
			Pw_hi			=> Voice_3_Pw_hi,
			Control		=> Voice_3_Control,
			Att_dec		=> Voice_3_Att_dec,
			Sus_Rel		=> Voice_3_Sus_Rel,
			PA_MSB_in	=> voice_2_PA_MSB,
			PA_MSB_out	=> voice_3_PA_MSB,
			Osc			=> Misc_Osc3_Random,
			Env			=> Misc_Env3,
			voice			=> voice_3
			);

-------------------------------------------------------------------------------------
do						<= do_buf;
clk_1MHz				<= devide_0(31);

voice_mixed		<= (("00" & voice_1) + ("00" & voice_2)) + (voice_3 + DC_offset);		--add voice 1+2 and 3, we must do this in this way to create the shortest timing path (keep in mind that a basic adder can only add two variables)
voice_volume	<= voice_mixed * Filter_Mode_Vol(3 downto 0);								--multiply the volume register with the voices


-- Devide 32MHz clock back to 1MHz for internal use within the SID
devider0: process(clk32)				-- this process devides 32 MHz to 1MHz (for the SID)
begin									
	if (rising_edge(clk32)) then			    			
		if (reset = '1') then				
			devide_0 	<= "00000000000000001111111111111111";
		else
			devide_0(31 downto 1)	<= devide_0(30 downto 0); --devide(31) now has a freq. that is 1/32 of clk32, while having a duty cycle of 50%
			devide_0(0)					<= devide_0(31);
		end if;
	end if;
end process;


-- Register decoding
register_decoder:process(clk32)
begin
	if rising_edge(clk32) then
		if (reset = '1') then
			--------------------------------------- Voice-1
			Voice_1_Freq_lo	<= "00000000";
			Voice_1_Freq_hi	<= "00000000";
			Voice_1_Pw_lo		<= "00000000";
			Voice_1_Pw_hi		<= "0000";
			Voice_1_Control	<= "00000000";
			Voice_1_Att_dec	<= "00000000";
			Voice_1_Sus_Rel	<= "00000000";
			--------------------------------------- Voice-2
			Voice_2_Freq_lo	<= "00000000";
			Voice_2_Freq_hi	<= "00000000";
			Voice_2_Pw_lo		<= "00000000";
			Voice_2_Pw_hi		<= "0000";
			Voice_2_Control	<= "00000000";
			Voice_2_Att_dec	<= "00000000";
			Voice_2_Sus_Rel	<= "00000000";
			--------------------------------------- Voice-3
			Voice_3_Freq_lo	<= "00000000";
			Voice_3_Freq_hi	<= "00000000";
			Voice_3_Pw_lo		<= "00000000";
			Voice_3_Pw_hi		<= "0000";
			Voice_3_Control	<= "00000000";
			Voice_3_Att_dec	<= "00000000";
			Voice_3_Sus_Rel	<= "00000000";
			--------------------------------------- Filter & volume
			Filter_Fc_lo		<= "00000000";
			Filter_Fc_hi		<= "00000000";
			Filter_Res_Filt	<= "00000000";
			Filter_Mode_Vol	<= "00000000";
		else
			Voice_1_Freq_lo	<= Voice_1_Freq_lo;
			Voice_1_Freq_hi	<= Voice_1_Freq_hi;
			Voice_1_Pw_lo		<= Voice_1_Pw_lo;
			Voice_1_Pw_hi		<= Voice_1_Pw_hi;
			Voice_1_Control	<= Voice_1_Control;
			Voice_1_Att_dec	<= Voice_1_Att_dec;
			Voice_1_Sus_Rel	<= Voice_1_Sus_Rel;
			Voice_2_Freq_lo	<= Voice_2_Freq_lo;
			Voice_2_Freq_hi	<= Voice_2_Freq_hi;
			Voice_2_Pw_lo		<= Voice_2_Pw_lo;
			Voice_2_Pw_hi		<= Voice_2_Pw_hi;
			Voice_2_Control	<= Voice_2_Control;
			Voice_2_Att_dec	<= Voice_2_Att_dec;
			Voice_2_Sus_Rel	<= Voice_2_Sus_Rel;
			Voice_3_Freq_lo	<= Voice_3_Freq_lo;
			Voice_3_Freq_hi	<= Voice_3_Freq_hi;
			Voice_3_Pw_lo		<= Voice_3_Pw_lo;
			Voice_3_Pw_hi		<= Voice_3_Pw_hi;
			Voice_3_Control	<= Voice_3_Control;
			Voice_3_Att_dec	<= Voice_3_Att_dec;
			Voice_3_Sus_Rel	<= Voice_3_Sus_Rel;
			Filter_Fc_lo		<= Filter_Fc_lo;
			Filter_Fc_hi		<= Filter_Fc_hi;
			Filter_Res_Filt	<= Filter_Res_Filt;
			Filter_Mode_Vol	<= Filter_Mode_Vol;
--			do_buf			<= do_buf;
			do_buf 			<= "00000000";

			if (cs='1') then
				if (we='1') then	-- Write to SID-register
							------------------------
					--case CONV_INTEGER(addr) is
					case to_integer(addr) is
						-------------------------------------- Voice-1	
						when 00 =>	Voice_1_Freq_lo	<= di;
						when 01 =>	Voice_1_Freq_hi	<= di;
						when 02 =>	Voice_1_Pw_lo		<= di;
						when 03 =>	Voice_1_Pw_hi		<= di(3 downto 0);
						when 04 =>	Voice_1_Control	<= di;
						when 05 =>	Voice_1_Att_dec	<= di;
						when 06 =>	Voice_1_Sus_Rel	<= di;
						--------------------------------------- Voice-2
						when 07 =>	Voice_2_Freq_lo	<= di;
						when 08 =>	Voice_2_Freq_hi	<= di;
						when 09 =>	Voice_2_Pw_lo		<= di;
						when 10 =>	Voice_2_Pw_hi		<= di(3 downto 0);
						when 11 =>	Voice_2_Control	<= di;
						when 12 =>	Voice_2_Att_dec	<= di;
						when 13 =>	Voice_2_Sus_Rel	<= di;
						--------------------------------------- Voice-3
						when 14 =>	Voice_3_Freq_lo	<= di;
						when 15 =>	Voice_3_Freq_hi	<= di;
						when 16 =>	Voice_3_Pw_lo		<= di;
						when 17 =>	Voice_3_Pw_hi		<= di(3 downto 0);
						when 18 =>	Voice_3_Control	<= di;
						when 19 =>	Voice_3_Att_dec	<= di;
						when 20 =>	Voice_3_Sus_Rel	<= di;
						--------------------------------------- Filter & volume
						when 21 =>	Filter_Fc_lo		<= di;
						when 22 =>	Filter_Fc_hi		<= di;
						when 23 =>	Filter_Res_Filt	<= di;
						when 24 =>	Filter_Mode_Vol	<= di;
						--------------------------------------
						when others	=>	null;
					end case;

				else			-- Read from SID-register
						-------------------------
					--case CONV_INTEGER(addr) is
					case to_integer(addr) is
						-------------------------------------- Misc
						when 25 =>	do_buf	<= Misc_PotX;
						when 26 =>	do_buf	<= Misc_PotY;
						when 27 =>	do_buf	<= Misc_Osc3_Random;
						when 28 =>	do_buf	<= Misc_Env3;
						--------------------------------------
--						when others	=>	null;
						when others	=>	do_buf <= "00000000";

					end case;		
				end if;
			end if;
		end if;
	end if;
end process;


end Behavioral;
