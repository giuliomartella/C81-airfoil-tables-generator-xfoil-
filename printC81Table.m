function printC81Table(fileID, alpha, data, ma_double)
% Function to print data in a C81 format table to a file
% Inputs:
%   fileID: file identifier for the file to write to
%   alpha: array of angles of attack
%   data: matrix of corresponding data (e.g., CL, CD, CM)
%   ma_double: Mach numbers corresponding to each data set

% Print Mach numbers line
fprintf(fileID, ' %s\n', sprintf('%.1f ', ma_double));
fprintf(fileID, ' %.1f   ',-180.0);
for i =1:numel(ma_double)-1
fprintf(fileID, ' %.1f   ',0.0);
end
fprintf(fileID, ' %.1f \n  ',0.0);
% Loop over each angle of attack
for k = 1:length(alpha)
    % Print angle of attack
    fprintf(fileID, '%8.1f', alpha(k));
    
    % Print corresponding data
    fprintf(fileID, '%10.5f', data(k, :));
    
    % Move to next line
    fprintf(fileID, '\n');
end
fprintf(fileID, ' %.1f   ',+180.0);
for i =1:numel(ma_double)-1
fprintf(fileID, ' %.1f   ',0.0);
end
fprintf(fileID, ' %.1f \n  ',0.0);


end
