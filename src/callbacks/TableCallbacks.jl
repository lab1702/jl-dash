module TableCallbacks

using Dash
using DataFrames
using Dates

export register_table_callbacks!

"""
Register table-related callbacks.
"""
function register_table_callbacks!(app, df_ref::Ref{DataFrame})

    # Update table data based on stock selection and date range
    callback!(app,
        Output("stock-table", "data"),
        Output("stock-table", "columns"),
        Input("stock-dropdown", "value"),
        Input("date-range", "start_date"),
        Input("date-range", "end_date")
    ) do selected_stock, start_date, end_date
        df = df_ref[]

        start_dt = Date(start_date[1:10])
        end_dt = Date(end_date[1:10])

        # Filter data
        filtered = filter(row ->
            row.Symbol == selected_stock &&
            start_dt <= row.Date <= end_dt,
            df
        )

        # Sort by date descending (most recent first)
        sorted_df = sort(filtered, :Date, rev=true)

        # Create column definitions
        columns = [
            Dict("name" => "Symbol", "id" => "Symbol"),
            Dict("name" => "Date", "id" => "Date"),
            Dict("name" => "Open", "id" => "Open", "type" => "numeric",
                 "format" => Dict("specifier" => ".2f")),
            Dict("name" => "High", "id" => "High", "type" => "numeric",
                 "format" => Dict("specifier" => ".2f")),
            Dict("name" => "Low", "id" => "Low", "type" => "numeric",
                 "format" => Dict("specifier" => ".2f")),
            Dict("name" => "Close", "id" => "Close", "type" => "numeric",
                 "format" => Dict("specifier" => ".2f")),
            Dict("name" => "Volume", "id" => "Volume", "type" => "numeric"),
            Dict("name" => "Change %", "id" => "Change_Pct", "type" => "numeric",
                 "format" => Dict("specifier" => "+.2f")),
            Dict("name" => "MA 20", "id" => "MA_20", "type" => "numeric",
                 "format" => Dict("specifier" => ".2f")),
            Dict("name" => "MA 50", "id" => "MA_50", "type" => "numeric",
                 "format" => Dict("specifier" => ".2f"))
        ]

        # Convert DataFrame to vector of dicts for Dash
        data = Vector{Dict{String,Any}}()
        for row in eachrow(sorted_df)
            row_dict = Dict{String,Any}()
            row_dict["Symbol"] = row.Symbol
            row_dict["Date"] = string(row.Date)
            row_dict["Open"] = row.Open
            row_dict["High"] = row.High
            row_dict["Low"] = row.Low
            row_dict["Close"] = row.Close
            row_dict["Volume"] = row.Volume
            row_dict["Change_Pct"] = row.Change_Pct
            row_dict["MA_20"] = isnan(row.MA_20) ? nothing : row.MA_20
            row_dict["MA_50"] = isnan(row.MA_50) ? nothing : row.MA_50
            push!(data, row_dict)
        end

        return data, columns
    end
end

end # module
