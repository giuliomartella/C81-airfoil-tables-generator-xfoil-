clc; clear; close all;

AlphaSequence = -5:0.3:14; % Define angle of attack sequence

WING.AIRFOIL = 'S9000.dat'; % Define airfoil file name
WING.AirfoilName = 'S9000'; % Define airfoil name
NACA_4SERIES = 0; % Indicator for NACA 4-series airfoil

for Re  = [2500000.0, 5000000.0] % Loop over Reynolds numbers
    for Ma = 0:0.1:0.9 % Loop over Mach numbers
        % Call Xfoil function with specified parameters
        XfoilCall(Re, Ma, NACA_4SERIES, WING.AIRFOIL, WING.AirfoilName, AlphaSequence)

        % Construct command to execute Xfoil with input file
        command = 'cat xfoil_input.txt | xfoil';
        
        % Execute command in the system shell
        system(command);
    end
end
