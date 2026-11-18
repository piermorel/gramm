function w=text_probe_width(probe)
% Width in pixels of the string of a text object used to measure text
% (invisible, with 'Units' set to 'pixels'). On systems without a display,
% e.g. MATLAB on a Linux CI runner, text extents are a constant placeholder
% whatever the string. The width is then estimated from the number of
% characters and the font size, generously so that legends and titles
% aren't clipped. Whether text can be measured is checked once per session

persistent measurable
if isempty(measurable)
    str=probe.String;
    probe.String='M';
    one=probe.Extent(3);
    probe.String='MM';
    measurable=probe.Extent(3)>one;
    probe.String=str;
end

if measurable
    w=probe.Extent(3);
else
    %Longest line, in characters, at about 0.6 times the font size each
    %(Helvetica averages about 0.5), font size converted from points
    n=max([0 cellfun(@numel,cellstr(probe.String))]);
    if strcmp(probe.FontWeight,'bold')
        em=0.65;
    else
        em=0.6;
    end
    w=n*em*probe.FontSize*get(groot,'ScreenPixelsPerInch')/72;
end

end
