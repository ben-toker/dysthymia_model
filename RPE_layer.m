function [V_history, w_history, E_history, T_history] = RPE_layer(time, cue, reward, numUnits, params)
    % RPE_layer simulates a population of Dopamine neurons with tonic feedback.
    %
    % Inputs:
    %   time: vector of time points
    %   cue: vector of cue presence (0 or 1)
    %   reward: vector of reward presence/magnitude
    %   numUnits: integer, size of the population
    %   params: struct containing model parameters (dt, k0, kT, eta, sigma, tau_T)
    %
    % Outputs:
    %   V_history: [numUnits x numSteps] Membrane potential of each unit
    %   w_history: [numUnits x numSteps] Associative weights
    %   E_history: [numUnits x numSteps] Expected reward (internal variable)
    %   T_history: [1 x numSteps] Tonic dopamine concentration (integrator)
    
    % Unpack parameters
    dt = params.dt;
    k0 = params.k0;          % Baseline leak
    kT = params.kT;          % Tonic feedback gain
    eta = params.eta;        % Learning rate
    sigma = params.sigma;    % Noise amplitude
    tau_T = params.tau_T;    % Tonic integration time constant
    
    numSteps = length(time);
    
    V = zeros(numUnits, 1); %Membrane voltage of each neuron
    w = zeros(numUnits, 1); %weight in expectation update 
    T = 0; % tonic integrator starts at 0
    
    % Pre-allocate history matrices
    V_history = zeros(numUnits, numSteps);
    w_history = zeros(numUnits, numSteps);
    E_history = zeros(numUnits, numSteps);
    T_history = zeros(1, numSteps);
    
    for i = 1:numSteps
        % First, we get cue and reward stimuli
        C_t = cue(:, i);      
        O_t = reward(:, i);
        
        % E_i(t) = w_i(t) * cue(t)
        E_t = w .* C_t;  
        
        % I_i(t) = O(t) - E_i(t)
        I_t = O_t - E_t;
        
        % Update tonic integrator 
        I_T = sum(V); % (sum over all RPE units)
        dTdt = (-T + I_T) / tau_T;
        T = T + dTdt * dt;
       
        % update RPE units
        leak_term = (k0 + (kT * T)) .* V;
        current_noise = sigma * sqrt(dt) * randn(numUnits, 1);
        dVdt = (I_t - leak_term) * dt + current_noise;
        V = V + dVdt;
        
        % dw/dt = eta (learning rate) * V_i * cue
        dwdt = eta .* V .* C_t * dt;
        w = w + dwdt;
        
        % store data
        V_history(:, i) = V;
        w_history(:, i) = w;
        E_history(:, i) = E_t;
        T_history(i) = T;
    end
end