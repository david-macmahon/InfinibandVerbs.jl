# ibv_query port

export ibv_query_port

function ibv_query_port(context, port_num, port_attr)
    ccall((:ibv_query_port, libibverbs), Cint, (Ptr{ibv_context}, UInt8, Ptr{ibv_port_attr}), context, port_num, port_attr)
end

# Functions that are static inline in verbs.h

# Get ibv_context_ops struct from an Ptr{ibv_context}
function get_ibv_context_op(ctx::Ptr{ibv_context}, op::Symbol)
    op_offset = fieldoffset(ibv_context_ops, findfirst(==(op), fieldnames(ibv_context_ops)))
    unsafe_load(Ptr{Ptr{Cvoid}}(ctx + fieldoffset(ibv_context, 2) + op_offset))
end

function get_ibv_context_op(cq::Ptr{ibv_cq}, op::Symbol)
    ctx = unsafe_load(Ptr{Ptr{ibv_context}}(cq))
    get_ibv_context_op(ctx, op)
end

export ibv_poll_cq

function ibv_poll_cq(cq, num_entries, wc)
    ccall(get_ibv_context_op(cq, :poll_cq), Cint, (Ptr{ibv_cq}, Cint, Ptr{ibv_wc}), cq, num_entries, wc)
end

export ibv_req_notify_cq

function ibv_req_notify_cq(cq, solicited_only)
    ccall(get_ibv_context_op(cq, :req_notify_cq), Cint, (Ptr{ibv_cq}, Cint), cq, solicited_only)
end

#= TODO
export ibv_modify_cq
function ibv_modify_cq(cq, attr)
    ccall((:ibv_modify_cq, libibverbs), Cint, (Ptr{ibv_cq}, Ptr{ibv_modify_cq_attr}), cq, attr)
end
=#
