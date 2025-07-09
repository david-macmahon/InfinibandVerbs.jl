const ETH_ALEN = 6

const __VERBS_ABI_IS_EXTENDED = C_NULL - 1

export ibv_gid
struct ibv_gid
    subnet_prefix::UInt64
    interface_id::UInt64
end
