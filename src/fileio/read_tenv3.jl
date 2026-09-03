function read_tenv3(filepath::String)
    gps = Vector{TenvPoint}()
    open(filepath, "r") do io
        for (k, line) in enumerate(eachline(io))
            if k == 1
                continue
            end
            tokens = split(line)
            site = tokens[1]
            date = tokens[2]
            decy = parse(Float64, tokens[3])
            mjd = parse(Int, tokens[4])
            gps_week = parse(Int, tokens[5])
            gps_day = parse(Int, tokens[6])
            ref_lon = parse(Float64, tokens[7])
            e = parse(Float64, tokens[8]) + parse(Float64, tokens[9])
            n = parse(Float64, tokens[10]) + parse(Float64, tokens[11])
            u = parse(Float64, tokens[12]) + parse(Float64, tokens[13])
            antenna_hgt = parse(Float64, tokens[14])
            sige = parse(Float64, tokens[15])
            sign = parse(Float64, tokens[16])
            sigu = parse(Float64, tokens[17])
            coren = parse(Float64, tokens[18])
            coreu = parse(Float64, tokens[19])
            cornu = parse(Float64, tokens[20])
            lat = parse(Float64, tokens[21])
            lon = parse(Float64, tokens[22])
            hgt = parse(Float64, tokens[23])
            push!(gps, TenvPoint(
                site,
                date,
                decy,
                mjd,
                gps_week,
                gps_day,
                e,
                n,
                u,
                antenna_hgt,
                sige,
                sign,
                sigu,
                coren,
                coreu,
                cornu
            ))
        end
    end
    return gps
end
