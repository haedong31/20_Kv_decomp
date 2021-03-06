%% fully parameterized model
% 25-sec-single-clamp-voltage data
% model calibration phase 1 
% Mgat1KO
clc
close all
clear variables

% data to calculate objectives
exp_ksum = readtable('./25s-50mv-avg-ko.csv');
peak_vals = [17.6, 3.1, 3.6, 3.9];

% phase1: peak values
hold_volt = -70;
volt = 50;

time_space = cell(1,3);
hold_pt = 450;
end_pt = 25*1000;

hold_t = 0:hold_pt;
pulse_t = (hold_pt + 1):end_pt;
pulse_t_adj = pulse_t - pulse_t(1);
t = [hold_t, pulse_t];

time_space{1} = t;
time_space{2} = hold_t;
time_space{3} = pulse_t_adj;

Ek = -91.1;

param_select = false;

fun1 = @(p) obj_peak(p, hold_volt, volt, time_space, Ek, peak_vals, param_select);

% initialization with default values; note shared parameters of Ikslow1, Ikslow2, and Ikss
% 17 + 13 + 2 + 4 = 36 parameters
% p0_kto = [33, 15.5, 20, 16, 8, 7, 0.03577, 0.06237, 0.18064, 0.3956, 0.000152, 0.067083, 0.00095, 0.051335, 0.2087704319, 0.14067, 0.387];
% p0_kslow1 = [22.5, 45.2, 40.0, 7.7, 5.7, 6.1, 0.0629, 2.058, 803.0, 18.0, 0.9214774521, 0.05766, 0.07496];
% p0_kslow2 = [22.5, 45.2, 40.0, 7.7, 5.7, 6.1, 0.0629, 2.058, 5334, 4912, 0.05766];
% p0_kss = [22.5, 40.0, 7.7, 0.0862, 1235.5, 13.17, 0.0428];
p0 = [33, 15.5, 20, 16, 8, 7, 0.03577, 0.06237, 0.18064, 0.3956, 0.000152, 0.067083, 0.00095, 0.051335, 0.2087704319, 0.14067, 0.387, ...
    22.5, 45.2, 40.0, 7.7, 5.7, 6.1, 0.0629, 2.058, 803.0, 18.0, 0.9214774521, 0.05766, 0.07496, ...
    5334, 4912, ...
    0.0862, 1235.5, 13.17, 0.0428];

% fix phophorylation rates
pp0 = [33, 15.5, 20, 16, 8, 7, 0.03577, 0.06237, 0.18064, 0.3956, 0.000152, 0.067083, 0.00095, 0.051335, 0.14067, 0.387, ...
    22.5, 45.2, 40.0, 7.7, 5.7, 6.1, 0.0629, 2.058, 803.0, 18.0, 0.05766, 0.07496, ...
    5334, 4912, ...
    0.0862, 1235.5, 13.17, 0.0428];

% box constraints
lb = pp0 - pp0*5;
ub = pp0 + pp0*5;

% adjust lower bound for parameters that has to be non-zero
lb(6) = 1;
lb(7:16) = eps;

lb(20:21) = 1;
lb(22:24) = eps;
lb(25) = 10;
lb(26) = 1;
lb(27:28) = eps;

lb(29) = 10;
lb(30) = 1;

lb(31) = eps;
lb(32) = 1;
lb(33:34) = eps;

% other constraints
A = [];
b = [];
Aeq = [];
beq = [];
nonlcon = [];

[p1, fval1] = fmincon(fun1, pp0, A, b, Aeq, beq, lb, ub, nonlcon);
disp(fval1)

% simulate with found solution
[ykto, ykslow1, ykslow2, ykss, yksum] = full_model(p1, hold_volt, volt, time_space, Ek);

figure(1)
plot(t, yksum, "--", "Color","black", "LineWidth",1.5)
hold on
plot(exp_ksum.time, exp_ksum.current, "Color","red", "LineWidth",1.5)
title('Phase 1 - Mgat1KO')
legend('Simulated', 'Experimenta')
hold off

figure(2)
plot(t, ykto)
hold on
plot(t, ykslow1)
plot(t, ykslow2)
plot(t, ykss)
hold off
title('Phase 1 - Mgat1KO')
legend("I_{Kto}", "I_{Kslow1}", "I_{Kslow2}", "I_{Kss}");

