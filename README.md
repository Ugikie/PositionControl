# PositionControl

> *Copyright 2019 [Austin Adam](https://github.com/Ugikie)*

**Position Control** is a ready-to-use Matlab library to control the MI-4190 position controller and automate measurements with a USRP N310


### Table of contents

- [Prerequisites](#prerequisites)
- [Running An Automated Measurement](#running-an-automated-measurement)
- [Logging](#logging)


## Prerequisites
- You need to be using Matlab R2019b or later, and on Linux platform. Ubuntu 19.04 LTS was used for the creation of the scripts, so has not been tested on the other Linux versions.

## Running An Automated Measurement
- In order to use the script, you will have to connect a computer to the MI-4190 Position Controller. One can be found in the CSUN Microwave Lab. Use a GPIB-USB serial adapter, and make sure the primary address of the device is set to 4. 
- Next, the USRP N310 and USRP N210 must be plugged in, hooked up to the switch, and turned on. The Matlab script will run the bootup commands for the USRPs including `uhd_usrp_probe`, so you must only plug them in and switch the N310 on via the power button on the front.
- Now, the script is ready to run, just open the `/System/PositionController.m` file and click run. A load bar should appear, and the script will proceed to ask you for an input of your desired increment size.
- A log of the output will be created in the `/Misc/Logs` folder that contains an output of the entire measurement run. It will however contain some command information, as it was created using the `diary` command.

## Logging
- Each time you run the program, a log file will be generated in `/Misc/Logs` that is named appropriately with the exact time and date of the moment you clicked the `run` button. You can however provide an optional filename to the log file, that will go at the beginning of the timestamp in the file name. For example, the default file name will look something like:

```
Nov-23-19_18.40.14_log.txt
```
However, you can add the optional file name simply by changing the input variable to the `logFilePath()` command to your desired log file name. For example on line 3 of `/System/PositionController.m` change the function call to:
```
[logFileName,logFile] = logFilePath('desiredFilename');
```
And you will get a log file that is named:
```
desiredFileName_Nov-23-19_18.40.14_log.txt
```
