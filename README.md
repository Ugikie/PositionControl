# PositionControl

> *Copyright 2020 [Austin Adam](https://github.com/Ugikie)*

**Position Control** is a ready-to-use Matlab library to control the MI-4190 position controller and automate measurements with a USRP N310


### Table of contents

- [Prerequisites](#prerequisites)
- [What's Included?](#whats-included?)
- [Running An Automated Measurement](#running-an-automated-measurement)
- [Logging](#logging)
- [Future Plans](#future-plans)
- [Known Issues](#known-issues)


## Prerequisites
- You need to be using Matlab R2019b or later, and on Linux platform. Ubuntu 19.04 LTS was used for the creation of the scripts, so has not been tested on the other Linux versions.

## What's Included?

Within the library you'll find the following directories and files:

```text
Automation/
└── PositionControl/
    ├── Docs/
    │   ├── Automation Flowchart.jpg
    ├── Misc/
    │   ├── cprintf/
    │   ├── Example Scripts/
    |   |   ├── AntennaPhiMeasurement.m
    |   |   ├── hp8720saveTrace.m
    |   ├── Logs/
    |   ├── cancelSystem.m
    |   ├── checkForCancel.m
    |   ├── dots.m
    ├── Motion/
    |   ├── incrementAxisByDegree.m
    |   ├── moveAxisToPosition.m
    |   ├── stopAxisMotion.m
    ├── Status/
    │   ├── getAZCurrPos.m
    │   ├── getAZCurrVelocity.m
    |   ├── verifyIfIdle.m
    |   ├── verifyIfInPosition.m
    ├── System/
    |   ├── ArrayTest2.grc
    |   ├── ArrayTest2.py
    |   ├── ArrayTest3.grc
    |   ├── ArrayTest3.py
    |   ├── PositionController.m
    |   ├── testing.m
    ├── USRP/
    |   ├── bootUSRPs.m
    |   ├── pingUSRPs.m
    |   └── usrpErrorChecker.m
    ├── USRPBoot.sh
    └── USRPN210Boot.sh
```

## Running An Automated Measurement
- In order to use the script, you will have to connect a computer to the MI-4190 Position Controller. One can be found in the CSUN Microwave Lab. Use a GPIB-USB serial adapter, and make sure the primary address of the device is set to 4. 
- Next, the USRP N310 and USRP N210 must be plugged in, hooked up to the switch, and turned on. The Matlab script will run the bootup commands for the USRPs including `uhd_usrp_probe`, so you must only plug them in and switch the N310 on via the power button on the front.
- Now, the script is ready to run, just open the `/System/PositionController.m` file and click run. A load bar should appear, and the script will proceed to ask you for an input of your desired increment size.
- A log of the output will be created in the `/Misc/Logs` folder that contains an output of the entire measurement run. It will however contain some command information, as it was created using the `diary` command.

## Logging
Each time you run the program, a log file will be generated in `/Misc/Logs` that is named appropriately with the exact time and date of the moment you clicked the `run` button. You can however provide an optional filename to the log file, that will go at the beginning of the timestamp in the file name. For example, the default file name will look something like:

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

## Future Plans
Here are some ideas for the future of the project. The list will be updated with each new addition to the script, and as items are completed.  
![#54B948](https://placehold.it/15/54B948/000000?text=+) Completed    ![#fdb813](https://placehold.it/15/fdb813/000000?text=+) Work In Progress    ![#f03c15](https://placehold.it/15/f03c15/000000?text=+) Not yet implemented
- ![#54B948](https://placehold.it/15/54B948/000000?text=+) `Add continuous checks for USRP response throughout the code.`
- ![#54B948](https://placehold.it/15/54B948/000000?text=+) `Add prompt for user to input desired VNA frequency.`
- ![#54B948](https://placehold.it/15/54B948/000000?text=+) `Allow user to start/stop/pause VNA signal.`
- ![#54B948](https://placehold.it/15/54B948/000000?text=+) `Fix cancel button on waitbar.`
- ![#54B948](https://placehold.it/15/54B948/000000?text=+) `Speed up verifyIfInPosition.`
- ![#54B948](https://placehold.it/15/54B948/000000?text=+) `Add function to decode status codes.`
- ![#54B948](https://placehold.it/15/54B948/000000?text=+) `Create GUI For entire script with start/stop/pause functionality and command window output. Can select increment amount, control VNA, and save output to file location.`
- ![#54B948](https://placehold.it/15/54B948/000000?text=+) `Add proper abort/stop functions.`
- ![#fdb813](https://placehold.it/15/fdb813/000000?text=+) `Fix elapsed time to be more accurate & informational.`
- ![#fdb813](https://placehold.it/15/fdb813/000000?text=+) `Add prompt for user to input desired number of samples for GNU script.`
- ![#f03c15](https://placehold.it/15/f03c15/000000?text=+) `Add check in the beginning to ensure the Axis (AZ) is enabled.`

## Known Issues
- Obviously running the script without either the USRP or Position Controller connected will result in errors in the console.
- Terminating the script early while the Position Controller is connected will sometimes result in an issue where it says the serial port is not available, and you have to close, and reopen Matlab. To fix this, simply type this command into the command window after the script terminates early:
```
fclose(MI4190)
``` 
- If not using a `Head` block in the GNU radio file that you are using, the USRP will occasionally experience connectivity issues, in that it will say the device has already been claimed. This usually appears in an error message upon trying to run the script that says "Someone has already tried to claim this device." In this scenario, you must manually reboot the USRP. 