% model calibration phase 2: RMSE
t = exp_ksum.time;
ksum = exp_ksum.current;

[~, peak_idx] = max(ksum);
early_ksum = ksum(1:peak_idx);
stable_val = min(early_ksum);
hold_idx = find(early_ksum == stable_val, 1, 'last');

time_space = cell(1, 3);
time_space{1} = t;

tH = t(1:hold_idx);
time_space{2} = tH;

tP1 = t(hold_idx+1:end);
tP1_adj = tP1 - tP1(1);
time_space{3} = tP1_adj;

% obj_rmse(p1, hold_volt, volt, time_space, Ek, ksum);
fun2 = @(p) obj_rmse(p, hold_volt, volt, time_space, Ek, ksum, param_select);

[p2, fval2] = fmincon(fun2, p1, A, b, Aeq, beq, lb, ub, nonlcon);
disp(fval2)

% simulate with found solution
[ykto, ykslow1, ykslow2, ykss, yksum] = full_model(p2, hold_volt, volt, time_space, Ek);

figure(3)
plot(t, yksum, "--", "Color","black", "LineWidth",1.5)
hold on
plot(exp_ksum.time, exp_ksum.current, "Color","red", "LineWidth",1.5)
title('Phase 2 - Mgat1KO')
legend('Simulated', 'Experimenta')
hold off

figure(4)
plot(t, ykto)
hold on
plot(t, ykslow1)
plot(t, ykslow2)
plot(t, ykss)
hold off
title('Phase 2 - Mgat1KO')
legend("I_{Kto}", "I_{Kslow1}", "I_{Kslow2}", "I_{Kss}");

save('param_25s','p2');

%% fully parameterized model
% 4.5-sec-voltage-dependent data
% Mgat1KO
clc
close all
clear variables

load('param_25s.mat');

% find holding-time index from experimental data
exp_ksum = table2array(readtable('./4.5s-avg-ko.csv'));
t = exp_ksum(:,1);
mean_ksum = mean(exp_ksum(:,2:end), 2);

[~, peak_idx] = max(mean_ksum);
early_ksum = mean_ksum(1:peak_idx);

early_ksum(early_ksum < 0) = 0; % negative to 0
stable_val = min(early_ksum);
hold_idx = min(early_ksum);

% generate time space
time_space = cell(1,3);
time_space{1} = t;

hold_t = t(1:hold_idx);
time_space{2} = hold_t;

pulse_t = t(hold_idx+1:end);
pulse_t_adj = pulse_t - pulse_t(1);
time_space{3} = pulse_t_adj;

% protocol
hold_volt = -70;
volt = -50:10:50;
Ek = -91.1;

% optimization
% 17 + 13 + 2 + 4 = 36 parameters
% p0_kto = [33, 15.5, 20, 16, 8, 7, 0.03577, 0.06237, 0.18064, 0.3956, 0.000152, 0.067083, 0.00095, 0.051335, 0.2087704319, 0.14067, 0.387];
% p0_kslow1 = [22.5, 45.2, 40.0, 7.7, 5.7, 6.1, 0.0629, 2.058, 803.0, 18.0, 0.9214774521, 0.05766, 0.07496];
% p0_kslow2 = [22.5, 45.2, 40.0, 7.7, 5.7, 6.1, 0.0629, 2.058, 5334, 4912, 0.05766];
% p0_kss = [22.5, 40.0, 7.7, 0.0862, 1235.5, 13.17, 0.0428];
p0 = [33, 15.5, 20, 16, 8, 7, 0.03577, 0.06237, 0.18064, 0.3956, 0.000152, 0.067083, 0.00095, 0.051335, 0.2087704319, 0.14067, 0.387, ...
    22.5, 45.2, 40.0, 7.7, 5.7, 6.1, 0.0629, 2.058, 803.0, 18.0, 0.9214774521, 0.05766, 0.07496, ...
    5334, 4912, ...
    0.0862, 1235.5, 13.17, 0.0428];

% fix phophorylation rates
pp0 = [33, 15.5, 20, 16, 8, 7, 0.03577, 0.06237, 0.18064, 0.3956, 0.000152, 0.067083, 0.00095, 0.051335, 0.14067, 0.387, ...
    22.5, 45.2, 40.0, 7.7, 5.7, 6.1, 0.0629, 2.058, 803.0, 18.0, 0.05766, 0.07496, ...
    5334, 4912, ...
    0.0862, 1235.5, 13.17, 0.0428];

