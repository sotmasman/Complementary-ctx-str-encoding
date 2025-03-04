function pdf_dstr = get_pdf_ros(xaxis, xaxis_analysis, this_all_modulated)
    % sorted_dstr = sort(dstr);

    
    pdf_dstr = zeros(1,length(xaxis_analysis));
    for mm = 1:length(this_all_modulated)
        this_cell_mod_time = this_all_modulated{mm};
        pdf_dstr(this_cell_mod_time) = pdf_dstr(this_cell_mod_time) + 1;
    end
    pdf_dstr = pdf_dstr((xaxis_analysis>=xaxis(1)) &...
                    (xaxis_analysis<=xaxis(end)));
    
end