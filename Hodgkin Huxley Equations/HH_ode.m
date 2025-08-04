function dXdt = HH_ode(~, X, I0)
% Hodgkin-Huxley equations without periodic forcing
% X = [V, n, m, h]

    V = X(1);
    n = X(2);
    m = X(3);
    h = X(4);

    % Constants
    Cm = 1.0;    % uF/cm^2
    gNa = 120;   ENa = 50;
    gK = 36;     EK = -77;
    gL = 0.3;    EL = -54.4;

    % Gating variable kinetics
    alpha_n = (0.01*(V+55)) / (1 - exp(-(V+55)/10));
    beta_n = 0.125 * exp(-(V+65)/80);

    alpha_m = (0.1*(V+40)) / (1 - exp(-(V+40)/10));
    beta_m = 4 * exp(-(V+65)/18);

    alpha_h = 0.07 * exp(-(V+65)/20);
    beta_h = 1 / (1 + exp(-(V+35)/10));

    % Currents
    INa = gNa * m^3 * h * (V - ENa);
    IK = gK * n^4 * (V - EK);
    IL = gL * (V - EL);

    % Differential equations
    dVdt = (I0 - INa - IK - IL) / Cm;
    dndt = alpha_n * (1 - n) - beta_n * n;
    dmdt = alpha_m * (1 - m) - beta_m * m;
    dhdt = alpha_h * (1 - h) - beta_h * h;

    dXdt = [dVdt; dndt; dmdt; dhdt];
end
