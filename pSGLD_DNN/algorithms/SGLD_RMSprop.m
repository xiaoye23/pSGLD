function [err,state] = SGLD_RMSprop(model,f,opts,state) %--TODO: Add momentum

    %% error checking and initialization
    if nargin < 3; state = {}; end
    if ~isfield(state,'iter'); state.iter = 0; end
    state.iter = state.iter+1;

    
    if isfield(opts,'learningRate')
        lr = opts.learningRate;
    else
        lr = 1;
    end
    
    if isfield(opts,'RMSpropDecay')
        rmsd = opts.RMSpropDecay;
    else
        rmsd = 0.99;
    end
    
    if isfield(opts,'epsilon')
        eps = opts.epsilon;
    else
        eps = 1e-1;
    end
    

    if ~isfield(opts,'reportL2Penalty');opts.reportL2Penalty=false;end

    params = model.getParameters();
    [err, grad] = f();

    
    if isfield(opts,'weightDecay') && opts.weightDecay > 0
        grad = grad + opts.weightDecay*params;
        if opts.reportL2Penalty; err = err + 0.5*opts.weightDecay*dot(params(:),params(:)); end
    end
    
    if isfield(opts,'learningRateOffset') && opts.learningRateOffset >0
        lr=opts.learningRate*((state.iter+opts.learningRateOffset)^-opts.learningRateDecay);
    elseif isfield(opts,'learningRateDecay') && opts.learningRateDecay > 0
        lr= opts.learningRate*(state.iter^-opts.learningRateDecay);
        %         lr = lr/(opts.learningRateDecay^state.iter);
    end
    
    if ~isfield(state,'history'); state.history = 0+grad.^2; end
    
    %% algorithm
    state.history = rmsd*state.history + (1-rmsd)*grad.^2;
    pcder=(eps + sqrt(state.history));  
    grad = lr* grad ./ pcder + sqrt(2*lr./pcder).*randn(size(grad))/opts.N ;
    
    params = params - grad;

    model.setParameters(params);
end