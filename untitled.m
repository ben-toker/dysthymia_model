% main_stable_comparison.m
clear; clc; close all;
rng(1); % Fixed seed for consistency

% --- 1. Setup ---
dt = 0.001;
numUnits = 50;
nTrials = 100;    
warmup_trials = 40; 

% Generate Task
[time, cue_vec, reward_vec] = task_generate(nTrials, 0.5, 1, 2.0, 2.0, dt);
cue_mat = repmat(cue_vec, numUnits, 1);
rew_mat = repmat(reward_vec, numUnits, 1);

% Base Parameters
params.dt = dt;
params.k0 = 0.1;    % Low baseline leak
params.eta = 0.0;   % Learning OFF
params.sigma = 0.5;
params.tau_T = 20.0; 
params.tau_trace = 1.0; 

% --- 2. Run Simulations ---
fprintf('Running Healthy Simulation...\n');
params.kT = 0.5;
[V_healthy, ~] = RPE_layer_stable(time, cue_mat, rew_mat, numUnits, params);

fprintf('Running Dysthymic Simulation...\n');
params.kT = 15.0; % High gain
[V_dysthymia, ~] = RPE_layer_stable(time, cue_mat, rew_mat, numUnits, params);

% --- 3. Robust Data Extraction ---
reward_indices = find(reward_vec(1,:) > 0);
reward_indices = reward_indices(diff([-999, reward_indices]) > 100); 

if length(reward_indices) > warmup_trials
    valid_indices = reward_indices(warmup_trials+1:end);
else
    % Fallback if random generation yielded fewer rewards
    valid_indices = reward_indices(round(end/2):end);
end

window_steps = round(0.5 / dt); 
peth_healthy = [];
peth_dysthymic = [];

for idx = valid_indices
    if idx - window_steps > 0 && idx + window_steps <= length(time)
        range = (idx - window_steps) : (idx + window_steps);
        peth_healthy(:, end+1) = mean(V_healthy(:, range));
        peth_dysthymic(:, end+1) = mean(V_dysthymia(:, range));
    end
end

mean_trace_H = mean(peth_healthy, 2);
mean_trace_D = mean(peth_dysthymic, 2);
time_axis = linspace(-0.5, 0.5, length(mean_trace_H));

% --- 4. Plotting ---
figure('Color','w', 'Position', [200, 200, 800, 500]);

plot(time_axis, mean_trace_H, 'k', 'LineWidth', 2.5); hold on;
plot(time_axis, mean_trace_D, 'r', 'LineWidth', 2.5);

xline(0, '--', 'Reward Onset', 'HandleVisibility','off');
legend('Healthy (Low Tonic)', 'Dysthymic (High Tonic)', 'Location', 'Best');
title('Phasic Burst Suppression (Steady State)');
ylabel('Firing Rate (Hz)'); xlabel('Time from Reward (s)');
grid on;

% Stats
peak_H = max(mean_trace_H);
peak_D = max(mean_trace_D);
pct_change = (1 - peak_D/peak_H) * 100;
subtitle(sprintf('Suppression Effect: %.1f%%', pct_change));


% --- LOCAL FUNCTIONS ---

function [V_history, T_history] = RPE_layer_stable(time, cue, reward, numUnits, params)
    dt = params.dt; k0 = params.k0; kT = params.kT;
    sigma = params.sigma; tau_T = params.tau_T;
    
    numSteps = length(time);
    V = zeros(numUnits, 1);
    w = zeros(numUnits, 1); % Unused but kept for structure
    T = 0;
    
    V_history = zeros(numUnits, numSteps);
    T_history = zeros(1, numSteps);
    
    for i = 1:numSteps
        C_t = cue(:, i);
        O_t = reward(:, i);
        E_t = w .* C_t;  
        I_t = O_t - E_t;
        
        % Update T
        I_T = sum(V); 
        dT = (-T + I_T) / tau_T;
        T = T + dT * dt;
        T = max(0, T); % Safety: T cannot be negative
        
        % --- STABLE UPDATE RULE (Semi-Implicit Euler) ---
        % Explicit Euler: V_new = V_old + dt*(Input - Leak*V_old) -> UNSTABLE if Leak is big
        % Semi-Implicit:  V_new = (V_old + dt*Input) / (1 + dt*Leak) -> ALWAYS STABLE
        
        leak_gain = (k0 + kT * T); % This is just the coefficient 'L'
        noise = sigma * sqrt(dt) * randn(numUnits, 1);
        
        numerator = V + I_t * dt + noise;
        denominator = 1 + leak_gain * dt;
        
        V = numerator ./ denominator;
        % ------------------------------------------------
        
        V_history(:, i) = V;
        T_history(i) = T;
    end
end