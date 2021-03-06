%% preprocessing for wt-4.5 / 12.10 / 10/29/2015 Cell 3 / 15o29009
clc
close all
clear variables

data = readtable('./data/wt/15o29009.xlsx');
col_names = data.Properties.VariableNames;
data = table2array(data);

% downsample
data_sampled = downsample(data, 20);
t = data_sampled(:, 1);
[~, num_volts] = size(data_sampled);
num_volts = num_volts - 1;

% visualization
plot(t, data_sampled(:,1+1))
hold on
for i=2:num_volts
    plot(t, data_sampled(:,i+1))
end
hold off

% remove negative values
for i = 1:num_volts
    y = data_sampled(:,i+1);
    y(y < 0) = 0;
    data_sampled(:,i+1) = y;
end

% chop off tail
ideal_hold_time = 120;
[~, hold_idx] = min(abs(t - ideal_hold_time));
ideal_end_time = ideal_hold_time + 4500;
[~, tail_idx] = min(abs(t - ideal_end_time));
data_sampled = data_sampled(1:tail_idx, :);
t = data_sampled(:, 1);

% visualization
plot(t, data_sampled(:,1+1))
hold on
for i=2:num_volts
    plot(t, data_sampled(:,i+1))
end
hold off

% each current
volt_idx = 11;
y = data_sampled(:, 1+volt_idx);
plot(t, y)

impute_val = mean(y(1:hold_idx));
y(y > 16000) = impute_val;
plot(t, y)

data_sampled(:, 1+volt_idx) = y;

% normalization
cap = 227.00;
data_sampled(:, 2:end) = data_sampled(:, 2:end)./cap;

% visualization
plot(t, data_sampled(:,1+1))
hold on
for i=2:num_volts
    plot(t, data_sampled(:,i+1))
end
hold off

data_processed = array2table(data_sampled, 'VariableNames',col_names);
writetable(data_processed, './data/wt-preprocessed/15o29009.xlsx')

%% preprocessing for wt-25 / 12.10 / 10/29/2015 Cell 3 / 15o29010


%% preprocessing for ko-4.5 / 15.40 / 11/24/2015 Cell 5 / 15n24005.xlsx
clc
close all
clear variables

data = readtable('./data/ko/15n24005.xlsx');
col_names = data.Properties.VariableNames;
data = table2array(data);

% downsample
data_sampled = downsample(data, 20);
t = data_sampled(:, 1);
[~, num_volts] = size(data_sampled);
num_volts = num_volts - 1;

% visualization
plot(t, data_sampled(:,1+1))
hold on
for i=2:num_volts
    plot(t, data_sampled(:,i+1))
end
hold off

% remove negative values
for i = 1:num_volts
    y = data_sampled(:,i+1);
    y(y < 0) = 0;
    data_sampled(:,i+1) = y;
end

% chop off tail
ideal_hold_time = 120;
[~, hold_idx] = min(abs(t - ideal_hold_time));
ideal_end_time = ideal_hold_time + 4500;
[~, tail_idx] = min(abs(t - ideal_end_time));
data_sampled = data_sampled(1:tail_idx, :);
t = data_sampled(:, 1);

% visualization
plot(t, data_sampled(:,1+1))
hold on
for i=2:num_volts
    plot(t, data_sampled(:,i+1))
end
hold off

% each current
volt_idx = 11;
y = data_sampled(:, 1+volt_idx);
plot(t, y)

impute_val = mean(y(1:hold_idx));
y(y > 5000) = impute_val;
plot(t, y)

data_sampled(:, 1+volt_idx) = y;

% normalization
cap = 177.00;
data_sampled(:, 2:end) = data_sampled(:, 2:end)./cap;

% visualization
plot(t, data_sampled(:,1+1))
hold on
for i=2:num_volts
    plot(t, data_sampled(:,i+1))
end
hold off

data_processed = array2table(data_sampled, 'VariableNames',col_names);
writetable(data_processed, './data/ko-preprocessed/15n24005.xlsx')

