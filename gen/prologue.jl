# ETH_ALEN 

const ETH_ALEN = 6

# ibv_gid

export ibv_gid

struct ibv_gid
    subnet_prefix::UInt64
    interface_id::UInt64
end
