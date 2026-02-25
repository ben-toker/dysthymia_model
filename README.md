# Model of Dysthymia
<div align=center>
<img width="580" height="606" alt="image" src="https://github.com/user-attachments/assets/c60fccd7-c22c-4abe-8987-1ea631a1593d" />
</div>

# Equations 

1. $\frac{dV_{i}}{dt}= I_{i}(t) - \left(k_{0} + k_{T} T(t)\right)V_{i}(t) + \left(\sigma \cdot \sqrt{dt} \cdot \mathcal{N}(u,1)\right)$
2. $I_{i}(t) = O_{i}(t) - E_{i}(t)$
3. $E_{i}(t) = w(t) \cdot \text{cue}(t)$
4. $\dfrac{dw}{dt} = \eta \cdot V_i(t) \cdot \text{cue}(t)$
5. $\dfrac{dT}{dt} = \dfrac{-T(t) + I_T(t)}{\tau_T}$
6. $I_T(t) = \sum_{\forall i} V_i$


 RPE Update Rule Key
- $V_{i}(t)$ Membrane variable of RPE neuron $i$; $I_{i}(t)$ is its corresponding input.
  - $w(t)$ is the weighted sum of active cues. 
  - $\eta$ is the learning rate of the RPE weight update.
  - $T(t)$ Integrator of the RPE unit layer, intended to represent tonic dopamine.
  - $k_{0}$ Baseline leak constant.
  -$k_{T}$ Tonic feedback gain that determines how strongly tonic dopamine modulates self-inhibition.
  - $\sigma$  Noise amplitude.
  - $\mathcal{N}(u,1)$ Additive Gaussian noise over $u$ units.
    In MATLAB, this would be
    ```matlab
    numUnits = u
    randn(numUnits,1)   % N(u,1)


Essentially, when tonic dopamine $T(t)$ is low, phasic bursts from each RPE unit can
persist. When tonic dopamine is high, the leak term $(k_{0} + k_{T} T(t))$ increases and
sustained phasic RPE activity is suppressed.



# Running the model

In order to run the main model simulation, simply open up the folder in MATLAB and run `main.m`

To get the peri-stimulus-time-histogram plot, run `psth.m.` For the task simulation plot, run `task_plot.m`


