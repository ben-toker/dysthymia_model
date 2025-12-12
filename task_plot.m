dt = 0.001;             % 1ms time step
nTrials = 5;            % Number of trials to plot
rewardProb = 0.5;       % 60% chance of reward (to see omissions)
rewardMag = 1.0;        % Magnitude of reward
cueRewardDelay = 1;   % 2 seconds between Cue and Reward
ITI = 0.0;              % 2 seconds wait between trials

[t, cue, reward] = task_generate(nTrials, rewardProb, rewardMag, cueRewardDelay, ITI, dt);

figure('Color', 'w', 'Position', [100, 100, 800, 600]);

% cue
subplot(2,1,1);
area(t, cue, 'FaceColor', [0 0.4470 0.7410], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); 
hold on;
plot(t, cue, 'Color', [0 0.4470 0.7410], 'LineWidth', 2);
ylabel('Cue Signal');
title('Task Structure: Cue and Reward Timing');
ylim([-0.1 1.2]);
grid on;

% reward
subplot(2,1,2);
area(t, reward, 'FaceColor', [0.8500 0.3250 0.0980], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); 
hold on;
plot(t, reward, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Reward Signal');
ylim([-0.1 1.2]);
grid on;

trial_length = cueRewardDelay + ITI;
for i = 1:nTrials
    trial_start = (i-1) * trial_length;
    
    subplot(2,1,1); xline(trial_start, '--k', 'Alpha', 0.5);
    subplot(2,1,2); xline(trial_start, '--k', 'Alpha', 0.5);
    
    subplot(2,1,1);
    text(trial_start + 0.1, 1.1, sprintf('Trial %d', i), 'FontWeight', 'bold');
end

% link axes so zooming in on one zooms the other
linkaxes(findall(gcf,'type','axes'), 'x');

subtitle_text = sprintf('Params: %d Trials, %.1f Prob, %.1fs Delay', nTrials, rewardProb, cueRewardDelay);
sgtitle(['Task Output Verification (' subtitle_text ')']);