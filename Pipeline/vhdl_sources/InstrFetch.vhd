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


type mem_rom is array (0 to 128) of std_logic_vector (15 downto 0);
signal ROM : mem_rom:= ( 

    b"000_000_000_000_0_000", --noop

    b"001_000_001_0000001", -- 2081 0.	addi $1,$0,1 --i=1 
    b"001_000_010_0000101" ,-- 2105 1.    addi $2,$0,5 --j=5 -- la 5 se opreste ( functioneaza ca while) 
    b"001_000_011_0000000", -- 2180 2.    addi $3,$0,0 --sum1=0
    b"001_000_100_0000000", -- 2200 3.    addi $4,$0,0 --sum2=0
    b"000_010_001_101_0_000", -- 08D0 4.    add $5,$2,$1 --n = i+j
    
    --
    b"000_000_000_000_0_000", --noop
    b"000_000_000_000_0_000", --noop ok
    --
    
    --aici vezi daca pune ce trebuie in 2
    b"000_000_101_101_1_011", -- 02DB 5.    srl $5,$5,1 --n/2 --  marchez jumatatea vectorului
    
    
    ----------------------------------------------------------------------------------------
    b"100_010_001_0100000", --  88A0  6.    loop_st: beq $1,$2,loop_end = 32 -- deschide bucla 
    
    ---
    b"000_000_000_000_0_000", --noop 7.
    b"000_000_000_000_0_000", --noop 8.
    b"000_000_000_000_0_000", --noop 9.
    ---
    
    b"001_000_110_0000001",--  2301 10.     addi $6,$0,1 -- $6=0001
    
    ---
    b"000_000_000_000_0_000", --noop 11.
    b"000_000_000_000_0_000", --noop 12.
    ---                                         --verifica aici ce ai in 6 si in 1
    b"000_110_001_111_0_100", -- 18F4 13.    and $7,$6,$1 $7 = 1 daca e i impar, 0 altfel    
    ---                                         --VEZI AICI DACA ITI PUNE 1 IN 6
    b"000_000_000_000_0_000", --noop 14. --> aici e falling edge deci resultatul corect apare in alures (urm instr) dar in rd2 nu apuca sa se completeze
    b"000_000_000_000_0_000", --noop 15. --ex--> alu res e ok --> 

    ---   
    --    b"100_010_001_0100000", --  88A0  6.    loop_st: beq $1,$2,loop_end = 32 -- deschide bucla 

    b"100_111_000_0001100", -- 9C0C 16.    beq $7,$0,par=12 -- verifica daca i par --4e05  ------------------- AICI
    ---
    b"000_000_000_000_0_000", --noop 17.
    b"000_000_000_000_0_000", --noop 18.
    b"000_000_000_000_0_000", --noop 19.
    ---
    
    b"010_001_101_0000000", --4680  20. lw $5,  $1
    ---    
    b"000_000_000_000_0_000", --noop 21. 
    b"000_000_000_000_0_000", --noop 22. 
    ---
    
    
    b"000_101_000_101_0_000", -- 1450 23.    add $5,$5,$0  
    ---    
    b"000_000_000_000_0_000", --noop 24.
    b"000_000_000_000_0_000", --noop 25. --imi da 4 la alu res (pe urmatorul ca in memorie se numara de la 0 si eu incep cu index-ul 1)
    --- 
    
    b"000_011_101_011_0_000",  -- 0EB0 26.    impar: add $3,$3,$5
   b"111_0000000100111", --  E026 27.    jmp incr = 38 
    
    
    ---
    b"000_000_000_000_0_000", --noop 28. -- de aici incep sa calculez pt cel cu index par
    --- 
    ---CRED CA TRB SA TREACA SI DE NOOP
    
    b"010_001_101_0000000", --4680  lw $5,  $1
    ---    
    b"000_000_000_000_0_000", --noop
    b"000_000_000_000_0_000", --noop
    --- 
    
    
    b"000_101_000_101_0_000", -- 1470 4.    add $5,$5,$0   
    ---    
    b"000_000_000_000_0_000", --noop
    b"000_000_000_000_0_000", --noop
    --- 
    
    b"000_100_101_100_0_000",  -- 12C0 12.    par: add $4,$4,$5 
    
    --------------------------------------------------------------------------- INCR 
    b"001_001_001_0000001",--  2481 13.    incr: addi $1,$1,1
    b"111_0000000001001", --  E008 14.    jmp 8 --loop_st  --9
    --    
    b"000_000_000_000_0_000", --noop
    

    --- 
    
    --------------------------------------------------------------------------- END LOOP
    b"100_011_100_0000110", -- 8E06 15.    loop_end: beq $3,$4, equal
    ---
    b"000_000_000_000_0_000", --noop --AICI POT VEDEA REZULTATUL SUMElor ($3 index impar si $4 index par) (E=5+9 si 12hex=18dec = 7 + 11(B))
    b"000_000_000_000_0_000", --noop
    b"000_000_000_000_0_000", --noop
    ---
    
    b"001_000_001_0000000",--  2080 13.     addi $1,$0,0 -- $6=0001
    b"111_0000000110100", --  E033 14.    jmp done=51 /52 
    ---    
    b"000_000_000_000_0_000", --noop
    --- 
    
    b"001_000_001_0000001",--  2081 13.    equal: addi $1,$0,1 -- $6=0001
    
    ---    
    b"000_000_000_000_0_000", --noop
    b"000_000_000_000_0_000", --noop
    --- 
    b"000_001_000_001_0_000", -- 0410 4.   --done add $1,$1,$0 -- ca sa vad ce am in registru 1 pe placuta
    
    
    ---    
    b"000_000_000_000_0_000", --noop
    b"000_000_000_000_0_000", --noop  --aici am result = 0 (nu sunt egale cele 2 sume) sau  =1 (cele 2 sume sunt egale)
    --- 
    b"100_001_001_0000100", --8484  sw $1,  $1
    
    
    
    ---    verific daca sumele retinute in $ 
    
    --ma asigur ca am terminat cu sw (noopx5 safest)
    b"000_000_000_000_0_000", --noop
    b"000_000_000_000_0_000", --noop
    b"000_000_000_000_0_000", --noop
    b"000_000_000_000_0_000", --noop
    b"000_000_000_000_0_000", --noop
    --fac un addi $3,0,0 sa vad ce imi afiseaza pe rd1 
    b"001_000_011_0000000", --2180 	addi $3,$0,0 --i=1 --if

    --ma asigur ca termin cu cea de sus
    b"000_000_000_000_0_000", --noop --aici imi da rd1,rd2 pt aia de sus --id
    b"000_000_000_000_0_000", --noop --ex
    b"000_000_000_000_0_000", --noop --mem
    b"000_000_000_000_0_000", --noop --wb

    --fac un addi $4,0,0 sa vad ce imi afiseaza pe rd1 
    b"001_000_100_0000000", --2200 	addi $4,$0,0 --i=1 
    b"000_000_000_000_0_000", --noop --aici imi da rd1,rd2 pt aia de sus --id
    b"000_000_000_000_0_000", --noop --ex
    b"000_000_000_000_0_000", --noop --mem
    b"000_000_000_000_0_000", --noop --wb
    --- 
    
   
    others =>b"1111111111111111"
);

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


end Behavioral;
