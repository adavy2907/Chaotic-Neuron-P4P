classdef Chaotic_Neuron

    properties 
        k {mustBeNumeric}
        alpha {mustBeNumeric}
        a {mustBeNumeric}
        epsilon {mustBeNumeric}
        state {mustBeNumeric}
    end

    methods
        function obj = Chaotic_Neuron(k, alpha, a, epsilon, initial_state)
            obj.k = k;
            obj.alpha = alpha;
            obj.a = a;
            obj.epsilon = epsilon;
            obj.state = initial_state;
        end 

        function y_next = chaotic_neuron(obj, y, fx)
            f = fx(y, obj.epsilon);
            obj.state = (obj.k * y) - obj.alpha * f + obj.a;
            y_next = obj.state;
        end 
    end 
end
