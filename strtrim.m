function out = strtrim(in)

%trim leading and trailing spaces
out = in;
a = findstrchr(' ', out);
while (a(1) == 1)
  if length(out) > 1
    out = out(2:length(out));
  else
    out = '';
  end
  a = findstrchr(' ', out);
end
while (a & (a(length(a)) == length(out)) )
  if length(out) > 1
    out = out(1:length(out)-1);
  else
    out = '';
  end
  a = findstrchr(' ', out);
end