% box constraints
lb = pp0 - pp0*5;
ub = pp0 + pp0*5;

% adjust lower bound for parameters that has to be non-zero
lb(6) = 1;
lb(7:16) = eps;

lb(20:21) = 1;
lb(22:24) = eps;
lb(25) = 10;
lb(26) = 1;
lb(27:28) = eps;

lb(29) = 10;
lb(30) = 1;

lb(31) = eps;
lb(32) = 1;
lb(33:34) = eps;

% other constraints
A = [];
b = [];
Aeq = [];
beq = [];
nonlcon = [];

% obj_rmse_over_volt(p2, hold_volt, volt, time_space, Ek, exp_ksum(:,2:end));
fun = @(p) obj_rmse_over_volt(p, hold_volt, volt, time_space, Ek, exp_ksum(:,2:end));

[p, fval] = fmincon(fun, p2, A, b, Aeq, beq, lb, ub, nonlcon);

% plot - simulation
figure(1)
[~, ~, ~, ~, yksum] = full_model(p2, hold_volt, volt(1), time_space, Ek);
plot(t, yksum)
hold on
for i=2:length(volt)
    [~, ~, ~, ~, yksum] = full_model(p2, hold_volt, volt(i), time_space, Ek);
    plot(t, yksum)
end
hold off

% plot - experimental
figure(2)
plot(t, exp_ksum(:,2))
hold on
for i=3:12
    plot(t, exp_ksum(:,i))
end
hold off

%% reduced model
% 4.5-sec-voltage-dependent data
% Mgat1KO

clc
close all
clear variables

% load experimental data
exp_ksum = table2array(readtable('./4.5s-avg-ko.csv'));
[~, num_volts] = size(exp_ksum);
num_volts = num_volts - 1;

% relavant information from the experimental data
t = exp_ksum(:,1);
exp_yksum = exp_ksum(:,2:end);
hold_idx = zeros(num_volts,1);
for i = 1:num_volts
    current_trc = exp_yksum(:,i);
    [~, peak_idx] = max(current_trc);

    early_current_trc = current_trc(1:peak_idx);
    stable_val = min(early_current_trc);
    hold_idx(i) = find(early_current_trc == stable_val, 1, 'last');
end

% visualize experimental data
figure(1)
plot(t, exp_ksum(:,1+1))
hold on
for i=2:num_volts
    plot(t, exp_ksum(:,i+1))
end
hold off
axis tight
xlabel('Time (ms))')
ylabel('Current (pA/pF)')

% optimization phase 1: with peaks
% constraints 
A = [];
b = [];
Aeq = [];
beq = [];
lb = [];
ub = [];
nonlcon = [];

p0 = [33,15.5,20,8,7,0.3956,0.00095,0.051335,0.14067,0.387,22.5,45.2,40,2.058,803,0.05766,0.07496,5334,13.17,0.0428];
lb = p0 - 10*p0;
ub = p0 + 10*p0;
lb([5, 6, 7, 8, 9, 10, 14, 15, 16, 17, 18, 19, 20]) = eps;

% protocol
hold_volt = -70;

volts = -50:10:50;

time_space = cell(1,3);
end_idx = 4.5*1000;
hold_t = 0:hold_idx;
pulse_t = (hold_idx + 1):end_idx;
pulse_t_adj = pulse_t - pulse_t(1);
sim_t = [hold_t, pulse_t];

time_space{1} = sim_t;
time_space{2} = hold_t;
time_space{3} = pulse_t_adj;

Ek = -91.1;

param_select = true;

volt_idx = 1;
[amp, tau, s] = tri_exp_fit(t, exp_yksum(:,volt_idx), hold_idx(volt_idx));
peak_vals = [amp; s];
opt_fun1 = @(p) obj_peak(p, hold_volt,volts(volt_idx), time_space, Ek, peak_vals, param_select);
[sol, min_val1] = fmincon(opt_fun1, p0, A, b, Aeq, beq, lb, ub, nonlcon);
p1 = sol;
for i = 2:num_volts
    volt_idx = i;
    [amp, tau, s] = tri_exp_fit(t, exp_yksum(:,volt_idx), hold_idx(volt_idx));
    peak_vals = [amp; s];
    obj_peak(p1, hold_volt,volts(volt_idx), time_space, Ek, peak_vals, param_select);
    opt_fun1 = @(p) obj_peak(p, hold_volt,volts(volt_idx), time_space, Ek, peak_vals, param_select);
    [sol, min_val1] = fmincon(opt_fun1, p1, A, b, Aeq, beq, lb, ub, nonlcon);
    p1=sol;
