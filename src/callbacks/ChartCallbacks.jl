module ChartCallbacks

using Dash
using DataFrames
using Dates
using Random

export register_chart_callbacks!

"""
Format large numbers for display (e.g., 1.5M, 250K).
"""
function format_number(n::Integer)
    if n >= 1_000_000
        return string(round(n / 1_000_000, digits=2), "M")
    elseif n >= 1_000
        return string(round(n / 1_000, digits=2), "K")
    end
    return string(n)
end

"""
Register all chart-related callbacks.
"""
function register_chart_callbacks!(app, df_ref::Ref{DataFrame}, create_candlestick, create_volume_chart, create_ma_chart, create_comparison_chart)

    # Callback: Update all single-stock charts when stock or date range changes
    callback!(app,
        Output("candlestick-chart", "figure"),
        Output("volume-chart", "figure"),
        Output("ma-chart", "figure"),
        Input("stock-dropdown", "value"),
        Input("date-range", "start_date"),
        Input("date-range", "end_date")
    ) do selected_stock, start_date, end_date
        df = df_ref[]

        # Filter by date range
        start_dt = Date(start_date[1:10])  # Handle ISO format
        end_dt = Date(end_date[1:10])
        filtered = filter(row -> start_dt <= row.Date <= end_dt, df)

        candlestick = create_candlestick(filtered, selected_stock)
        volume = create_volume_chart(filtered, selected_stock)
        ma = create_ma_chart(filtered, selected_stock)

        return candlestick, volume, ma
    end

    # Callback: Update comparison chart when multi-stock selection changes
    callback!(app,
        Output("comparison-chart", "figure"),
        Input("multi-stock-dropdown", "value"),
        Input("date-range", "start_date"),
        Input("date-range", "end_date")
    ) do selected_stocks, start_date, end_date
        # Handle nothing or empty selection
        if isnothing(selected_stocks)
            return Dict(
                "data" => [],
                "layout" => Dict(
                    "title" => Dict("text" => "Select stocks to compare", "font" => Dict("size" => 16)),
                    "xaxis" => Dict("title" => "Date"),
                    "yaxis" => Dict("title" => "% Change from Start"),
                    "height" => 400,
                    "margin" => Dict("l" => 50, "r" => 30, "t" => 50, "b" => 70)
                )
            )
        end

        df = df_ref[]

        # Handle single value (not array) case - convert to Vector{String}
        # Note: Dash passes JSON3.Array, so we need to collect elements explicitly
        stocks = if selected_stocks isa AbstractVector
            [string(s) for s in selected_stocks]
        else
            [string(selected_stocks)]
        end

        if isempty(stocks)
            return Dict(
                "data" => [],
                "layout" => Dict(
                    "title" => Dict("text" => "Select stocks to compare", "font" => Dict("size" => 16)),
                    "xaxis" => Dict("title" => "Date"),
                    "yaxis" => Dict("title" => "% Change from Start"),
                    "height" => 400,
                    "margin" => Dict("l" => 50, "r" => 30, "t" => 50, "b" => 70)
                )
            )
        end

        start_dt = Date(start_date[1:10])
        end_dt = Date(end_date[1:10])
        filtered = filter(row -> start_dt <= row.Date <= end_dt, df)

        return create_comparison_chart(filtered, stocks)
    end

    # Callback: Enable/disable interval based on toggle
    callback!(app,
        Output("interval-component", "disabled"),
        Input("auto-refresh-toggle", "value")
    ) do toggle_value
        return isempty(toggle_value) || !("enabled" in toggle_value)
    end

    # Callback: Real-time update triggered by interval
    callback!(app,
        Output("summary-stats", "children"),
        Input("interval-component", "n_intervals"),
        Input("stock-dropdown", "value")
    ) do n_intervals, selected_stock
        df = df_ref[]

        # Get latest data for selected stock
        stock_data = filter(row -> row.Symbol == selected_stock, df)

        if nrow(stock_data) == 0
            return [
                html_div("No data available")
            ]
        end

        latest = last(stock_data)

        # Add some simulated real-time noise
        price_noise = 1 + 0.002 * randn()
        current_price = round(latest.Close * price_noise, digits=2)
        change = round((current_price - latest.Open) / latest.Open * 100, digits=2)
        change_str = change >= 0 ? "+$change%" : "$change%"

        summary = [
            html_div(
                style = Dict("textAlign" => "center"),
                children = [
                    html_div("Current Price", style = Dict("fontWeight" => "bold", "fontSize" => "12px", "color" => "#666")),
                    html_div("\$$current_price",
                        style = Dict("fontSize" => "24px", "fontWeight" => "bold",
                                    "color" => change >= 0 ? "#26a69a" : "#ef5350"))
                ]
            ),
            html_div(
                style = Dict("textAlign" => "center"),
                children = [
                    html_div("Day Change", style = Dict("fontWeight" => "bold", "fontSize" => "12px", "color" => "#666")),
                    html_div(change_str,
                        style = Dict("fontSize" => "24px", "fontWeight" => "bold",
                                    "color" => change >= 0 ? "#26a69a" : "#ef5350"))
                ]
            ),
            html_div(
                style = Dict("textAlign" => "center"),
                children = [
                    html_div("Volume", style = Dict("fontWeight" => "bold", "fontSize" => "12px", "color" => "#666")),
                    html_div(format_number(latest.Volume),
                        style = Dict("fontSize" => "24px", "fontWeight" => "bold", "color" => "#2c3e50"))
                ]
            ),
            html_div(
                style = Dict("textAlign" => "center"),
                children = [
                    html_div("Last Updated", style = Dict("fontWeight" => "bold", "fontSize" => "12px", "color" => "#666")),
                    html_div(Dates.format(now(), "HH:MM:SS"),
                        style = Dict("fontSize" => "24px", "fontWeight" => "bold", "color" => "#2c3e50"))
                ]
            )
        ]

        return summary
    end
end

end # module
