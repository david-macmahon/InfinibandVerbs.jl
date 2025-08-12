export ibv_query_port
function ibv_query_port(context, port_num, port_attr)
    ccall((:ibv_query_port, libibverbs), Cint, (Ptr{ibv_context}, UInt8, Ptr{ibv_port_attr}), context, port_num, port_attr)
end

export ibv_reg_mr
function ibv_reg_mr(pd, addr, length, access)
    ccall((:ibv_reg_mr, libibverbs), Ptr{ibv_mr}, (Ptr{ibv_pd}, Ptr{Cvoid}, Csize_t, Cuint), pd, addr, length, access)
end

# Functions that are static inline in verbs.h have no implementation (and
# therefore no symbol for `dlsym` to find) in the shared library.

#=
## Clang 0.18
# Get ibv_context_ops struct from an Ptr{ibv_context}
function get_ibv_context_op(ctx::Ptr{ibv_context}, op::Symbol)
    op_offset = fieldoffset(ibv_context_ops, findfirst(==(op), fieldnames(ibv_context_ops)))
    unsafe_load(Ptr{Ptr{Cvoid}}(ctx + fieldoffset(ibv_context, 2) + op_offset))
end

# Get ibv_context_ops struct from an Ptr{ibv_cq} via the the ibv_context pointer
# in cq's first field.
function get_ibv_context_op(cq::Ptr{ibv_cq}, op::Symbol)
    ctx = unsafe_load(Ptr{Ptr{ibv_context}}(cq))
    get_ibv_context_op(ctx, op)
end
=#

## Clang 0.19
get_context_op(ctx::Ptr{ibv_context}, op::Symbol) = GC.@preserve ctx getproperty(unsafe_load(ctx.ops), op)
get_context_op(cq::Ptr{ibv_cq}, op::Symbol) = GC.@preserve cq get_context_op(unsafe_load(cq.context), op)
get_context_op(qp::Ptr{ibv_qp}, op::Symbol) = GC.@preserve qp get_context_op(unsafe_load(qp.context), op)

# NOT exported
function verbs_get_ctx(ctx::Ptr{ibv_context})::Ptr{verbs_context}
    if unsafe_load(ctx.abi_compat) != __VERBS_ABI_IS_EXTENDED
        return C_NULL
    end

    # This is a variation of the verbs.h code.  The verbs.h implementation
    # subtracts the offset of the ibv_context struct within the verbs_context
    # struct.  Because verbs_context and ibv_context are "synthetic" structs
    # (i.e. they just contain a single `NTuple{N,UInt8}` member) we can't use
    # fieldoffset() to determine this offset.  Instead we rely on the comment in
    # verbs.h that the ibv_context struct pointed to by `ctx` "must be" the last
    # field in the verbs_context structure.  This allows us to compute the
    # offset by subtracting sizeof(ibv_context) from sizeof(verbs_context).
    ctx - (sizeof(verbs_context) - sizeof(ibv_context))
end

# NOT exported
"""
    verbs_get_ctx_op(ctx::Ptr{ibv_context}, op::Symbol)::Ptr{verbs_context}

Return `Ptr{verbs_context}` if `ctx` is part of a `verbs_context` struct and the
verbs_context struct has a field for `op` and that field is non-NULL.
Otherwise, return Ptr{verbs_context}(C_NULL).
"""
function verbs_get_ctx_op(ctx::Ptr{ibv_context}, op::Symbol)::Ptr{verbs_context}
    vctx = verbs_get_ctx(ctx)
    vctx == C_NULL && return C_NULL # Not part of a verbs_context

    op_ptr = try
        getproperty(vctx, op)
    catch
        C_NULL
    end

    op_ptr == C_NULL && return C_NULL # Unknown op
    unsafe_load(op_ptr) == C_NULL && return C_NULL # Unsupported but known op
    return vctx # vctx with valid op property
end

export ibv_poll_cq
function ibv_poll_cq(cq, num_entries, wc)
    f = get_context_op(cq, :poll_cq)
    ccall(f, Cint, (Ptr{ibv_cq}, Cint, Ptr{ibv_wc}), cq, num_entries, wc)
end

export ibv_req_notify_cq
function ibv_req_notify_cq(cq, solicited_only)
    f = get_context_op(cq, :req_notify_cq)
    ccall(f, Cint, (Ptr{ibv_cq}, Cint), cq, solicited_only)
end

export ibv_post_recv
function ibv_post_recv(qp, wr, bad_wr)
    f = get_context_op(qp, :post_recv)
    ccall(f, Cint, (Ptr{ibv_qp}, Ptr{ibv_recv_wr}, Ptr{Ptr{ibv_recv_wr}}), qp, wr, bad_wr)
end

