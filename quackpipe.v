module main

import vduckdb
import vweb

import x.json2

pub struct ReqStats {
pub:
    elapsed_sec f64
    read_rows   i64
    read_bytes  i64
}

struct App {
        vweb.Context
pub:
        play string @[vweb_global]
mut:
        db vduckdb.DuckDB
}

@['/']
fn (mut app App) index() vweb.Result {
        query := app.query['query'] or { '' }
        if query == '' {
                return app.html(app.play.str())
        }
        _ := app.db.query(query) or { panic('bad query') }
        stats := ReqStats{
                elapsed_sec: 0.00031403
                read_rows: 3
                read_bytes: 0
        }

        return app.text(convert_result_to_json(app.db.get_array_as_string(),stats ))
}

@['/'; post]
fn (mut app App) query() vweb.Result {
        query := app.req.data
        if query == '' {
                return app.html(app.play.str())
        }
        _ := app.db.query(query) or { panic('bad query') }
        stats := ReqStats{
                elapsed_sec: 0.00031403
                read_rows: 3
                read_bytes: 0
        }

        return app.text(convert_result_to_json(app.db.get_array_as_string(), stats ))
}

fn main() {
        mut db := vduckdb.DuckDB{}
        println('vduckdb version: ${vduckdb.version()}')
        println('duckdb version: ${vduckdb.duckdb_library_version()}')

        _ := db.open(':memory:')!

        mut app := &App{
                play: $embed_file('./play.html').to_string()
                db: db
        }
        vweb.run(app, 8080)

        defer {
           db.close()
        }
}

          pub fn convert_result_to_json(result []map[string]string, stats ?ReqStats) string {
    mut root := map[string]json2.Any{}

    // Add meta information - get column names from first row if available
    mut meta_array := []json2.Any{}
    if result.len > 0 {
        for column_name in result[0].keys() {
            mut column_obj := map[string]json2.Any{}
            column_obj['name'] = json2.Any(column_name)
            // Since we don't have type info in map[string]string, defaulting to string
            column_obj['type'] = json2.Any('string')
            meta_array << json2.Any(column_obj)
        }
    }
    root['meta'] = json2.Any(meta_array)

    // Add data
    mut data_array := []json2.Any{}
    for row in result {
        mut row_array := []json2.Any{}
        for column_name in row.keys() {
            value := row[column_name]
            if value == 'NULL' {
                row_array << json2.Any(json2.Null{})
            } else {
                row_array << json2.Any(value)
            }
        }
        data_array << json2.Any(row_array)
    }
    root['data'] = json2.Any(data_array)

    // Add row count
    root['rows'] = json2.Any(result.len)

    // Add statistics if provided
    if req_stats := stats {
        mut stats_obj := map[string]json2.Any{}
        stats_obj['elapsed'] = json2.Any(req_stats.elapsed_sec)
        stats_obj['rows_read'] = json2.Any(req_stats.read_rows)
        stats_obj['bytes_read'] = json2.Any(req_stats.read_bytes)
        root['statistics'] = json2.Any(stats_obj)
    }

    // Convert to JSON string
    return json2.encode(root)

}
