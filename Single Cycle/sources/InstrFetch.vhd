----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.03.2023 12:38:07
-- Design Name: 
-- Module Name: InstrFetch - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity InstrFetch is
    Port ( en : in STD_LOGIC;
           clk : in STD_LOGIC;
           pc_src: in STD_LOGIC;
           jmp : in STD_LOGIC;
           brAddr : in STD_LOGIC_VECTOR(15 downto 0);
           jAddr : in STD_LOGIC_VECTOR(15 downto 0);
           pcPlus : out STD_LOGIC_VECTOR (15 downto 0);
           instr : out STD_LOGIC_VECTOR (15 downto 0);
           reset : in std_logic);
end InstrFetch;

architecture Behavioral of InstrFetch is


signal q : std_logic_vector(15 downto 0) ;
signal d : std_logic_vector(15 downto 0);
signal sum_result : std_logic_vector(15 downto 0);
signal pc_in: std_logic_vector(15 downto 0);


type mem_rom is array (0 to 32) of std_logic_vector (15 downto 0);
signal ROM : mem_rom:= ( 

    b"001_000_001_0000001", -- 2081 0.	addi $1,$0,1 --i=1
    b"001_000_010_0000101" ,-- 2105 1.    addi $2,$0,5 --j=5 -- la 5 se opreste ( functioneaza ca while) 
    b"001_000_011_0000000", -- 2180 2.    addi $3,$0,0 --sum1=0
    b"001_000_100_0000000", -- 2200 3.    addi $4,$0,0 --sum2=0
    b"000_010_001_101_0_000", -- 08D0 4.    add $5,$2,$1 --n = i+j
    b"000_000_101_101_1_011", -- 02DB 5.    srl $5,$5,1 --n/2 --  marchez jumatatea vectorului
    
    b"100_010_001_0001100", --  8888 6.    loop_st: beq $1,$2,loop_end = 8 -- deschide bucla
    
    b"001_000_110_0000001",--  2301 13.     addi $6,$0,1 -- $6=0001
    b"000_110_001_111_0_100", -- 18F4 4.    and $7,$6,$1 $7 = 1 daca e i impar, 0 altfel  
      
    b"100_111_000_0000100", -- 9C82 9.    beq $7,$0,par=2 -- verifica daca i par
    
    -----------
    b"010_001_101_0000000", --4780  lw $5,  $1
     b"000_101_000_101_0_000", -- 1C70 4.    add $5,$5,$0 --n = i+j
        
    b"000_011_101_011_0_000",  -- eb0 12.    impar: add $3,$3,$5
    b"111_0000000010001", --  E011 14.    jmp incr = 17
    ----------
  b"010_001_101_0000000", --4780  lw $5,  $1
       b"000_101_000_101_0_000", -- 1C70 4.    add $5,$5,$0 --n = i+j
     
    b"000_100_101_100_0_000",  -- 12C0 12.    par: add $4,$4,$5
    b"001_001_001_0000001",--  2481 13.    incr: addi $1,$1,1
    b"111_0000000000110", --  E006 14.    jmp 6 --loop_st 
    
    b"100_011_100_0000010", -- 8E01 15.    loop_end: beq $3,$4, equal
    
    b"001_000_001_0000000",--  2080 13.     addi $1,$0,0 -- $6=0001
    b"111_0000000010111", --  E017 14.    jmp done
    b"001_000_001_0000001",--  2081 13.     addi $1,$0,1 -- $6=0001
    
    b"000_001_000_001_0_000", -- 410 4.   --done add $1,$1,$0 --n = i+j
    b"100_001_001_0000100", --8484  sw $1,  $1

    others =>x"1110000000000011"
);

--when "000" => out_ssd <= instr;
--when "001" => out_ssd <= pcplus;
--when "010" => out_ssd <= rd1;
--when "011" => out_ssd <= rd2;
--when "100" => out_ssd <= ext_imm;
--when "101" => out_ssd <= alures;
--when "110" => out_ssd <= memdata;
--when "111" => out_ssd <= wd;


begin


instr<=ROM(conv_integer (q(7 downto 0)));

pcPlus<=q+1;
sum_result<=q+1;
-- registru PC
process(clk)
begin
if(rising_edge(clk))then
   if reset='1' then
     q<="0000000000000000";
     elsif(en='1') then
        q<=d;
     end if;
