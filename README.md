# tcp_interface
[](https://github.com/djani2703/tcp_interface/blob/main/README.md#tcp_interface)

A TCP echo server application built with Erlang/OTP and Rebar3.

The application listens on a configurable TCP port. Each accepted connection
is handled by a `gen_server` process that sends received data back to the
client.

## Features
[](https://github.com/djani2703/tcp_interface/blob/main/README.md#features)

- TCP echo server using Erlang's `gen_tcp`
- Dynamic `gen_server` workers supervised by an OTP supervisor
- Configurable listening port (default: `8080`)
- Rebar3 build and formatting workflow

## Architecture
[](https://github.com/djani2703/tcp_interface/blob/main/README.md#architecture)

```
                     tcp_interface_app
                            |
                 +----------+----------+
                 |                     |
                 v                     v
          TCP listening socket   tcp_interface_sup
                                       |
                                       v
                              tcp_interface_server
                               accepts a connection
                                       |
                              starts the next acceptor
                                       |
                                       v
                              echoes client data
```

The application opens the listening socket and starts the supervisor. A server
worker accepts a client connection, starts another worker to accept the next
connection, and echoes data received from its client.

## Configuration
[](https://github.com/djani2703/tcp_interface/blob/main/README.md#configuration)

The listening port is configured in `config/sys.config`. The default is
`8080`.

```erlang
[
    {tcp_interface, [
        {port, 8080}
    ]}
].
```

Change `8080` to the port the server should listen on.

## Build
[](https://github.com/djani2703/tcp_interface/blob/main/README.md#build)

Compile the application with:

```sh
rebar3 compile
```

## Format
[](https://github.com/djani2703/tcp_interface/blob/main/README.md#format)

Format the Erlang source code with:

```sh
rebar3 format
```

This command uses the `rebar3_format` plugin configured in `rebar.config`.

## Run
[](https://github.com/djani2703/tcp_interface/blob/main/README.md#run)

Start the application shell with:

```sh
rebar3 shell
```

Connect to the server from another terminal using `nc`:

```sh
nc 127.0.0.1 8080
```

Text sent through the connection is echoed back by the server.

## License
[](https://github.com/djani2703/tcp_interface/blob/main/README.md#license)

See [LICENSE.md](LICENSE.md).