%% preprocessing for ko-25 / 15.40 / 11/24/2015 Cell 5 / 15n24014


%% preprocessing for 4.5-2-avg-ko data
clc
close all
clear variables

exp_ksum = readtable('./4.5s-avg-ko-orig.csv');
col_names = exp_ksum.Properties.VariableNames;

exp_ksum = table2array(exp_ksum);

t = exp_ksum(:,1);
[~, num_volts] = size(exp_ksum);
num_volts = num_volts - 1;

% remove sharp negative peaks at the early phase
for i=1:num_volts
    y = exp_ksum(:,i+1);
    y(y < 0) = 0;
    exp_ksum(:,i+1) = y;
end

% visualize experimental data 
plot(t, exp_ksum(:,1+1))
hold on
for i=2:num_volts
    plot(t, exp_ksum(:,i+1))
end
hold off

% remove sharp pulse in -50 ~ 0 mV
% -50 mV
y = exp_ksum(:,6);
[peak, peak_idx] = max(y);
impute_val = mean(y(1:100));
y(y>0.5) = impute_val;
y(255:257) = impute_val;
plot(t, y)
xlabel('Time (ms)')
ylabel('Current (pA/pF)')
exp_ksum(:,2) = y;

% - 40 mV;
y = exp_ksum(:,3);
[peak, peak_idx] = max(y);
impute_val = mean(y(1:155));
y(y>0.5) = impute_val;
y(250:255) = impute_val;
plot(t,y)
exp_ksum(:,3) = y;

% -30 mV;
y = exp_ksum(:,4);
[peak, peak_idx] = max(y);
impute_val = mean(y(1:180));
y(y>0.6) = impute_val;
plot(t,y)
exp_ksum(:,4) = y;

% -20 mV
y = exp_ksum(:,5);
[peak, peak_idx] = max(y);
impute_val = mean(y(1:200));
y(y>1.5) = impute_val;
plot(t,y)
exp_ksum(:,5) = y;

% -10 mV
y = exp_ksum(:,6);
[peak, peak_idx] = max(y);
impute_val = mean(y(1:220));
y(y>3.5) = impute_val;
plot(t,y)
exp_ksum(:,6) = y;

% save
exp_ksum = array2table(exp_ksum, 'VariableNames',col_names);
writetable(exp_ksum,'./4.5s-avg-ko.csv');

%% preprocessing for 4.5-2-avg-wt data
clc
close all
clear variables

ds = readtable('./4.5s-avg-wt-orig.csv');
col_names = ds.Properties.VariableNames;

ds = table2array(ds);

t = ds(:,1);
traces = ds(:,2:end);
[~, num_volts] = size(traces);

% remove negative pulses in early phase
for i=1:num_volts
    y = traces(:,i);
    y(y < 0) = 0;
    traces(:,i) = y;
end

% cut tails
tail_idx = find(t == 4620);
t(tail_idx:end) = [];
traces(tail_idx:end,:) = [];

% remove sharp pulse in -50 ~ 0 mV
% -50 mV
y = traces(:,1);
plot(t, y)
impute_val = mean(y(1:300));
y(y>0.4) = impute_val;
y(310:315) = impute_val;
traces(:,1) = y;

% -40 mV
y = traces(:,2);
plot(t,y)
impute_val = mean(y(1:300));
y(y>0.4) = impute_val;
traces(:,2) = y;

% -30 mV
y = traces(:,3);
plot(t, y)
impute_val = mean(y(1:300));
y(y>1.5) = impute_val;
y(314:316) = impute_val;
traces(:,3) = y;

% visualize all traces
plot(t, traces(:,1))
hold on
for i=1:num_volts
    plot(t, traces(:,i))
end
hold off
xlabel('Time (ms)')
ylabel('Current (pA/pF)')

new_ds = [t, traces];
new_ds = array2table(new_ds, 'VariableNames',col_names);
writetable(new_ds,'./4.5s-avg-wt.csv')
