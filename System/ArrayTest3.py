#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: Arraytest3
# Generated: Sat Nov 23 16:27:08 2019
##################################################

from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import gr
from gnuradio import uhd
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from optparse import OptionParser
import time
import sys
import datetime
import os


class ArrayTest3(gr.top_block):

    def __init__(self):
        gr.top_block.__init__(self, "Arraytest3")

        ##################################################
        # Variables
        ##################################################
        self.samp_rate = samp_rate = 1e6
        self.gain = gain = 60
        self.center_frequency = center_frequency = 1949.95e6
        self.bandwidth = bandwidth = 100e6

        ##################################################
        # Blocks
        ##################################################
        self.uhd_usrp_source_0 = uhd.usrp_source(
        	",".join(('addr=192.168.10.2', 'rx_lo_source=external,init_cals=BASIC|TX_ATTENUATION_DELAY|RX_GAIN_DELAY|PATH_DELAY|TX_LO_LEAKAGE_INTERNAL|LOOPBACK_RX_LO_DELAY')),
        	uhd.stream_args(
        		cpu_format="fc32",
        		channels=range(4),
        	),
        )
        self.uhd_usrp_source_0.set_clock_source('internal', 0)
        self.uhd_usrp_source_0.set_subdev_spec("A:0 A:1 B:0 B:1", 0)
        self.uhd_usrp_source_0.set_samp_rate(samp_rate)
        self.uhd_usrp_source_0.set_time_unknown_pps(uhd.time_spec())
        self.uhd_usrp_source_0.set_center_freq(center_frequency, 0)
        self.uhd_usrp_source_0.set_gain(gain, 0)
        self.uhd_usrp_source_0.set_antenna('RX2', 0)
        self.uhd_usrp_source_0.set_bandwidth(bandwidth, 0)
        self.uhd_usrp_source_0.set_center_freq(center_frequency, 1)
        self.uhd_usrp_source_0.set_gain(gain, 1)
        self.uhd_usrp_source_0.set_antenna('RX2', 1)
        self.uhd_usrp_source_0.set_bandwidth(bandwidth, 1)
        self.uhd_usrp_source_0.set_center_freq(center_frequency, 2)
        self.uhd_usrp_source_0.set_gain(gain, 2)
        self.uhd_usrp_source_0.set_antenna('RX2', 2)
        self.uhd_usrp_source_0.set_bandwidth(bandwidth, 2)
        self.uhd_usrp_source_0.set_center_freq(center_frequency, 3)
        self.uhd_usrp_source_0.set_gain(gain, 3)
        self.uhd_usrp_source_0.set_antenna('RX2', 3)
        self.uhd_usrp_source_0.set_bandwidth(bandwidth, 3)
        self.blocks_head_0_1 = blocks.head(gr.sizeof_gr_complex*1, 2000000)
        self.blocks_head_0_0_0 = blocks.head(gr.sizeof_gr_complex*1, 2000000)
        self.blocks_head_0_0 = blocks.head(gr.sizeof_gr_complex*1, 2000000)
        self.blocks_head_0 = blocks.head(gr.sizeof_gr_complex*1, 2000000)


        #st = datetime.datetime.fromtimestamp(time.time()).strftime('%H:%M:%S')
        degreeIncrements = sys.argv[1]
        dateAndTime = sys.argv[2]
        currentDegree = sys.argv[3]
        if (not os.path.exists('/home/ugikie/Documents/USRP_DATA/Inc_' + degreeIncrements)):
            os.mkdir('/home/ugikie/Documents/USRP_DATA/Inc_' + degreeIncrements)
        if (not os.path.exists('/home/ugikie/Documents/USRP_DATA/Inc_' + degreeIncrements + '/ArrayTest_' + dateAndTime)):
            os.mkdir('/home/ugikie/Documents/USRP_DATA/Inc_' + degreeIncrements + '/ArrayTest_' + dateAndTime)
        self.blocks_file_sink_0_2 = blocks.file_sink(gr.sizeof_gr_complex*1, '/home/ugikie/Documents/USRP_DATA/Inc_' + degreeIncrements + '/ArrayTest_' + dateAndTime + '/ArrayTest3_' + currentDegree, False)
        self.blocks_file_sink_0_2.set_unbuffered(False)
        self.blocks_file_sink_0_1 = blocks.file_sink(gr.sizeof_gr_complex*1, '/home/ugikie/Documents/USRP_DATA/Inc_' + degreeIncrements + '/ArrayTest_' + dateAndTime + '/ArrayTest0_' + currentDegree, False)
        self.blocks_file_sink_0_1.set_unbuffered(False)
        self.blocks_file_sink_0_0 = blocks.file_sink(gr.sizeof_gr_complex*1, '/home/ugikie/Documents/USRP_DATA/Inc_' + degreeIncrements + '/ArrayTest_' + dateAndTime + '/ArrayTest1_' + currentDegree, False)
        self.blocks_file_sink_0_0.set_unbuffered(False)
        self.blocks_file_sink_0 = blocks.file_sink(gr.sizeof_gr_complex*1, '/home/ugikie/Documents/USRP_DATA/Inc_' + degreeIncrements + '/ArrayTest_' + dateAndTime + '/ArrayTest2_' + currentDegree, False)
        self.blocks_file_sink_0.set_unbuffered(False)



        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_head_0, 0), (self.blocks_file_sink_0_1, 0))
        self.connect((self.blocks_head_0_0, 0), (self.blocks_file_sink_0_0, 0))
        self.connect((self.blocks_head_0_0_0, 0), (self.blocks_file_sink_0_2, 0))
        self.connect((self.blocks_head_0_1, 0), (self.blocks_file_sink_0, 0))
        self.connect((self.uhd_usrp_source_0, 0), (self.blocks_head_0, 0))
        self.connect((self.uhd_usrp_source_0, 1), (self.blocks_head_0_0, 0))
        self.connect((self.uhd_usrp_source_0, 3), (self.blocks_head_0_0_0, 0))
        self.connect((self.uhd_usrp_source_0, 2), (self.blocks_head_0_1, 0))

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.uhd_usrp_source_0.set_samp_rate(self.samp_rate)

    def get_gain(self):
        return self.gain

    def set_gain(self, gain):
        self.gain = gain
        self.uhd_usrp_source_0.set_gain(self.gain, 0)

        self.uhd_usrp_source_0.set_gain(self.gain, 1)

        self.uhd_usrp_source_0.set_gain(self.gain, 2)

        self.uhd_usrp_source_0.set_gain(self.gain, 3)


    def get_center_frequency(self):
        return self.center_frequency

    def set_center_frequency(self, center_frequency):
        self.center_frequency = center_frequency
        self.uhd_usrp_source_0.set_center_freq(self.center_frequency, 0)
        self.uhd_usrp_source_0.set_center_freq(self.center_frequency, 1)
        self.uhd_usrp_source_0.set_center_freq(self.center_frequency, 2)
        self.uhd_usrp_source_0.set_center_freq(self.center_frequency, 3)

    def get_bandwidth(self):
        return self.bandwidth

    def set_bandwidth(self, bandwidth):
        self.bandwidth = bandwidth
        self.uhd_usrp_source_0.set_bandwidth(self.bandwidth, 0)
        self.uhd_usrp_source_0.set_bandwidth(self.bandwidth, 1)
        self.uhd_usrp_source_0.set_bandwidth(self.bandwidth, 2)
        self.uhd_usrp_source_0.set_bandwidth(self.bandwidth, 3)


def main(top_block_cls=ArrayTest3, options=None):

    tb = top_block_cls()
    tb.start()
    tb.wait()


if __name__ == '__main__':
    main()
