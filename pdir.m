function str = pdir(in)
    str = regexprep(in, '(\\)', '\\$1');
end