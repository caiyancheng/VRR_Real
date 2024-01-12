function v = get_field_def( s, field, def_val )

if isfield( s, field )
    v = s.(field);
else
    v = def_val;
end

end