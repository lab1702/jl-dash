module Layout

using Dash
using Dates

export build_layout

function build_layout(stock_symbols::Vector{String})
    html_div(
        style = Dict("fontFamily" => "Arial, sans-serif", "padding" => "20px", "maxWidth" => "1400px", "margin" => "0 auto"),
        children = [
            # Header
            html_h1("Financial Dashboard",
                style = Dict("textAlign" => "center", "color" => "#2c3e50", "marginBottom" => "30px")
            ),

            # Filters Row
            html_div(
                style = Dict("display" => "flex", "justifyContent" => "space-between",
                            "marginBottom" => "20px", "flexWrap" => "wrap", "gap" => "15px",
                            "backgroundColor" => "#f8f9fa", "padding" => "15px", "borderRadius" => "8px"),
                children = [
                    # Stock Selector
                    html_div(
                        style = Dict("minWidth" => "180px"),
                        children = [
                            html_label("Select Stock:", style = Dict("fontWeight" => "bold", "display" => "block", "marginBottom" => "5px")),
                            dcc_dropdown(
                                id = "stock-dropdown",
                                options = [(label = s, value = s) for s in stock_symbols],
                                value = stock_symbols[1],
                                clearable = false
                            )
                        ]
                    ),

                    # Multi-Stock Selector (for comparison)
                    html_div(
                        style = Dict("minWidth" => "280px"),
                        children = [
                            html_label("Compare Stocks:", style = Dict("fontWeight" => "bold", "display" => "block", "marginBottom" => "5px")),
                            dcc_dropdown(
                                id = "multi-stock-dropdown",
                                options = [(label = s, value = s) for s in stock_symbols],
                                value = stock_symbols[1:min(2, length(stock_symbols))],
                                multi = true
                            )
                        ]
                    ),

                    # Date Range Picker
                    html_div(
                        style = Dict("minWidth" => "280px"),
                        children = [
                            html_label("Date Range:", style = Dict("fontWeight" => "bold", "display" => "block", "marginBottom" => "5px")),
                            dcc_datepickerrange(
                                id = "date-range",
                                min_date_allowed = today() - Day(365),
                                max_date_allowed = today(),
                                start_date = today() - Day(90),
                                end_date = today(),
                                display_format = "YYYY-MM-DD"
                            )
                        ]
                    ),

                    # Auto-refresh toggle
                    html_div(
                        style = Dict("minWidth" => "150px"),
                        children = [
                            html_label("Auto Refresh:", style = Dict("fontWeight" => "bold", "display" => "block", "marginBottom" => "5px")),
                            dcc_checklist(
                                id = "auto-refresh-toggle",
                                options = [(label = " Enable (5s)", value = "enabled")],
                                value = []
                            )
                        ]
                    )
                ]
            ),

            # Primary Charts Row
            html_div(
                style = Dict("display" => "flex", "justifyContent" => "space-between",
                            "marginBottom" => "20px", "flexWrap" => "wrap", "gap" => "20px"),
                children = [
                    html_div(
                        style = Dict("flex" => "1", "minWidth" => "450px"),
                        children = dcc_graph(id = "candlestick-chart")
                    ),
                    html_div(
                        style = Dict("flex" => "1", "minWidth" => "450px"),
                        children = dcc_graph(id = "volume-chart")
                    )
                ]
            ),

            # Secondary Charts Row
            html_div(
                style = Dict("display" => "flex", "justifyContent" => "space-between",
                            "marginBottom" => "20px", "flexWrap" => "wrap", "gap" => "20px"),
                children = [
                    html_div(
                        style = Dict("flex" => "1", "minWidth" => "450px"),
                        children = dcc_graph(id = "ma-chart")
                    ),
                    html_div(
                        style = Dict("flex" => "1", "minWidth" => "450px"),
                        children = dcc_graph(id = "comparison-chart")
                    )
                ]
            ),

            # Data Table Section
            html_div(
                style = Dict("marginBottom" => "20px"),
                children = [
                    html_h3("Stock Data", style = Dict("color" => "#2c3e50", "marginBottom" => "10px")),
                    dash_datatable(
                        id = "stock-table",
                        columns = [],
                        data = [],
                        page_size = 15,
                        page_action = "native",
                        sort_action = "native",
                        sort_mode = "multi",
                        filter_action = "native",
                        style_table = Dict("overflowX" => "auto"),
                        style_cell = Dict(
                            "textAlign" => "center",
                            "padding" => "10px",
                            "minWidth" => "80px",
                            "fontFamily" => "Arial, sans-serif"
                        ),
                        style_header = Dict(
                            "backgroundColor" => "#2c3e50",
                            "color" => "white",
                            "fontWeight" => "bold"
                        ),
                        style_data_conditional = [
                            Dict(
                                "if" => Dict("filter_query" => "{Change_Pct} > 0"),
                                "backgroundColor" => "#d4edda",
                                "color" => "#155724"
                            ),
                            Dict(
                                "if" => Dict("filter_query" => "{Change_Pct} < 0"),
                                "backgroundColor" => "#f8d7da",
                                "color" => "#721c24"
                            )
                        ]
                    )
                ]
            ),

            # Summary Stats (Live)
            html_div(
                id = "summary-stats",
                style = Dict(
                    "display" => "flex",
                    "justifyContent" => "space-around",
                    "backgroundColor" => "#f8f9fa",
                    "padding" => "20px",
                    "borderRadius" => "8px",
                    "flexWrap" => "wrap",
                    "gap" => "15px"
                ),
                children = [
                    html_div(id = "current-price", children = "Current Price: --"),
                    html_div(id = "day-change", children = "Day Change: --"),
                    html_div(id = "day-volume", children = "Volume: --"),
                    html_div(id = "last-updated", children = "Last Updated: --")
                ]
            ),

            # Interval component for real-time updates
            dcc_interval(
                id = "interval-component",
                interval = 5000,  # 5 seconds
                n_intervals = 0,
                disabled = true  # Controlled by toggle
            ),

            # Hidden store for data
            dcc_store(id = "data-store")
        ]
    )
end

end # module
