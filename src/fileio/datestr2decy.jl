function datestr2decy(
    date_str::String,
    format::String
)
    df = DateFormat(format)
    date = Date(date_str, df)
    yr = year(date)
    start_year = Date(yr, 1, 1)
    next_year = Date(yr + 1, 1, 1)
    decy = yr + Dates.value(date - start_year) / Dates.value(next_year - start_year)
    return decy
end
