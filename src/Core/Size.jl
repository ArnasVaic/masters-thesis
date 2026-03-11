struct Size
    width::Int
    height::Int

    function Size(width::Int, height::Int)
        width > 0 || error("required: width > 0")
        height > 0 || error("required: height > 0")
        return new(width, height)
    end
end

Base.:/(a::Size, b::Size) =
    Size(div(a.width, b.width), div(a.height, b.height))
