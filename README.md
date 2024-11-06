<a href="https://quackpipe.fly.dev" target="_blank"><img src="https://user-images.githubusercontent.com/1423657/231310060-aae46ee6-c748-44c9-905e-20a4eba0a814.png" width=220 /></a>

> _a pipe for quackheads_

# :baby_chick: vQuackpipe

Minimal DuckDB Quackpipe... in [vlang](vlang.io)

> _QuackPipe is a serverless OLAP API built on top of DuckDB

<br>

### Requirements
- The latest [vlang](https://vlang.io/) version
- The latest DuckDB library should be downloaded to the `/thirdparty` folder before compiling
```
mkdir thirdparty && cd thirdparty
wget https://github.com/duckdb/duckdb/releases/latest/download/libduckdb-linux-amd64.zip
unzip libduckdb-linux-amd64.zip
```

### Build
```
v -prod quackpipe.v
```