end

volt_idx = 1;
[~, ~, ~, ~, yksum] = reduced_model(p1, hold_volt, volts(volt_idx), time_space, Ek);
figure(2)
plot(sim_t, yksum)
hold on
for i = 1:num_volts
    volt_idx = i;
    [~, ~, ~, ~, yksum] = reduced_model(p1, hold_volt, volts(volt_idx), time_space, Ek);
    plot(sim_t, yksum)    
end
hold off
axis tight
xlabel('Time (ms)')
ylabel('Current (pA/pF)')

% optimization phase 2-1: stochastic RMSE
volt_idx = 1;
time_space = cell(1,3);
time_space{1} = t;
time_space{2} = t(1:hold_idx(volt_idx));
time_space{3} = t(hold_idx(volt_idx)+1:end) - t(hold_idx(volt_idx)+1);

opt_fun2 = @(p) obj_rmse(p, hold_volt,volts(volt_idx), time_space, Ek, exp_yksum(:,volt_idx), param_select);
[sol, ~] = fmincon(opt_fun2, p1, A, b, Aeq, beq, lb, ub, nonlcon);
p2 = sol;

for i = 2:num_volts
    volt_idx = i;
    time_space{2} = t(1:hold_idx(volt_idx));
    time_space{3} = t(hold_idx(volt_idx)+1:end) - t(hold_idx(volt_idx)+1);

    opt_fun2 = @(p) obj_rmse(p, hold_volt,volts(volt_idx), time_space, Ek, exp_yksum(:,volt_idx), param_select);
    [sol, min_val2] = fmincon(opt_fun2, p2, A, b, Aeq, beq, lb, ub, nonlcon);
    p2=sol;
end

volt_idx = 1;
time_space = cell(1,3);
time_space{1} = t;
time_space{2} = t(1:hold_idx(volt_idx));
time_space{3} = t(hold_idx(volt_idx)+1:end) - t(hold_idx(volt_idx)+1);

[~, ~, ~, ~, yksum] = reduced_model(p2, hold_volt, volts(volt_idx), time_space, Ek);

figure(3)
plot(t, yksum)
hold on
for i=2:num_volts
    volt_idx = i;
    time_space{2} = t(1:hold_idx(volt_idx));
    time_space{3} = t(hold_idx(volt_idx)+1:end) - t(hold_idx(volt_idx)+1);
    [~, ~, ~, ~, yksum] = reduced_model(p2, hold_volt, volts(volt_idx), time_space, Ek);
    plot(t, yksum)
end
hold off
axis tight
xlabel('Time (ms)')
ylabel('Current (pA/pF)')


% optimization phase 2-1: aggregated RMSE
opt_fun2 = @(p) obj_rmse_over_volt(p, hold_volt,volts, t, hold_idx, Ek, exp_yksum, param_select);
[sol, ~] = fmincon(opt_fun2, p1, A, b, Aeq, beq, lb, ub, nonlcon);
p2 = sol;

volt_idx = 1;
time_space = cell(1,3);
time_space{1} = t;
time_space{2} = t(1:hold_idx(volt_idx));
time_space{3} = t(hold_idx(volt_idx)+1:end) - t(hold_idx(volt_idx)+1);

[~, ~, ~, ~, yksum] = reduced_model(p2, hold_volt, volts(volt_idx), time_space, Ek);
figure(4)
plot(t, yksum)
hold on
for i=2:num_volts
    volt_idx = i;
    time_space{2} = t(1:hold_idx(volt_idx));
    time_space{3} = t(hold_idx(volt_idx)+1:end) - t(hold_idx(volt_idx)+1);
    [~, ~, ~, ~, yksum] = reduced_model(p2, hold_volt, volts(volt_idx), time_space, Ek);
    plot(t, yksum)
end
hold off
axis tight
xlabel('Time (ms)')
ylabel('Current (pA/pF)')
