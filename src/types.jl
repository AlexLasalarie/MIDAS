struct StationLLH
    id::String
    lat::Float64
    lon::Float64
    hgt::Float64
end

struct Step
    site::String
    decy::Float64
    date::String
    type::Int

    # Constructor if given all fields
    function Step(
        site::String,
        decy::Float64,
        date::String,
        type::Int
    )
        new(site, decy, date, type)
    end

    # Constructor if decimal year is not given
    function Step(
        site::String,
        date::String,
        type::Int
    )
        fulldate = "20" * date
        dt = Date(fulldate, dateformat"yyyyuuudd")
        yr = year(dt)
        start_year = Date(yr, 1, 1)
        next_year = Date(yr + 1, 1, 1)
        decy = yr + Dates.value(dt - start_year) / Dates.value(next_year - start_year)
        new(site, decy, date, type)
    end
end

struct TenvPoint
    id::String
    date::String
    decy::Float64
    mjd::Int
    week::Int
    day::Int
    e::Float64
    n::Float64
    u::Float64
    antennaHeight::Float64
    sige::Float64
    sign::Float64
    sigu::Float64
    coren::Float64
    coreu::Float64
    cornu::Float64
end

struct VelData
    site::String
    version::String
    t1::Float64
    t2::Float64
    tspan::Float64
    epoch_total::Int
    epoch_valid::Int
    npairs::Int
    e::Float64
    n::Float64
    u::Float64
    unc_e::Float64
    unc_n::Float64
    unc_u::Float64
    off_e::Float64
    off_n::Float64
    off_u::Float64
    out_e::Float64
    out_n::Float64
    out_u::Float64
    sig_e::Float64
    sig_n::Float64
    sig_u::Float64
    nstep::Int
end
