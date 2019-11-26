# PositionControl

> *Copyright 2019 [Austin Adam](https://github.com/Ugikie)*

**Position Control** is a ready-to-use Matlab library to control the MI-4190 position controller and automate measurements with a USRP N310


### Table of contents

- [Prerequisites](#prerequisites)
- [Running An Automated Measurement](#running-an-automated-measurement)


## Prerequisites
- You need to be using Matlab R2019b or later, and on Linux platform. Ubuntu 19.04 LTS was used for the creation of the scripts, so has not been tested on the other Linux versions.

## Running An Automated Measurement
- In order to use the script, you will have to connect a computer to the MI-4190 Position Controller. One can be found in the CSUN Microwave Lab. Use a GPIB-USB serial adapter, and make sure the primary address of the device is set to 4. 
- Next, the USRP N310 and USRP N210 must be plugged in, hooked up to the switch, and turned on. The Matlab script will run the bootup commands for the USRPs including `uhd_usrp_probe`, so you must only plug them in and switch the N310 on via the power button on the front.
- Now, the script is ready to run, just open the `/System/PositionController.m` file and click run. A load bar should appear, and the script will proceed to ask you for an input of your desired increment size.
- A log of the output will be created in the `/Misc/Logs` folder that contains an output of the entire measurement run. It will however contain some command information, as it was created using the `diary` command.
