module Charts

using DataFrames
using Dates

export create_candlestick, create_volume_chart, create_ma_chart, create_comparison_chart

"""
Create a candlestick chart for OHLC data.
"""
function create_candlestick(df::DataFrame, symbol::String)
    stock_data = filter(row -> row.Symbol == symbol, df)

    if nrow(stock_data) == 0
        return Dict(
            "data" => [],
            "layout" => Dict("title" => "No data available")
        )
    end

    Dict(
        "data" => [
            Dict(
                "type" => "candlestick",
                "x" => string.(stock_data.Date),
                "open" => stock_data.Open,
                "high" => stock_data.High,
                "low" => stock_data.Low,
                "close" => stock_data.Close,
                "name" => symbol,
                "increasing" => Dict("line" => Dict("color" => "#26a69a")),
                "decreasing" => Dict("line" => Dict("color" => "#ef5350"))
            )
        ],
        "layout" => Dict(
            "title" => Dict("text" => "$symbol Price Chart", "font" => Dict("size" => 16)),
            "xaxis" => Dict("title" => "Date", "rangeslider" => Dict("visible" => false)),
            "yaxis" => Dict("title" => "Price (USD)"),
            "height" => 400,
            "margin" => Dict("l" => 50, "r" => 30, "t" => 50, "b" => 50)
        )
    )
end

"""
Create a volume bar chart.
"""
function create_volume_chart(df::DataFrame, symbol::String)
    stock_data = filter(row -> row.Symbol == symbol, df)

    if nrow(stock_data) == 0
        return Dict(
            "data" => [],
            "layout" => Dict("title" => "No data available")
        )
    end

    # Color bars based on price direction
    colors = [close >= open ? "#26a69a" : "#ef5350"
              for (close, open) in zip(stock_data.Close, stock_data.Open)]

    Dict(
        "data" => [
            Dict(
                "type" => "bar",
                "x" => string.(stock_data.Date),
                "y" => stock_data.Volume,
                "name" => "Volume",
                "marker" => Dict("color" => colors)
            )
        ],
        "layout" => Dict(
            "title" => Dict("text" => "$symbol Trading Volume", "font" => Dict("size" => 16)),
            "xaxis" => Dict("title" => "Date"),
            "yaxis" => Dict("title" => "Volume"),
            "height" => 400,
            "margin" => Dict("l" => 50, "r" => 30, "t" => 50, "b" => 50)
        )
    )
end

"""
Create a line chart with closing price and moving averages.
"""
function create_ma_chart(df::DataFrame, symbol::String)
    stock_data = filter(row -> row.Symbol == symbol, df)

    if nrow(stock_data) == 0
        return Dict(
            "data" => [],
            "layout" => Dict("title" => "No data available")
        )
    end

    # Filter out NaN values for MA display
    ma20_valid = .!isnan.(stock_data.MA_20)
    ma50_valid = .!isnan.(stock_data.MA_50)

    Dict(
        "data" => [
            Dict(
                "type" => "scatter",
                "mode" => "lines",
                "x" => string.(stock_data.Date),
                "y" => stock_data.Close,
                "name" => "Close Price",
                "line" => Dict("color" => "#2196F3", "width" => 2)
            ),
            Dict(
                "type" => "scatter",
                "mode" => "lines",
                "x" => string.(stock_data.Date[ma20_valid]),
                "y" => stock_data.MA_20[ma20_valid],
                "name" => "MA 20",
                "line" => Dict("color" => "#FF9800", "width" => 1, "dash" => "dash")
            ),
            Dict(
                "type" => "scatter",
                "mode" => "lines",
                "x" => string.(stock_data.Date[ma50_valid]),
                "y" => stock_data.MA_50[ma50_valid],
                "name" => "MA 50",
                "line" => Dict("color" => "#9C27B0", "width" => 1, "dash" => "dot")
            )
        ],
        "layout" => Dict(
            "title" => Dict("text" => "$symbol Moving Averages", "font" => Dict("size" => 16)),
            "xaxis" => Dict("title" => "Date"),
            "yaxis" => Dict("title" => "Price (USD)"),
            "legend" => Dict("orientation" => "h", "y" => -0.15),
            "height" => 400,
            "margin" => Dict("l" => 50, "r" => 30, "t" => 50, "b" => 70)
        )
    )
end

"""
Create a comparison chart showing normalized percentage change for multiple stocks.
"""
function create_comparison_chart(df::DataFrame, symbols::Vector)
    traces = Dict{String,Any}[]

    for sym in symbols
        symbol = string(sym)
        stock_data = filter(row -> row.Symbol == symbol, df)

        if nrow(stock_data) > 0
            stock_data = sort(stock_data, :Date)

            # Normalize prices to percentage change from first day
            first_price = Float64(stock_data.Close[1])
            close_prices = Float64.(stock_data.Close)
            normalized = (close_prices ./ first_price .- 1.0) .* 100.0

            push!(traces, Dict{String,Any}(
                "type" => "scatter",
                "mode" => "lines",
                "x" => string.(stock_data.Date),
                "y" => collect(normalized),
                "name" => symbol
            ))
        end
    end

    Dict{String,Any}(
        "data" => traces,
        "layout" => Dict{String,Any}(
            "title" => Dict{String,Any}("text" => "Stock Comparison (% Change)", "font" => Dict{String,Any}("size" => 16)),
            "xaxis" => Dict{String,Any}("title" => "Date"),
            "yaxis" => Dict{String,Any}("title" => "% Change from Start"),
            "legend" => Dict{String,Any}("orientation" => "h", "y" => -0.15),
            "height" => 400,
            "margin" => Dict{String,Any}("l" => 50, "r" => 30, "t" => 50, "b" => 70),
            "hovermode" => "x unified"
        )
    )
end

end # module
