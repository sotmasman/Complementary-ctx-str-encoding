function pop_plot_default(data,time,yspan,...
                    color_n,dashtype,varargin)
    
    options = struct('set_gca_off', false,...
                        'plotstack', false,...
                        'plotline',true);
    
    optionNames = fieldnames(options);
    for pair = reshape(varargin, 2, [])
        if any(strcmp(pair{1}, optionNames))
            options.(pair{1}) = pair{2};
        end
    end
    set_gca_off = options.set_gca_off;
    plotline = options.plotline;
    plotstack = options.plotstack;
    if plotstack
        plotline = false;
    end

    if plotline
        plot(time, data,dashtype, 'color',color_n);
    elseif plotstack
        [~, max_fr_bin] = max(data);
        [~,sortorder] = sort(max_fr_bin); 
        norm_data = data./max(data);
        imagesc([norm_data(:, sortorder)]')
    end
    if set_gca_off
    set(gca, 'Visible','off')
    end
    if ~isempty(yspan)
        axis([time(1),time(end),yspan]);
    end
    return
end