library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Debouncer is
Port (
	clk: in STD_LOGIC;
	reset : in std_logic;
	boton : in STD_LOGIC;
	DF: in std_logic; --divider frecuecny
	filtrado : out STD_LOGIC
);
end Debouncer;


architecture behavioral of Debouncer is
-- Sincronizador--
	signal Q1: std_logic;
	signal b : std_logic;-- Q2
-- detector de flancos--
	signal flanco: std_logic;
	signal Q3: std_logic;
-- declaracion de FSM ----
	type state_t is (S_NADA, S_BOTON, S_HOLD);
	signal state : state_t;
-- Temporizador--
	constant MAX: integer :=(125*10**3);--**6
	signal E : std_logic;
	signal T : std_logic;
	
	
-- contador de 0 a 6. para contar tiempo a partir de nuestro divisor de frecuencia
	signal count_seven: integer range 0 to 7;
	
	
begin

			

--Sincronizador
process(clk,reset)
begin
	if reset = '1' then
		Q1 <= '0';
	elsif clk'event and clk ='1' then
		if boton ='1' then
		Q1<='1';
		elsif boton='0' then
		Q1<='0';
		end if;
	end if;
end process;
process(clk,reset)
begin
	if reset = '1' then
		b <= '0';
	elsif clk'event and clk ='1' then
		if Q1 ='1' then
		b<='1';
		elsif Q1='0' then
		b<='0';
		end if;
	end if;
end process;

--DETECTOR DE FLANCOS
process(clk,reset)
begin
	if reset = '1' then
		Q3 <= '0';
	elsif clk'event and clk ='1' then
		if b ='1' then
			Q3<='1';
		elsif b='0' then
			Q3<='0';
		end if;
	end if;
end process;

--Negar Q3 y puerta AND
flanco<= not (Q3) and b;

---Implementacion de FSM explicita-- (ecuaciones de estado)
process(clk,reset)
begin
	if reset = '1' then
		state <= S_NADA;
	elsif clk'event and clk ='1' then
		case state is
			when S_NADA =>
						if flanco = '1' then
						state <= S_BOTON;
						end if;
			when S_BOTON =>
						if T = '1' then
						state <=S_HOLD;
						end if;
			when S_HOLD =>
						if b='0' then
						state <=S_NADA;
						end if;
		end case;
	end if;
end process;

-- ecuaciones de salida
filtrado <= '1' when state = S_HOLD and b='1' else '0'; -- Mealy, T es 1 en la
--transicion de estados
E <= '1' when state = S_BOTON else '0'; -- Moore

--contador de 0 a 7
process(clk, reset)
begin
	if reset='1' then
		count_seven<=0;
	elsif clk'event and clk='1' then
		if count_seven<7 then
			if DF<='1' and E='1' then
			count_seven<=count_seven+1;
			end if;
		else
			count_seven<=0;
		end if;
	end if;
end process;

T<='1' when count_seven=7 and E='1' else '0';

end behavioral;

