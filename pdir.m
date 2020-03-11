% escape the backslash in Unix directories so that we can
% print out the directory name.
%
% ie, if in="foo\bar.txt" then out="foo\\bat.txt"

function str = pdir(in)
    str = regexprep(in, '(\\)', '\\$1');
end