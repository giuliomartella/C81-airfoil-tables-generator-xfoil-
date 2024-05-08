clear
clc

% Specify the folder containing .dat files
folder_path = './';
files = dir(fullfile(folder_path, '*.dat'));

% Initialize structures for unique values
data_struct = struct();

% Read and prepare data from all files
for k = 1:size(files,1)
    file_name = files(k).name;
    % Extract Reynolds number and Mach number from the filename
    tokens = regexp(file_name, 'S9000Re(\d+)Ma0\.(\d+)_pwrt\.dat', 'tokens');
    if isempty(tokens)
        continue;
    end
    re = str2double(tokens{1}{1}); % Reynolds number
    ma = str2double(tokens{1}{2}) / 100; % Mach number
    re_key = sprintf('Re%d', re);
    mach_key = sprintf('Ma_%.2f', ma);
    mach_key = strrep(mach_key, '.', '_');  % Replace dot with underscore

    % Read data from the file
    full_path = fullfile(folder_path, file_name);
    fid = fopen(full_path, 'r');
    data = textscan(fid, '%f%f%f%f%f%f%f%f%f', 'HeaderLines', 12);  % Skip header lines
    fclose(fid);

    % Extract data
    alpha = data{1}; % Angle of attack
    cl = data{2};    % Lift coefficient
    cd = data{3};    % Drag coefficient
    cm = data{5};    % Moment coefficient

    % Ensure data is not empty or NaN before saving
    valid_indices = ~isnan(alpha) & ~isnan(cl) & ~isnan(cd) & ~isnan(cm);
    alpha = alpha(valid_indices);
    cl = cl(valid_indices);
    cd = cd(valid_indices);
    cm = cm(valid_indices);

    % Save data in the structure
    if ~isfield(data_struct, re_key)
        data_struct.(re_key) = struct();
    end
    if ~isfield(data_struct.(re_key), mach_key)
        data_struct.(re_key).(mach_key) = struct('Alpha', [], 'CL', [], 'CD', [], 'CM', []);
    end
    data_struct.(re_key).(mach_key).Alpha = [data_struct.(re_key).(mach_key).Alpha; alpha];
    data_struct.(re_key).(mach_key).CL = [data_struct.(re_key).(mach_key).CL; cl];
    data_struct.(re_key).(mach_key).CD = [data_struct.(re_key).(mach_key).CD; cd];
    data_struct.(re_key).(mach_key).CM = [data_struct.(re_key).(mach_key).CM; cm];
end

% Open the file for writing
fileID = fopen('S9000.c81', 'w');

% Process each Reynolds number in the structure
reynolds_numbers = fieldnames(data_struct);

% File header
fprintf(fileID, '%d 0 0\n0 0\n0 0.\n', length(reynolds_numbers));

for i = 1:length(reynolds_numbers)
    re_key = reynolds_numbers{i};
    mach_numbers = fieldnames(data_struct.(re_key));

    % Clean data, if Xfoil does not converge
    canc_vect = zeros(76,length(mach_numbers));
    for j = 1:length(mach_numbers)
        mach_key = mach_numbers{j};
        nsize = numel(data_struct.(re_key).(mach_key).Alpha);
        a = -4;
        k_canc = 0;
        for k = 1:nsize
            k_canc = k_canc+1;
            if abs(data_struct.(re_key).(mach_key).Alpha(k)  - a) > 1e-2
                canc_vect(k_canc,j) = 1;
                k_canc = k_canc+1;
                a = a + 0.4;
            else
                a = a + 0.2;
            end
        end
    end
    
    % Find rows where at least one value is non-zero
    non_zero_rows = any(canc_vect ~= 0, 2);

    % Create a column vector with values of 1 for non-zero rows
    index_vector = zeros(size(canc_vect, 1), 1);
    index_vector(non_zero_rows) = 1;

    for j = 1:length(mach_numbers)
        mach_key = mach_numbers{j};
        base_matrix = zeros(76,4);
        kj = 0;
        for k = 1:76
            if index_vector(k) == 0
                kj = kj +1;
                base_matrix(k,:) = [data_struct.(re_key).(mach_key).Alpha(kj), data_struct.(re_key).(mach_key).CL(kj), data_struct.(re_key).(mach_key).CD(kj), data_struct.(re_key).(mach_key).CM(kj)];
            end
        end
        % Find rows where every value is zero
        non_zero_rows = ~all(base_matrix == 0, 2);

        % Use logical indexing to select only the non-zero rows
        base_matrix_non_zero = base_matrix(non_zero_rows, :);

        data_struct.(re_key).(mach_key).Alpha = base_matrix_non_zero(:,1);
        data_struct.(re_key).(mach_key).CL = base_matrix_non_zero(:,2);
        data_struct.(re_key).(mach_key).CD = base_matrix_non_zero(:,3);
        data_struct.(re_key).(mach_key).CM = base_matrix_non_zero(:,4);
    end

    re_num = str2double(regexp(re_key, '\d+', 'match'));
    
    % Write header for each Reynolds-Mach pair
    fprintf(fileID, 'COMMENT#1\n');
    fprintf(fileID, '%10.1f %6.3f     %f\n ', re_num, 0.1);
    fprintf(fileID, '\nVahana1                       0%d%d0%d%d0%d%d\n', length(mach_numbers), 2+numel(data_struct.(re_key).(mach_key).Alpha), length(mach_numbers), 2+numel(data_struct.(re_key).(mach_key).Alpha), length(mach_numbers), 2+numel(data_struct.(re_key).(mach_key).Alpha));

    for j = 1:length(mach_numbers)
        re = str2double(re_key(3:end));
        mach_key = mach_numbers{j};
        ma = strrep(mach_key, 'Ma_', '');
        ma = replace(ma, '_', '.'); % Convert back underscore to dot for Mach number
        ma_double(j) = str2double(ma);
        
        % Column headers for angles and Mach numbers
        alpha = data_struct.(re_key).(mach_key).Alpha;
       
        if j ==1
            % Print CL, CD, and CM data
            cl_data = [data_struct.(re_key).(mach_key).CL];
            cd_data = [data_struct.(re_key).(mach_key).CD];
            cm_data = [data_struct.(re_key).(mach_key).CM];
        else
            cl_data = [cl_data, data_struct.(re_key).(mach_key).CL];
            cd_data = [cd_data, data_struct.(re_key).(mach_key).CD];
            cm_data = [cm_data, data_struct.(re_key).(mach_key).CM];
        end
    end

    % Insert data
    printC81Table(fileID, alpha, cl_data, ma_double);
    printC81Table(fileID, alpha, cd_data, ma_double);
    printC81Table(fileID, alpha, cm_data, ma_double);
end

fclose(fileID);
