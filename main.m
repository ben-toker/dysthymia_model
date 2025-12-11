% --- Simulation Setup ---
dt = 0.01; 
numUnits = 50;

% Generate Task: 20 trials
nTrials = 20;
rewardProbability = 0.5;
rewardMagnitude = 1;
cueRewardDelay = 2;

trialDuration = cueRewardDelay; % determines how long each trial is 
total_time = nTrials * trialDuration; 
total_time_steps=length(0:dt:total_time);

% Pre-allocate matrices [numUnits x numSteps]
all_cues = zeros(numUnits, total_time_steps);
all_rewards = zeros(numUnits, total_time_steps);

% Generate a unique task for each unit
for u = 1:numUnits
    [time,cue, reward] = task_generate(nTrials, rewardProbability, rewardMagnitude, cueRewardDelay, 0, dt);    
    all_cues(u, :) = cue;
    all_rewards(u, :) = reward;
end




% Define Parameters
params.dt = dt;
params.k0 = 1.0;     % Baseline leak
params.kT = 0.1;     % Feedback gain 
params.eta = 0.1;    % Learning rate
params.sigma = 0.5;  % Noise

params.tau_T = 20.0; 

% --- Run Model ---
[V_hist, w_hist, E_hist, T_hist] = RPE_layer(time, cue, reward, numUnits, params);

% --- Plotting ---
figure('Color','w');

subplot(3,1,1);
plot(time, mean(V_hist), 'k');
title('Mean Phasic RPE Activity (V)');
ylabel('Hz');

subplot(3,1,2);
plot(time, T_hist, 'r', 'LineWidth', 2);
title('Tonic Dopamine Concentration (T)');
ylabel('[DA]');

subplot(3,1,3);
plot(time, mean(w_hist), 'b');
title('Learned Weights (Expectation)');
xlabel('Time (s)');