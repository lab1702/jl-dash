# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
# Run the dashboard (from project directory)
julia app.jl

# Or from Julia REPL with project environment
julia --project=.
include("app.jl")

# Install dependencies (first time only)
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

The server runs on http://localhost:8050 with debug mode enabled.

## Architecture

This is a Julia/Dash.jl financial dashboard with a modular MVC-style structure:

```
app.jl                          # Entry point - initializes data, registers callbacks, starts server
src/
├── data/DataGenerator.jl       # Synthetic OHLCV data using Geometric Brownian Motion
├── components/
│   ├── Layout.jl               # Dashboard UI structure (build_layout)
│   └── Charts.jl               # Plotly chart creation (candlestick, volume, MA, comparison)
└── callbacks/
    ├── ChartCallbacks.jl       # Reactive updates for all charts
    └── TableCallbacks.jl       # Data table formatting and sorting
```

### Data Flow

1. `app.jl` generates synthetic stock data at startup and stores it in a `Ref{DataFrame}` container (`const DATA`)
2. Callbacks access this shared state to filter and render charts based on user input
3. All callbacks are registered via `register_chart_callbacks!` and `register_table_callbacks!`

### Key Patterns

- **State container**: Global `const DATA = Ref{DataFrame}()` allows callbacks to access mutable data
- **Date handling**: Dash sends dates as ISO strings; parse with `Date(string[1:10])`
- **Input conversion**: Dash.jl may pass `JSON3.Array` for dropdown values; handle both vector and single-value cases
- **Moving averages**: MA-20 and MA-50 columns contain `NaN` for early rows where calculation isn't possible

### Stock Symbols

`SYMBOLS = ["AAPL", "GOOGL", "MSFT", "AMZN", "TSLA"]` defined in DataGenerator.jl