export ibv_create_flow
function ibv_create_flow(qp, flow)
    vctx = verbs_get_ctx_op(unsafe_load(qp.context), :ibv_create_flow)
    if vctx == C_NULL
        Libc.errno = Libc.EOPNOTSUPP
        return C_NULL
    end

    # verbs_get_ctx_op has validated everything so this unsafe_load is OK
    f = unsafe_load(vctx.ibv_create_flow)
    ccall(f, Ptr{ibv_flow}, (Ptr{ibv_qp}, Ptr{ibv_flow_attr}), qp, flow)
end

export ibv_destroy_flow
function ibv_destroy_flow(flow_id)
    vctx = verbs_get_ctx_op(unsafe_load(flow_id).context, :ibv_destroy_flow)
    vctx == C_NULL && return Libc.EOPNOTSUPP

    # verbs_get_ctx_op has validated everything so this unsafe_load is OK
    f = unsafe_load(vctx.ibv_destroy_flow)
    ccall(f, Cint, (Ptr{ibv_flow},), flow_id)
end

# Pseudo-kwarg constructors

function synthentic_constructor(::Type{T}; kwargs...)::T where T
    ref = Ref(reinterpret(T, ntuple(_->0x00, Base.packedsize(T))))
    GC.@preserve ref begin
        ptr = Base.unsafe_convert(Ptr{T}, ref)
        for (f,v) in kwargs
            setproperty!(ptr, f, v)
        end
    end
    ref[]
end

ibv_qp_attr(; kwargs...) = synthentic_constructor(ibv_qp_attr; kwargs...)
ibv_send_wr(; kwargs...) = synthentic_constructor(ibv_send_wr; kwargs...)

#= TODO
export ibv_modify_cq
function ibv_modify_cq(cq, attr)
    ccall((:ibv_modify_cq, libibverbs), Cint, (Ptr{ibv_cq}, Ptr{ibv_modify_cq_attr}), cq, attr)
end
=#

# Convenience getindex methods for ibv_send_wr/ibv_recv_wr/ibv_sge pointers

"""
    getindex(p::Ptr{T}, i)::Ptr{T} where {T<:Union{ibv_send_wr, ibv_recv_wr, ibv_sge}}

Returns a pointer to the `i`th element of a memory contiguous list of type `T`
pointed to by `p`.  This function does not de-reference any pointers (i.e it is
not "unsafe").
"""
function Base.getindex(p::Ptr{T}, i)::Ptr{T} where {T<:Union{ibv_send_wr, ibv_recv_wr, ibv_sge}}
    p + (i-1)*sizeof(T)
end

"""
    getindex(p::Ptr{Ptr{T}}, i)::Ptr{T} where {T<:Union{ibv_send_wr, ibv_recv_wr, ibv_sge}}

Returns a pointer to the `i`th element of a memory contiguous list of type `T`
pointed to by `unsafe_load(p)`.  Because this function performs an `unsafe_load`
of `p` it should be considered "unsafe" in the same sense as `unsafe_load`.
"""
function Base.getindex(p::Ptr{Ptr{T}}, i)::Ptr{T} where {T<:Union{ibv_send_wr, ibv_recv_wr, ibv_sge}}
    getindex(unsafe_load(p), i)
end

"""
    getindex(p::Ptr{T})::T where {T<:Union{ibv_send_wr, ibv_recv_wr, ibv_sge}}

Performs an `unsafe_load` on `p` for the supported types: `ibv_send_wr`,
`ibv_recv_wr`, `ibv_sge`.  Because this function performs an `unsafe_load` of
`p` it should be considered "unsafe" in the same sense as `unsafe_load`.
"""
function Base.getindex(p::Ptr{T})::T where {T<:Union{ibv_send_wr, ibv_recv_wr, ibv_sge}}
    unsafe_load(p)
end

"""
    getindex(p::Ptr{Ptr{T}})::Ptr{T} where {T<:Union{ibv_send_wr, ibv_recv_wr, ibv_sge}}

Performs an `unsafe_load` on `p` for the supported types: `ibv_send_wr`,
`ibv_recv_wr`, `ibv_sge`.  Equivalent to `getindex(p, 1)`.  Because this
function performs an `unsafe_load` of `p` it should be considered "unsafe" in
the same sense as `unsafe_load`.
"""
function Base.getindex(p::Ptr{Ptr{T}})::Ptr{T} where {T<:Union{ibv_send_wr, ibv_recv_wr, ibv_sge}}
    unsafe_load(p)
end

function Base.show(io::IO, wr::T) where T<:Union{ibv_send_wr,ibv_recv_wr}
    compact = get(io, :compact, false)
    print(io, nameof(T), "(", wr.wr_id, ", next->")
    print(io, wr.next == C_NULL ? "∅" : wr.next[].wr_id)
    if !compact
        print(io, ", [")
        if wr.sg_list != C_NULL
            for i = 1:wr.num_sge
                print(io, wr.sg_list[i][].length, "@0x")
                print(io, string(wr.sg_list[i][].addr, base=16))
                print(io, i==wr.num_sge ? "" : ",")
            end
        end
        print(io, "]")
    end
    print(io, ")")
end
