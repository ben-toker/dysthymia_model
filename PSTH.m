rng(1); % fixed seed for consistency

dt = 0.001;
numUnits = 50;
nTrials = 100;    
warmup_trials = 40; 

[time, cue_vec, reward_vec] = task_generate(nTrials, 0.5, 1, 2.0, 2.0, dt);

%we stack the columns; this means every unit gets identical task
cue_mat = repmat(cue_vec, numUnits, 1); 
rew_mat = repmat(reward_vec, numUnits, 1);

% Base Parameters
params.dt = dt;
params.k0 = 0.1;    % Low baseline leak
params.eta = 0.0;   % Learning OFF
params.sigma = 0.5;
params.tau_T = 20.0; 
params.tau_V = 0.1;

fprintf('Running Healthy Simulation...\n');
params.kT = 0.5;
[V_healthy, ~] = RPE_layer(time, cue_mat, rew_mat, numUnits, params);

fprintf('Running Dysthymic Simulation...\n');
params.kT = 15.0; % High gain
[V_dysthymia, ~] = RPE_layer(time, cue_mat, rew_mat, numUnits, params);

reward_indices = find(reward_vec(1,:) > 0);

%this ensures we grab unique reward events by only grabbing the start (we
%only grab those seperated by at least 100 steps)
reward_indices = reward_indices(diff([-999, reward_indices]) > 100); 


%we throw away the first 40 indices to let the model reach a baseline
if length(reward_indices) > warmup_trials
    valid_indices = reward_indices(warmup_trials+1:end);
else
    % Fallback if random generation yielded fewer rewards
    valid_indices = reward_indices(round(end/2):end);
end

window_steps = round(0.5 / dt); 
psth_healthy = [];
psth_dysthymic = [];

%defining a time window (window_steps) around the reward
for idx = valid_indices
    if idx - window_steps > 0 && idx + window_steps <= length(time)
        range = (idx - window_steps) : (idx + window_steps);
        psth_healthy(:, end+1) = mean(V_healthy(:, range));
        psth_dysthymic(:, end+1) = mean(V_dysthymia(:, range));
    end
end

%we collapse the matrix across columns using mean(..,2)
mean_trace_H = mean(psth_healthy, 2);  
mean_trace_D = mean(psth_dysthymic, 2);
time_axis = linspace(-0.5, 0.5, length(mean_trace_H));

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
