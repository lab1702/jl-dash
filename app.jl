#!/usr/bin/env julia
#
# Financial Dashboard - Entry Point
# Run with: julia app.jl
#

# Activate project environment
using Pkg
Pkg.activate(@__DIR__)

# Check and install dependencies if needed
deps = ["Dash", "DataFrames"]
installed = keys(Pkg.project().dependencies)
for dep in deps
    if !(dep in installed)
        println("Installing $dep...")
        Pkg.add(dep)
    end
end

using Dash
using DataFrames
using Dates

# Include local modules
include("src/data/DataGenerator.jl")
include("src/components/Layout.jl")
include("src/components/Charts.jl")
include("src/callbacks/ChartCallbacks.jl")
include("src/callbacks/TableCallbacks.jl")

using .DataGenerator
using .Layout
using .Charts
using .ChartCallbacks
using .TableCallbacks

# Initialize data
println("=" ^ 50)
println("Financial Dashboard")
println("=" ^ 50)
println()
println("Generating sample financial data...")

const START_DATE = today() - Day(365)
const DAYS = 400  # Generate ~1 year of trading days

# Store data in a Ref for access in callbacks
const DATA = Ref(generate_all_stocks(START_DATE, DAYS))

println("Generated $(nrow(DATA[])) rows of data for $(length(SYMBOLS)) stocks")
println("Stocks: $(join(SYMBOLS, ", "))")
println()

# Create Dash app
app = dash(
    external_stylesheets = [
        "https://codepen.io/chriddyp/pen/bWLwgP.css"
    ],
    suppress_callback_exceptions = true
)

# Set layout
app.layout = build_layout(SYMBOLS)

# Register callbacks
register_chart_callbacks!(app, DATA, create_candlestick, create_volume_chart, create_ma_chart, create_comparison_chart)
register_table_callbacks!(app, DATA)

# Run server
println("Starting dashboard server...")
println("Open your browser to: http://localhost:8050")
println()
println("Press Ctrl+C to stop the server")
println()

run_server(app, "0.0.0.0", 8050, debug=true)
