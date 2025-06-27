# ibv_query port

export ibv_query_port

function ibv_query_port(context, port_num, port_attr)
    ccall((:ibv_query_port, libibverbs), Cint, (Ptr{ibv_context}, UInt8, Ptr{ibv_port_attr}), context, port_num, port_attr)
end
