function[] = XfoilCall(Re,Ma,NACA_4SERIES,AIRFOIL,AirfoilName,AlphaSequence)

% DEFINE SETTINGS
numNodes = '200';

fname = 'xfoil_input.txt';

% CREATE AIRFOIL FILE

fid = fopen(fname,'w');
if fid == -1
    error('Failed to open file for writing.');
end
fprintf(fid,'\n\n');
if NACA_4SERIES == 1
    fprintf(fid,['NACA ' AIRFOIL '\n']);
else
 fprintf(fid,['LOAD ' AIRFOIL '\n']);
 fprintf(fid,'\n'); 
end

fprintf(fid, 'PPAR\n');
fprintf(fid,['N ' numNodes '\n']);
fprintf(fid,'\n\n');

% POLAR
fprintf(fid,'\n\noper\n');
% fprintf(fid,'INIT \n');
fprintf(fid,'ITER %d\n',1000);
% set Remolds and Mach
fprintf(fid,'re %g\n',Re);
fprintf(fid,'mach %g\n',Ma);
  
% Switch to viscous mode
if (Re>0)
   fprintf(fid,'visc\n');  
end

% Polar accumulation 
fprintf(fid,'pacc\n\n\n');
% Xfoil alpha calculations
for ii = 1:length(AlphaSequence)
    % Individual output filenames
    % file_dump{ii} = sprintf('%s_a%06.3f_dump.dat',fname,AlphaSequence(ii));
    % file_cpwr{ii} = sprintf('%s_a%06.3f_cpwr.dat',fname,AlphaSequence(ii));
    % Commands
    fprintf(fid,'alfa %g\n',AlphaSequence(ii));
    % fprintf(fid,'dump %s\n',file_dump{ii});
    % fprintf(fid,'cpwr %s\n',file_cpwr{ii});
end
% Polar output filename
file_pwrt = sprintf('%sRe%dMa%.2f_pwrt.dat',AirfoilName,Re,Ma);
fprintf(fid,'pwrt\n%s\n',file_pwrt);
fprintf(fid,'plis\n');
fprintf(fid,'\nquit\n');
fclose(fid);

% execute xfoil
cmd = 'xfoil.exe < xfoil_input.txt > xfoil.out';
[~, ~] = system(cmd);


end