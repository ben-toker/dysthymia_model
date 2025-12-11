% Generate a time course of cue and reward through simple Pavlovian task
% simulation

function [time,cue,reward] = task_generate(nTrials,rewardProb,rewardMag, cueRewardDelay, ITI,dt)
    % Input:
    % nTrials = number of Trials
    % rewardProb = the probability that a reward will come after the cue
    % dt = delta T = timestep interval
    % cueRewardDelay = # of (dt) time units between cue and reward
    % ITI = inter-trial interval
    %
    % Output:
    % time: vector of time steps
    % cue: vector of cue occurances (1 if there's a cue, 0 if not)
    % reward: vector of reward occurences (rewardMag or 0)

    trialDuration = cueRewardDelay + ITI; % determines how long each trial is 
    total_time = nTrials * trialDuration; 

    t = 0:dt:total_time; % number of time steps
    time=t;

    cue = zeros(1,length(t));
    reward = zeros(1,length(t));

    % how long stimuli last (e.g., 200ms)
    % This ensures the Euler integrator actually "sees" the input.
    stimDuration = 0.2; 
    stimSteps = round(stimDuration / dt);

    for i = 1:nTrials
       %starts at the end of the previous trial
       trialStartTime = (i-1) * trialDuration;

       cueStartIdx = round(trialStartTime / dt) + 1;
       rewStartIdx = round((trialStartTime + cueRewardDelay) / dt) + 1;
       
       % boxcar
       if (cueStartIdx + stimSteps) <= length(t)
           cue(cueStartIdx : cueStartIdx + stimSteps) = 1;
       end
       
       % Set Reward (Probabilistic)
       if rand < rewardProb 
           if (rewStartIdx + stimSteps) <= length(t)
                % You can make reward a pulse (short) or boxcar (long)
                % Here we treat it same as cue for visibility
                reward(rewStartIdx : rewStartIdx + stimSteps) = rewardMag;
           end
       end
    end
end
