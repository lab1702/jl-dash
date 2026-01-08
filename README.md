# Financial Dashboard

An interactive financial dashboard built with Julia and Dash, featuring real-time stock visualization and analysis tools.

## Features

- **Candlestick Charts**: OHLC price visualization with color-coded bullish/bearish candles
- **Volume Analysis**: Trading volume bar charts with directional coloring
- **Moving Averages**: Price trends with 20-day and 50-day moving average overlays
- **Stock Comparison**: Normalized percentage change comparison across multiple stocks
- **Interactive Data Table**: Sortable, filterable table with conditional formatting
- **Real-time Updates**: Optional auto-refresh with simulated price changes
- **Date Range Filtering**: Filter all visualizations by custom date ranges

## Project Structure

```
jl-dash/
├── app.jl                      # Application entry point
├── Project.toml                # Julia project dependencies
├── README.md
└── src/
    ├── callbacks/
    │   ├── ChartCallbacks.jl   # Chart update callbacks
    │   └── TableCallbacks.jl   # Data table callbacks
    ├── components/
    │   ├── Charts.jl           # Chart creation functions
    │   └── Layout.jl           # Dashboard UI layout
    └── data/
        └── DataGenerator.jl    # Sample OHLCV data generation
```

## Requirements

- Julia 1.6 or later
- Dash.jl
- DataFrames.jl

## Installation

1. Clone or download this repository

2. Navigate to the project directory:
   ```bash
   cd jl-dash
   ```

3. Start Julia and activate the project:
   ```bash
   julia --project=.
   ```

4. Install dependencies (first time only):
   ```julia
   using Pkg
   Pkg.instantiate()
   ```

## Usage

Run the dashboard:

```bash
julia app.jl
```

Or from the Julia REPL:

```julia
include("app.jl")
```

Then open your browser to http://localhost:8050

## Dashboard Controls

- **Select Stock**: Choose a single stock for detailed analysis (candlestick, volume, MA charts)
- **Compare Stocks**: Select multiple stocks for side-by-side percentage change comparison
- **Date Range**: Filter data by start and end dates
- **Auto Refresh**: Enable 5-second automatic updates with simulated price changes

## Sample Data

The dashboard generates synthetic OHLCV data for demonstration purposes:

- **Stocks**: AAPL, GOOGL, MSFT, AMZN, TSLA
- **Time Period**: ~1 year of daily data (weekdays only)
- **Data Points**: Open, High, Low, Close, Volume, Daily Change %, MA-20, MA-50

Price series are generated using geometric Brownian motion to simulate realistic market behavior.

## License

MIT
