----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.04.2023 16:46:28
-- Design Name: 
-- Module Name: EX - Behavioral
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

entity EX is
    Port ( RD1 : in STD_LOGIC_VECTOR (15 downto 0);
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           Ex_imm : in STD_LOGIC_VECTOR (15 downto 0);
           ALUsrc : in STD_LOGIC;
           sa : in STD_LOGIC;
           func : in STD_LOGIC_VECTOR (2 downto 0);
           ALUop : in STD_LOGIC_VECTOR (2 downto 0);
           Zero : out STD_LOGIC;
           ALURes : inout STD_LOGIC_VECTOR (15 downto 0));
end EX;

architecture Behavioral of EX is
signal aluCtrl:std_logic_vector(3 downto 0);
signal rd2_or_extimm:STD_LOGIC_VECTOR (15 downto 0);
begin

process(aluOp,func)
begin
   case aluOp is
        -- aluCtrl= 0 + func
        when "000" => aluCtrl <= "0" & func;
        when "001" => aluCtrl <= "0000"; -- addi,lw,sw => +
        when "010" => aluCtrl <= "0001"; -- beq,bne => -
      --  when "011" => aluCtrl <= "0000"; -- sw; +
        --when "100" => aluCtrl <= "0001"; -- beq; -
       -- when "101" => aluCtrl <= "0001"; -- bne; -
        when "110" => aluCtrl <= "1000"; -- slti; <
        when "111" => aluCtrl <= "1111"; -- jmp; DK 
        when others => aluCtrl <= "0000"; -- 
    end case;
end process;


-- mux pentru rd2/ext_imm

process(alusrc) begin

case alusrc is
when '0' => rd2_or_extimm<=rd2;
when '1' => rd2_or_extimm<=Ex_imm;
end case;
end process;


-- alu 

process(aluctrl,rd1,sa,alures,rd2_or_extimm)
begin
case(aluCTRL) is
    when "0000" => aluRes<= rd1 + rd2_or_extimm;
    when "0001" => aluRes<= rd1 - rd2_or_extimm;
    when "0010" =>
        if sa='1' then
        aluRes <= rd2_or_extimm(14 downto 0) & "0";
        end if; -- shiftare la stanga cu o pozitie cand sa=1 
    when "0011" =>
            if sa='1' then
            aluRes <= "0" & rd2_or_extimm(15 downto 1);
            end if; -- shiftare logica la dreapta cu o pozitie cand sa=1 
    when "0100" => aluRes<= rd1 and rd2_or_extimm; 
    when "0101" => aluRes<= rd1 or rd2_or_extimm; 
    when "0110" => aluRes<= rd1 xor rd2_or_extimm; 
    when "0111" =>
            if sa='1' then
                if(rd1(0)='1') then
                aluRes <= "1" & rd2_or_extimm(15 downto 1);
                else
                aluRes <= "0" & rd2_or_extimm(15 downto 1);
                end if;
            end if; -- shiftare aritmetica la dreapta cu o pozitie cand sa=1  
     when "1000"=>
     --slti
                if(signed(rd1)<signed(rd2_or_extimm)) then 
                    aluRes<=x"0001";
                    else
                    aluRes<=x"0000";
                    end if;
     when others => 
                aluRes<=x"0000";
end case;

    if aluRes = x"0000" then
    zero<='1';
    else
    zero<='0';
    end if;
end process;

end Behavioral;
