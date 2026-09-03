function read_tenv(filepath::String)
    open(filepath, "r") do io
        gps = Vector{TenvPoint}()
        for line in eachline(io)
            tokens = split(line)
            push!(gps, TenvPoint(
                tokens[1],
                tokens[2],
                parse(Float64, tokens[3]),
                parse(Int, tokens[4]),
                parse(Int, tokens[5]),
                parse(Int, tokens[6]),
                parse(Float64, tokens[7]),
                parse(Float64, tokens[8]),
                parse(Float64, tokens[9]),
                parse(Float64, tokens[10]),
                parse(Float64, tokens[11]),
                parse(Float64, tokens[12]),
                parse(Float64, tokens[13]),
                parse(Float64, tokens[14]),
                parse(Float64, tokens[15]),
                parse(Float64, tokens[16]),
            ))
        end
        return gps
    end
end