end if;
end process;



--mux pc_src

process(pc_src,brAddr,sum_result)
begin
case pc_src 
is
when '0' => pc_in <= sum_result;
when '1' => pc_in <= brAddr;
end case;
end process;


-- mux jmp

process(jmp,pc_in,jAddr) begin
case jmp is
when '0' => d<=pc_in;
when '1' => d<=jAddr;
end case;
end process;




--case sw(15 downto 13) is
--when "000" => out_ssd <= instr;
--when "001" => out_ssd <= pcPlus;
--when "010" => out_ssd <= alures;
--when "011" => out_ssd <= rd1;
--when "100" => out_ssd <= rd2;
--when "101" => out_ssd <= ext_imm;
--when "110" => out_ssd <= jumpAddr;
--when others => out_ssd <= x"0000";


-- rom

--rom(0)<=b"0010000010000001"; -- 1 --2081 0.	addi $1,$0,1 --i=1
--rom(1)<=b"0010000100000010"; -- 2 --210C 1.	addi $2,$0,4 --j=4
--rom(2)<=b"0010000110000000"; -- 3 --2180 2.	addi $3,$0,0 --sum1=0
--rom(3)<=b"0010001000000000"; -- 4 --2200 3.	addi $4,$0,0 --sum2=0
--rom(4)<=b"0000100011010000"; -- 5 --08D0 4.	add $5,$3,$1 --n = i+j
--rom(5)<=b"0001010001010000"; -- 6 --1450 5.	srl $5,$5,1 --n/2
--rom(6)<=b"1000100010001000"; -- 7 --8888 6.	loop_st: beq $1,$2,loop_end = 8 --1000100010001000
--rom(7)<=b"0000011011100001"; -- 8 --06E1 7.	sub $6,$1,$5
--rom(8)<=b"1101101110000000";  -- 9 --DB80 8.	slti $7,$6,0 
--rom(9)<=b"1000001110000010";  -- 10 --8383 9.	beq $7,$0,mare=2 --1000001110000010
--rom(10)<=b"0000110010110000"; -- 11 --0CB0 10.	add $3,$3,$1
--rom(11)<=b"1110000000001101"; -- 12 --E00D 11.	jmp 13 incr
--rom(12)<=b"0001000011000000"; -- 13 --10C0 12.	mare: add $4,$4,$1
--rom(13)<=b"0010010010000001"; -- 14 --2481 13.	incr: addi $1,$1,1
--rom(14)<=b"1110000000000110"; -- 15 --E006 14.	jmp 6 --loop_st 
--rom(15)<=b"0000111000010001"; -- 16 --0E11 15.	loop_end: sub $1,$3,$4
--rom(16)<=b"1100010100000000"; -- 17 --C500 16.	slti $2,$1,0
--rom(17)<=b"1000000010000010"; -- 18 --8082 17.	beq $2,$0,greater_equal=2 --1000000010000010
--rom(18)<=b"0010001110000001"; -- 19 --2381 18.	addi $7,$0,1
--rom(19)<=b"1110000000011000"; -- 20 --E018 19.	jmp 24 -- done --
--rom(20)<=b"1000010000000010"; -- 21 --8402 20.	greater_equal: beq $1,$0,equal=2 --1000010000000010
--rom(21)<=b"0010001110000011"; -- 22 --2383 21.	addi $7,$0,3
--rom(22)<=b"1110000000011000"; -- 23 --E018 22.	jmp 24 done
--rom(23)<=b"0010001110000010"; -- 24 --2382 23.	equal: addi $7,$0,2
--rom(24)<=b"0110001111010000"; -- 25 --63D0 24.	done: sw $7,80??

--rom(0)<=b"001_000_001_0000001";
--rom(1)<=b"001_000_010_0000100";
--rom(2)<=b"001_000_010_0000100";
--rom(3)<=b"001_000_011_0000000";
--rom(4)<=b"001_000_001_0000000";
--rom(5)<=b"000_011_001_101_0_001";
--rom(6)<=b"000_000_101_101_1_011";
--rom(7)<=b"100_010_001_0001000";
--rom(8)<=b"000_001_101_110_0_001";
--rom(9)<=b"001_000_001_0000000";


end Behavioral;
