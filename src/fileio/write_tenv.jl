function write_tenv(
    filepath::String,
    gps::Vector{TenvPoint}
)
    open(filepath, "w") do io
        for pt in gps
            @printf(io, "%s %7s %9.4f %5d %4d %1d %10.6f %10.6f %10.6f %7.4f %8.6f %8.6f %8.6f %9.6f %9.6f %9.6f\n",
                pt.id,
                pt.date,
                pt.decy,
                pt.mjd,
                pt.week,
                pt.day,
                pt.e - gps[1].e,
                pt.n - gps[1].n,
                pt.u - gps[1].u,
                pt.antennaHeight,
                pt.sige,
                pt.sign,
                pt.sigu,
                pt.coren,
                pt.coreu,
                pt.cornu
            )
        end
    end
end
