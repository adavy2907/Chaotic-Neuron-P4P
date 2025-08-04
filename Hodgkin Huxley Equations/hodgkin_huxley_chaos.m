function hodgkin_huxley_chaos
    % Parameters (adjusted to induce chaos)
    Cm = 1;      gNa = 120;    gK = 36;     gL = 0.3;
    ENa = 50;    EK = -77;     EL = -54.4;
    Iext = 10;   % External current (uA/cm²)

    % Initial conditions
    V0 = -65;    m0 = 0.05;    h0 = 0.6;    n0 = 0.32;
    y0 = [V0; m0; h0; n0];

    % Time span (long simulation to capture chaos)
    tspan = [0 300]; % Extended time to observe irregularity

    % Solve ODEs
    [t, y] = ode45(@(t, y) hh_ode(t, y, Cm, gNa, gK, gL, ENa, EK, EL, Iext), tspan, y0);

    % Plot membrane potential
    figure;
    plot(t, y(:, 1));
    xlabel('Time (ms)'), ylabel('Membrane Potential (mV)');
    title('HH Model: Chaotic Spiking/Bursting');
end

function dydt = hh_ode(~, y, Cm, gNa, gK, gL, ENa, EK, EL, Iext)
    V = y(1); m = y(2); h = y(3); n = y(4);

    % Rate constants (voltage-dependent)
    alpha_m = 0.1 * (V + 40) / (1 - exp(-(V + 40)/10));
    beta_m  = 4 * exp(-(V + 65)/18);
    alpha_h = 0.07 * exp(-(V + 65)/20);
    beta_h  = 1 / (1 + exp(-(V + 35)/10));
    alpha_n = 0.01 * (V + 55) / (1 - exp(-(V + 55)/10));
    beta_n  = 0.125 * exp(-(V + 65)/80);

    % Gating dynamics
    dmdt = alpha_m * (1 - m) - beta_m * m;
    dhdt = alpha_h * (1 - h) - beta_h * h;
    dndt = alpha_n * (1 - n) - beta_n * n;

    % Ion currents
    INa = gNa * m^3 * h * (V - ENa);
    IK  = gK * n^4 * (V - EK);
    IL  = gL * (V - EL);

    % Membrane potential dynamics
    dVdt = (Iext - INa - IK - IL) / Cm;

    dydt = [dVdt; dmdt; dhdt; dndt];
end

