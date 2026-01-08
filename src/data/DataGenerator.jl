module DataGenerator

using DataFrames
using Dates
using Random
using Statistics

const SYMBOLS = ["AAPL", "GOOGL", "MSFT", "AMZN", "TSLA"]

const BASE_PRICES = Dict(
    "AAPL" => 175.0,
    "GOOGL" => 140.0,
    "MSFT" => 370.0,
    "AMZN" => 180.0,
    "TSLA" => 250.0
)

"""
Generate a price series using geometric Brownian motion.
"""
function generate_price_series(symbol::String, start_date::Date, days::Int; seed=nothing)
    !isnothing(seed) && Random.seed!(seed)

    base_price = BASE_PRICES[symbol]
    daily_volatility = 0.02  # 2% daily volatility
    drift = 0.0001           # Small upward drift

    # Generate date range and filter to weekdays
    all_dates = collect(start_date:Day(1):start_date + Day(days - 1))
    dates = filter(d -> dayofweek(d) <= 5, all_dates)

    n = length(dates)
    prices = zeros(n)
    prices[1] = base_price

    # Geometric Brownian Motion
    for i in 2:n
        returns = drift + daily_volatility * randn()
        prices[i] = prices[i-1] * exp(returns)
    end

    return dates, prices
end

"""
Calculate simple moving average.
"""
function moving_average(data::Vector{Float64}, window::Int)
    n = length(data)
    result = fill(NaN, n)
    for i in window:n
        result[i] = mean(data[i-window+1:i])
    end
    return result
end

"""
Generate OHLCV data for a single stock.
"""
function generate_ohlcv(symbol::String, start_date::Date, days::Int)
    dates, close_prices = generate_price_series(symbol, start_date, days)
    n = length(dates)

    # Generate OHLCV data around closing prices
    opens = close_prices .* (1 .+ 0.01 .* randn(n))
    highs = max.(opens, close_prices) .* (1 .+ abs.(0.015 .* randn(n)))
    lows = min.(opens, close_prices) .* (1 .- abs.(0.015 .* randn(n)))
    volumes = round.(Int, 1e6 .* (5 .+ 3 .* rand(n)))

    # Calculate daily change percentage
    changes = zeros(n)
    changes[1] = 0.0
    for i in 2:n
        changes[i] = (close_prices[i] - close_prices[i-1]) / close_prices[i-1] * 100
    end

    # Calculate moving averages
    ma_20 = moving_average(close_prices, 20)
    ma_50 = moving_average(close_prices, 50)

    DataFrame(
        Symbol = fill(symbol, n),
        Date = dates,
        Open = round.(opens, digits=2),
        High = round.(highs, digits=2),
        Low = round.(lows, digits=2),
        Close = round.(close_prices, digits=2),
        Volume = volumes,
        Change_Pct = round.(changes, digits=2),
        MA_20 = round.(ma_20, digits=2),
        MA_50 = round.(ma_50, digits=2)
    )
end

"""
Generate data for all stocks.
"""
function generate_all_stocks(start_date::Date, days::Int)
    dfs = [generate_ohlcv(s, start_date, days) for s in SYMBOLS]
    vcat(dfs...)
end

export SYMBOLS, generate_all_stocks, generate_ohlcv

end # module
