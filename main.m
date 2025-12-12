dt = 0.001; 
numUnits = 50;

nTrials = 500;
rewardProbability = 0.5;
rewardMagnitude = 1;
cueRewardDelay = 2;
ITI=0; % no way for model to recognize an inter-trial interval, so this is 0 for now

trialDuration = cueRewardDelay +ITI; % determines how long each trial is 
total_time = nTrials * trialDuration; 
time_steps = 0:dt:total_time;
total_time_steps=length(time_steps);

% Pre-allocate matrices [numUnits x numSteps]
all_cues = zeros(numUnits, total_time_steps);
all_rewards = zeros(numUnits, total_time_steps);

% generate a unique task for each unit
for u = 1:numUnits
    [time,cue, reward] = task_generate(nTrials, rewardProbability, rewardMagnitude, cueRewardDelay, ITI, dt);    
    all_cues(u, :) = cue;
    all_rewards(u, :) = reward;
end


% Define Parameters
params.dt = dt;
params.k0 = 1.0;     % Baseline leak
params.kT = 0.1;     % Feedback gain 
params.eta = 0.1;    % Learning rate
params.sigma = 0.5;  % Noise
params.tau_V = 0.1;  % Tau for all RPE units
params.tau_T = 40.0; % tau for tonic integrator

fprintf('Running main simulation (kT = %.1f)...\n', params.kT);
[V_hist, w_hist, E_hist, T_hist] = RPE_layer(time_steps, all_cues, all_rewards, numUnits, params);

% We define a range of kT values to test
kT_sweep_values = 0 : 1 : 10; 
avg_amplitudes = zeros(size(kT_sweep_values));

fprintf('Starting parameter sweep for %d values\n', length(kT_sweep_values));

for i = 1:length(kT_sweep_values)
    % Create a temporary params struct for this iteration
    sweep_params = params;
    sweep_params.kT = kT_sweep_values(i);
    
    % Run the layer (suppress outputs we don't need to save memory)
    [V_sw, ~, ~, ~] = RPE_layer(time_steps, all_cues, all_rewards, numUnits, sweep_params);
    
    % Calculate Metric: Average rectified firing rate over the whole session
    avg_amplitudes(i) = mean(mean(max(0, V_sw)));
end

figure('Color','w', 'Position', [100, 100, 1000, 800]);

% mean phasic activity
subplot(2,2,1);
plot(time_steps, mean(V_hist), 'k');
title('Mean Phasic RPE Activity (V)');
ylabel('Hz'); grid on;
xlim([0 total_time]);

% tonic dopamine chart
subplot(2,2,2);
plot(time_steps, T_hist, 'r', 'LineWidth', 1.5);
title(sprintf('Tonic Dopamine (T) | kT = %.1f', params.kT));
ylabel('[DA]'); grid on;
xlim([0 total_time]);

% learned weights
subplot(2,2,3);
plot(time_steps, mean(w_hist), 'b');
title('Learned Weights (Expectation)');
xlabel('Time (s)'); ylabel('Weight'); grid on;
xlim([0 total_time]);

% parameter sweep
subplot(2,2,4);
plot(kT_sweep_values, avg_amplitudes, '-o', 'Color', [0 0.5 0], 'LineWidth', 2, 'MarkerFaceColor', 'w');
title('Parameter Sweep: Self-Inhibition');
xlabel('Feedback Gain (k_T)');
ylabel('Avg Population Activity (Hz)');
grid on;

% current simulation mark
hold on;
current_amp = mean(mean(max(0, V_hist)));
plot(params.kT, current_amp, 'rx', 'MarkerSize', 12, 'LineWidth', 2);
legend('Sweep Curve', 'Current Sim', 'Location', 'NorthEast');