#!/bin/python3
from ast import parse
from audioop import add
import sys
import typing as T
import argparse

from vipy.regbank.reader import CSVReader
cmds = {
    1 : "READ",
    2 : "WRITE"
}

def cmd_to_str(cmd : int) :
    if cmd in cmds :
        return cmds[cmd]
    else :
        f"CMD 0x{cmd:02X}"



class Decoder:
    def __init__(self) -> None:
        self.miso : str = ""
        self.mosi : str = ""
        self.pol  = 0
        self.pha  = 1
        self.last_clk = "0"
        self.last_csn = "1"

        self.suffix = 0
        
        self.length = 16
        self.cnt = 0
        self.time_start = 0
        self.time_stop = 0
        self.time_end_cmd = 0
        self.time_start_data = 0
        self.frame_started = False

        self._overall_frame = list()
        self._cmd_detail_mosi = list()
        self._cmd_detail_miso = list()

        csv = CSVReader()
        csv.read_csv("../../rtl/regbank/definition/hamster_regbank.csv")
        self.rb = csv.current_rb

    @property
    def send_edge(self):
        falling = self.pol != 0
        falling = falling != (self.pha != 0)
        if falling :
            return "1","0"
        else :
            return "0","1"
    
    def addr_to_str(self, addr : int) :
        reg = self.rb.get_register(addr)
        if reg is None :
            return f"ADDR 0x{addr:02X}"
        else :
            return f"{reg.name} {addr:02X}"


    def add_vector(self, time, vect : str) -> bool :
        csn,clk,mosi,miso = (x for x in vect)
        if (self.last_csn,csn) == ("1","0") :
            self.last_csn = csn
            self.time_start = time
        if (self.last_csn,csn) == ("0","1") :
            self.last_csn = csn
            self.time_stop = time
            self.cnt = 0
            self.add_frame()

        if(csn == "1") :
            self.miso = ""
            self.mosi = ""
            self.frame_started = False
        
        if(self.last_csn,csn) == ("0","0") :
            if(self.last_clk,clk) == self.send_edge :
                self.miso += miso
                self.mosi += mosi
                self.cnt += 1
                if not self.frame_started :
                    if self.cnt == 8 :
                        self.time_end_cmd = time
                    elif self.cnt == 16:
                        self.compute_command()
                        self.cnt = 0
                        self.frame_started = True
                        self.time_start_data = time
                        self.mosi = ""
                        self.miso = ""
                elif self.cnt == 16:
                    self.record_data(self.time_start_data)
                    self.time_start_data = time
                    self.mosi = ""
                    self.miso = ""
            self.last_clk = clk
                
    def compute_command(self) :
        ret = ""
        cmd = int(self.mosi[:8],2)
        addr = int(self.mosi[8:16],2)

        ret += f"#{self.time_start} ?forestgreen?{cmd_to_str(cmd)}\n"
        ret += f"#{self.time_end_cmd} ?darkgreen?{self.addr_to_str(addr)}\n"
        self._cmd_detail_mosi.append(ret)

    def record_data(self,time) :
        mosi_val = int(self.mosi,2)
        miso_val = int(self.miso,2)
        if mosi_val != 0 :
            self._cmd_detail_mosi.append(f"#{time} ?darkgreen?0x{mosi_val:04X}\n")
        elif "?" in self._cmd_detail_mosi[-1]:

            self._cmd_detail_mosi.append(f"#{time}\n")

        if miso_val != 0 or len(self._cmd_detail_miso) == 0:
            self._cmd_detail_miso.append(f"#{time} ?darkgreen?0x{miso_val:04X}\n")
        elif "?" in self._cmd_detail_miso[-1] :
            self._cmd_detail_miso.append(f"#{time}\n")
        

    def add_frame(self):
        if len(self._overall_frame) > 0 and self._overall_frame[-1] == f"#{self.time_start}":
            self._overall_frame.pop()
        self._overall_frame.append(f"#{self.time_start} ?steelblue?Frame")
        self._overall_frame.append(f"#{self.time_stop}")
        if "?" in self._cmd_detail_mosi[-1]:
            self._cmd_detail_mosi.append(f"#{self.time_stop}")
        if "?" in self._cmd_detail_miso[-1] :
            self._cmd_detail_miso.append(f"#{self.time_stop}")

    def print_all(self):
        print(f"$name SPI Decoded")
        print("#0")
        print("\n".join(self._overall_frame))
        print("$next")
        print(f"$name Details MOSI")
        print("#0")
        print("\n".join(self._cmd_detail_mosi))
        print("$next")
        print(f"$name Details MISO")
        print("#0")
        print("\n".join(self._cmd_detail_miso))
        print("$finish")


if __name__ == "__main__" :

    parser = argparse.ArgumentParser()
    parser.add_argument("--csn", default = "i_cs_n",help="CSN signal name")
    parser.add_argument("--clk", default = "i_spi_clk",help="CLK signal name")
    parser.add_argument("--mosi", default = "i_mosi",help="MOSI signal name")
    parser.add_argument("--miso", default = "o_miso",help="MISO signal name")

    args = parser.parse_args()
    mapping_source = {
        args.csn : 0,
        args.clk : 1,
        args.mosi : 2,
        args.miso : 3
        }

    mapping_vcd = dict()

    dec = Decoder()

    data = sys.stdin.readline()
    started = False
    output = ["0","0","0","0"]
    while True :
        if data.startswith("$var") :
            fields = data.split()
            name = fields[4]
            vcdid= fields[3]
            if name in mapping_source :
                mapping_vcd[vcdid] = mapping_source[name]
                sys.stderr.write(f"Mapping {name} with id {vcdid} matching position {mapping_source[name]}\n")
        if data.startswith("$comment data_end") :
            break
        if data.startswith("#") :
            t = int(data[1:])
        if data.startswith("1") or data.startswith("0") :
            output[mapping_vcd[data[1]]] = data[0]
            started = started or output[0] == "1"
            if started:
                dec.add_vector(t,output)
        data = sys.stdin.readline()


    dec.print_all()


    


