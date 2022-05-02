library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--on every bit there is different frequency
--		 (HZ)risEdges per sec    	period
--clk   -125 000 000      			- 8			ns
--0 	- 62 500 000				- 0.016 	us	
--1 	- 31 250 000				- 0.032 	us		
--2 	- 15 625 000				- 0.064 	us
--3 	-  7 812 500				- 0.128 	us
--4 	-  3 906 250				- 0.256 	us
--5 	-  1 952 125				- 0.512 	us
--6 	-    976 562.5				- 1.024 	us
--7 	-    488 281.25				- 2.048 	us
--8 	-    244 140.625			- 4.096 	us
--9 	-    122 070.321 5			- 8.192 	us
--10  	-	  61 035.156 25			- 16.384 	us
--11	-	  30 517.578 125		- 32.768 	us
--12    -     15 258.789 062 5		- 65.536 	us
--13	-	   7 629.394 531 25		- 0.131072	ms
--14    -      3 814.697 265 625	- 0.262144	ms
--15 	-      1 907.348			- 0.524288	ms
--16 	-        953.674			- 1.048576 	ms
--17	-        476.837			- 2.097152	ms
--18	-        238.418			- 4.194304 	ms
--19    -        119.209			- 8.388608	ms
--20	-		  59.604			- 16.777216 ms
--21	- 		  29.802			- 33.554432 ms
--22	-		  14.901			- 67.108864 ms
--23	-		   7.450			- 0.1342177 s
--24	-		   3.725			- 0.2684354 s
--25    -          1.89             - 0.52      s 
entity FrequencyDivider is
  port(
    clk     : in  std_logic;
    rst  : in  std_logic;
	VFF: out std_logic;--Very fast frequency for distinct players
	FF: out std_logic;--Fast frequency for 7 segments display
	SF: out std_logic;--Slow frequency for leds and displaying winner
	EF_0_1 :in std_logic;--enable 0.1 sec frequency
	SW: out std_logic;--leds and CL blinking
	DF: out std_logic;--impulse generated afer 1milisecond/7.DF=Debouncer frecuency
	F_0_1	:out std_logic;--one clk period pulse every 0.1 sec.
	DIV		:in std_logic--'1' if all frequencies should be divided by 1024
  );
end FrequencyDivider;

-- Declaración de la arquitectura
architecture behavioral of FrequencyDivider is

  -- Declaración de se?ales internas
  signal counter : unsigned(25 downto 0);
  signal Q1_0_03,Q2_0_03:std_logic;--rissing edge detector of 0.03 s period bit
  signal Q1_VFF,Q2_VFF:std_logic;--rising edge detector of VFF bit
  signal Q1_FF,Q2_FF:std_logic;--rising edge detector of FF bit
  signal Q1_SF,Q2_SF:std_logic;--rising edge detector of SF bit
  signal Q1_DF,Q2_DF:std_logic;--rising edge detector of DF bit
  signal C_0_1:unsigned(1 downto 0);-- counts(rising edges of 0.033 s signal)
  signal R_0_1:std_logic;--internal F_0_1
  signal F_0_03:std_logic;--pulse after every 0.03 sec
  signal VFFBit:integer range 0 to 10;--bit with 8*FF frequency(10)
  signal FFBit:integer range 0 to 13 ;--bit with 7.7kHz frequency(13)    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!CHANGE IT TO PROPER VALUES
  signal SFBit:integer range 0 to 25;--bit with period 0.25 sec(24)
  signal DFBit:integer range 0 to 13;--bit with period of 0.13ms(13)
  signal F_0_03Bit:integer range 0 to 21;--bit with period of 0.03 sec(21)

begin
process(clk,rst)
begin 

	if rst='1' then 
		VFFBit<=10;
		FFBit<=13;
		SFBit<=25;
		DFBit<=13;
		F_0_03Bit<=21;
	elsif rising_edge(clk) then
		if DIV='1' then
			VFFBit<=0;
			FFBit<=13;
			SFBit<=15;
			DFBit<=13;
			F_0_03Bit<=11;
		else
			VFFBit<=10;
			FFBit<=13;
			SFBit<=25;	---------CHANGE THIS FOR SIMULATION
			DFBit<=13;
			F_0_03Bit<=21;
		end if;
		end if;
end process;

SW<=counter(SFBit);
--generate different frequencies         
 process(clk, rst)
  begin
    if rst = '1' then
		counter <= (others => '0');
    elsif rising_edge(clk) then
		counter <= counter+1;
    end if;
  end process;
  
--detector of rising edge of F_0_03 bit
 F_0_03risingEdgeDetector: process(clk,rst)
  begin
	if rst ='1' then
		Q1_0_03<='0';
		Q2_0_03<='0';
	elsif rising_edge(clk) then
		Q1_0_03<=counter(F_0_03Bit);
		Q2_0_03<=Q1_0_03;
	end if;
  end process;
--generate pulse after every 0.0335seconds
  F_0_03<= Q1_0_03 and not(Q2_0_03);
 
--counts 0.032 impulses to 3
 F_0_1Generator: process(clk,rst)
 begin
 if rst='1' then
	C_0_1<=(others=>'0');
elsif rising_edge(clk) then 
	if EF_0_1='1' then
		if F_0_03='1' then
			if C_0_1=2 then
				C_0_1<=(others=>'0');
				R_0_1<='1';
			else 
				C_0_1<=C_0_1+1;
			end if;
		else 
			R_0_1<='0';
		end if;
	else 
		C_0_1<=(others=>'0');
	end if;
end if;
end process;
 --creating 0.1 period signal
F_0_1 <='1' when R_0_1='1' else '0';

--risign edge of VFFBit
VFFRisingEdge:process(clk,rst)
begin
	if rst='1' then
		Q1_VFF<='0';
		Q2_VFF<='0';
	elsif rising_edge(clk) then
		Q1_VFF<=counter(VFFBit);
		Q2_VFF<=Q1_VFF;
	end if;
  end process;
--generate pulse with VFF
  VFF<= Q1_VFF and not(Q2_VFF);
  
--risign edge of FFBit
FFRisingEdge:process(clk,rst)
begin
	if rst='1' then
		Q1_FF<='0';
		Q2_FF<='0';
	elsif rising_edge(clk) then
		Q1_FF<=counter(FFBit);
		Q2_FF<=Q1_FF;
	end if;
  end process;
--generate pulse with FF
  FF<= Q1_FF and not(Q2_FF);
  
--risign edge of SFBit
SFRisingEdge:process(clk,rst)
begin
	if rst='1' then
		Q1_SF<='0';
		Q2_SF<='0';
	elsif rising_edge(clk) then
		Q1_SF<=counter(SFBit);
		Q2_SF<=Q1_SF;
	end if;
  end process;
--generate pulse with SF
  SF<= Q1_SF and not(Q2_SF);  
  
  --risign edge of DFBit
DFRisingEdge:process(clk,rst)
begin
	if rst='1' then
		Q1_DF<='0';
		Q2_DF<='0';
	elsif rising_edge(clk) then
		Q1_DF<=counter(DFBit);
		Q2_DF<=Q1_DF;
	end if;
  end process;
--generate pulse with DF
  DF<= Q1_DF and not(Q2_DF); 
  
  

 end behavioral;



