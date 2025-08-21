# InfinibandVerbs.jl Documentation

!!! warning "🚧 👷 Under construction 👷 🚧"

    This documenation is under construction.

Here are some of the more commonly used high level API functions.  They are
presented in these sections:

```@contents
```

## General functions

These structure and functions are useful for both sending and receiving packets.

```@docs
Context
hascapability
post_wrs
repost_loop
```

## Send related functions

These functions are useful when sending packets.

```@docs
create_send_wrs
```

## Receive related functions

These functions are useful when receiving packets.

```@docs
create_recv_wrs
create_flow
destroy_flow
```

## Lesser directly-used functions

These functions see less direct use because they are called by more commonly
used functions, but sometimes the more commonly used functions expose parameters
that are passed on to these functions.

```@docs
create_sges
```

## Index

```@index
```
