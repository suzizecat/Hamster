#!/bin/python3
from ast import parse
import sys
import typing as T
import argparse

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

        self._overall_frame = list()
        self._cmd_detail = list()

    @property
    def send_edge(self):
        falling = self.pol != 0
        falling = falling != (self.pha != 0)
        if falling :
            return "1","0"
        else :
            return "0","1"
    
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
        
        if(self.last_csn,csn) == ("0","0") :
            if(self.last_clk,clk) == self.send_edge :
                self.miso += miso
                self.mosi += mosi
                self.cnt += 1
                if self.cnt == 8 :
                    self.compute_command(time)
                elif self.cnt == 16:
                    self.start_data(time)
            self.last_clk = clk
                
    def compute_command(self,time) :
        ret = ""
        ret += f"#{self.time_start} ?forestgreen?CMD\n"
        ret += f"#{time} ?darkgreen?ADDR\n"
        self._cmd_detail.append(ret)

    def start_data(self,time) :
        ret = ""
        ret += f"#{time} ?darkgreen?Data\n"
        self._cmd_detail.append(ret)
        

    def add_frame(self):
        ret = ""
        ret += f"#{self.time_start} ?steelblue?Frame\n"
        ret += f"#{self.time_stop}\n"
        self._overall_frame.append(ret)
        self._cmd_detail.append(f"#{self.time_stop}")

    def print_all(self):
        print(f"$name SPI Decoded")
        print("#0")
        print("\n".join(self._overall_frame))
        print("$next")
        print(f"$name Details")
        print("#0")
        print("\n".join(self._cmd_detail))
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


    


