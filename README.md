# PositionControl
A library to control the MI-4190 position controller and automate measurements with a USRP N310

Main file to run is: /System/PositionController.m

Just connect the Position Controller to your computer via the GPIB-USB serial connector and change the value for the port in the serial command at the beginning of the script.

To avoid errors on terminating during execution of the script. Run fclose(MI4190) in the command window before attempting to run the script or send commands to the MI-4190 again.
