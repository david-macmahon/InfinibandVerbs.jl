module API

using rdma_core_jll
export rdma_core_jll

using CEnum

# ETH_ALEN 

const ETH_ALEN = 6

# ibv_gid

export ibv_gid

struct ibv_gid
    subnet_prefix::UInt64
    interface_id::UInt64
end


const __time_t = Clong

struct timespec
    tv_sec::__time_t
    tv_nsec::Clong
end

struct __pthread_internal_list
    __prev::Ptr{__pthread_internal_list}
    __next::Ptr{__pthread_internal_list}
end

const __pthread_list_t = __pthread_internal_list

struct pthread_mutex_t
    data::NTuple{40, UInt8}
end

function Base.getproperty(x::Ptr{pthread_mutex_t}, f::Symbol)
    f === :__data && return Ptr{__pthread_mutex_s}(x + 0)
    f === :__size && return Ptr{NTuple{40, Cchar}}(x + 0)
    f === :__align && return Ptr{Clong}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::pthread_mutex_t, f::Symbol)
    r = Ref{pthread_mutex_t}(x)
    ptr = Base.unsafe_convert(Ptr{pthread_mutex_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{pthread_mutex_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct pthread_cond_t
    data::NTuple{48, UInt8}
end

function Base.getproperty(x::Ptr{pthread_cond_t}, f::Symbol)
    f === :__data && return Ptr{var"struct (unnamed at /home/davidm/.julia/artifacts/305c8b171016c46dfbb8ca234a543a99b6e3d045/x86_64-linux-gnu/sys-root/usr/include/bits/pthreadtypes.h:117:3)"}(x + 0)
    f === :__size && return Ptr{NTuple{48, Cchar}}(x + 0)
    f === :__align && return Ptr{Clonglong}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::pthread_cond_t, f::Symbol)
    r = Ref{pthread_cond_t}(x)
    ptr = Base.unsafe_convert(Ptr{pthread_cond_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{pthread_cond_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const __u8 = Cuchar

const __u16 = Cushort

const __u32 = Cuint

const __u64 = Culonglong

const __be16 = __u16

const __be32 = __u32

const __be64 = __u64

struct ib_uverbs_query_port_resp
    port_cap_flags::__u32
    max_msg_sz::__u32
    bad_pkey_cntr::__u32
    qkey_viol_cntr::__u32
    gid_tbl_len::__u32
    pkey_tbl_len::__u16
    lid::__u16
    sm_lid::__u16
    state::__u8
    max_mtu::__u8
    active_mtu::__u8
    lmc::__u8
    max_vl_num::__u8
    sm_sl::__u8
    subnet_timeout::__u8
    init_type_reply::__u8
    active_width::__u8
    active_speed::__u8
    phys_state::__u8
    link_layer::__u8
    flags::__u8
    reserved::__u8
end

struct _ibv_device_ops
    _dummy1::Ptr{Cvoid}
    _dummy2::Ptr{Cvoid}
end

@cenum ibv_node_type::Int32 begin
    IBV_NODE_UNKNOWN = -1
    IBV_NODE_CA = 1
    IBV_NODE_SWITCH = 2
    IBV_NODE_ROUTER = 3
    IBV_NODE_RNIC = 4
    IBV_NODE_USNIC = 5
    IBV_NODE_USNIC_UDP = 6
    IBV_NODE_UNSPECIFIED = 7
end

@cenum ibv_transport_type::Int32 begin
    IBV_TRANSPORT_UNKNOWN = -1
    IBV_TRANSPORT_IB = 0
    IBV_TRANSPORT_IWARP = 1
    IBV_TRANSPORT_USNIC = 2
    IBV_TRANSPORT_USNIC_UDP = 3
    IBV_TRANSPORT_UNSPECIFIED = 4
end

struct ibv_device
    _ops::_ibv_device_ops
    node_type::ibv_node_type
    transport_type::ibv_transport_type
    name::NTuple{64, Cchar}
    dev_name::NTuple{64, Cchar}
    dev_path::NTuple{256, Cchar}
    ibdev_path::NTuple{256, Cchar}
end

struct ibv_context_ops
    _compat_query_device::Ptr{Cvoid}
    _compat_query_port::Ptr{Cvoid}
    _compat_alloc_pd::Ptr{Cvoid}
    _compat_dealloc_pd::Ptr{Cvoid}
    _compat_reg_mr::Ptr{Cvoid}
    _compat_rereg_mr::Ptr{Cvoid}
    _compat_dereg_mr::Ptr{Cvoid}
    alloc_mw::Ptr{Cvoid}
    bind_mw::Ptr{Cvoid}
    dealloc_mw::Ptr{Cvoid}
    _compat_create_cq::Ptr{Cvoid}
    poll_cq::Ptr{Cvoid}
    req_notify_cq::Ptr{Cvoid}
    _compat_cq_event::Ptr{Cvoid}
    _compat_resize_cq::Ptr{Cvoid}
    _compat_destroy_cq::Ptr{Cvoid}
    _compat_create_srq::Ptr{Cvoid}
    _compat_modify_srq::Ptr{Cvoid}
    _compat_query_srq::Ptr{Cvoid}
    _compat_destroy_srq::Ptr{Cvoid}
    post_srq_recv::Ptr{Cvoid}
    _compat_create_qp::Ptr{Cvoid}
    _compat_query_qp::Ptr{Cvoid}
    _compat_modify_qp::Ptr{Cvoid}
    _compat_destroy_qp::Ptr{Cvoid}
    post_send::Ptr{Cvoid}
    post_recv::Ptr{Cvoid}
    _compat_create_ah::Ptr{Cvoid}
    _compat_destroy_ah::Ptr{Cvoid}
    _compat_attach_mcast::Ptr{Cvoid}
    _compat_detach_mcast::Ptr{Cvoid}
    _compat_async_event::Ptr{Cvoid}
end

struct ibv_context
    device::Ptr{ibv_device}
    ops::ibv_context_ops
    cmd_fd::Cint
    async_fd::Cint
    num_comp_vectors::Cint
    mutex::pthread_mutex_t
    abi_compat::Ptr{Cvoid}
end

mutable struct verbs_ex_private end

struct verbs_context
    query_port::Ptr{Cvoid}
    advise_mr::Ptr{Cvoid}
    alloc_null_mr::Ptr{Cvoid}
    read_counters::Ptr{Cvoid}
    attach_counters_point_flow::Ptr{Cvoid}
    create_counters::Ptr{Cvoid}
    destroy_counters::Ptr{Cvoid}
    reg_dm_mr::Ptr{Cvoid}
    alloc_dm::Ptr{Cvoid}
    free_dm::Ptr{Cvoid}
    modify_flow_action_esp::Ptr{Cvoid}
    destroy_flow_action::Ptr{Cvoid}
    create_flow_action_esp::Ptr{Cvoid}
    modify_qp_rate_limit::Ptr{Cvoid}
    alloc_parent_domain::Ptr{Cvoid}
    dealloc_td::Ptr{Cvoid}
    alloc_td::Ptr{Cvoid}
    modify_cq::Ptr{Cvoid}
    post_srq_ops::Ptr{Cvoid}
    destroy_rwq_ind_table::Ptr{Cvoid}
    create_rwq_ind_table::Ptr{Cvoid}
    destroy_wq::Ptr{Cvoid}
    modify_wq::Ptr{Cvoid}
    create_wq::Ptr{Cvoid}
    query_rt_values::Ptr{Cvoid}
    create_cq_ex::Ptr{Cvoid}
    priv::Ptr{verbs_ex_private}
    query_device_ex::Ptr{Cvoid}
    ibv_destroy_flow::Ptr{Cvoid}
    ABI_placeholder2::Ptr{Cvoid}
    ibv_create_flow::Ptr{Cvoid}
    ABI_placeholder1::Ptr{Cvoid}
    open_qp::Ptr{Cvoid}
    create_qp_ex::Ptr{Cvoid}
    get_srq_num::Ptr{Cvoid}
    create_srq_ex::Ptr{Cvoid}
    open_xrcd::Ptr{Cvoid}
    close_xrcd::Ptr{Cvoid}
    _ABI_placeholder3::UInt64
    sz::Csize_t
    context::ibv_context
end

function verbs_get_ctx(ctx)
    ccall((:verbs_get_ctx, libibverbs), Ptr{verbs_context}, (Ptr{ibv_context},), ctx)
end

@cenum ibv_port_state::UInt32 begin
    IBV_PORT_NOP = 0
    IBV_PORT_DOWN = 1
    IBV_PORT_INIT = 2
    IBV_PORT_ARMED = 3
    IBV_PORT_ACTIVE = 4
    IBV_PORT_ACTIVE_DEFER = 5
end

@cenum ibv_mtu::UInt32 begin
    IBV_MTU_256 = 1
    IBV_MTU_512 = 2
    IBV_MTU_1024 = 3
    IBV_MTU_2048 = 4
    IBV_MTU_4096 = 5
end

struct ibv_port_attr
    state::ibv_port_state
    max_mtu::ibv_mtu
    active_mtu::ibv_mtu
    gid_tbl_len::Cint
    port_cap_flags::UInt32
    max_msg_sz::UInt32
    bad_pkey_cntr::UInt32
    qkey_viol_cntr::UInt32
    pkey_tbl_len::UInt16
    lid::UInt16
    sm_lid::UInt16
    lmc::UInt8
    max_vl_num::UInt8
    sm_sl::UInt8
    subnet_timeout::UInt8
    init_type_reply::UInt8
    active_width::UInt8
    active_speed::UInt8
    phys_state::UInt8
    link_layer::UInt8
    flags::UInt8
    port_cap_flags2::UInt16
    active_speed_ex::UInt32
end

struct ibv_pd
    context::Ptr{ibv_context}
    handle::UInt32
end

struct ibv_mr
    context::Ptr{ibv_context}
    pd::Ptr{ibv_pd}
    addr::Ptr{Cvoid}
    length::Csize_t
    handle::UInt32
    lkey::UInt32
    rkey::UInt32
end

function __ibv_reg_mr(pd, addr, length, access, is_access_const)
    ccall((:__ibv_reg_mr, libibverbs), Ptr{ibv_mr}, (Ptr{ibv_pd}, Ptr{Cvoid}, Csize_t, Cuint, Cint), pd, addr, length, access, is_access_const)
end

function __ibv_reg_mr_iova(pd, addr, length, iova, access, is_access_const)
    ccall((:__ibv_reg_mr_iova, libibverbs), Ptr{ibv_mr}, (Ptr{ibv_pd}, Ptr{Cvoid}, Csize_t, UInt64, Cuint, Cint), pd, addr, length, iova, access, is_access_const)
end

@cenum ib_uverbs_core_support::UInt32 begin
    IB_UVERBS_CORE_SUPPORT_OPTIONAL_MR_ACCESS = 1
end

@cenum ib_uverbs_access_flags::UInt32 begin
    IB_UVERBS_ACCESS_LOCAL_WRITE = 1
    IB_UVERBS_ACCESS_REMOTE_WRITE = 2
    IB_UVERBS_ACCESS_REMOTE_READ = 4
    IB_UVERBS_ACCESS_REMOTE_ATOMIC = 8
    IB_UVERBS_ACCESS_MW_BIND = 16
    IB_UVERBS_ACCESS_ZERO_BASED = 32
    IB_UVERBS_ACCESS_ON_DEMAND = 64
    IB_UVERBS_ACCESS_HUGETLB = 128
    IB_UVERBS_ACCESS_FLUSH_GLOBAL = 256
    IB_UVERBS_ACCESS_FLUSH_PERSISTENT = 512
    IB_UVERBS_ACCESS_RELAXED_ORDERING = 1048576
    IB_UVERBS_ACCESS_OPTIONAL_RANGE = 1072693248
end

@cenum ib_uverbs_srq_type::UInt32 begin
    IB_UVERBS_SRQT_BASIC = 0
    IB_UVERBS_SRQT_XRC = 1
    IB_UVERBS_SRQT_TM = 2
end

@cenum ib_uverbs_wq_type::UInt32 begin
    IB_UVERBS_WQT_RQ = 0
end

@cenum ib_uverbs_wq_flags::UInt32 begin
    IB_UVERBS_WQ_FLAGS_CVLAN_STRIPPING = 1
    IB_UVERBS_WQ_FLAGS_SCATTER_FCS = 2
    IB_UVERBS_WQ_FLAGS_DELAY_DROP = 4
    IB_UVERBS_WQ_FLAGS_PCI_WRITE_END_PADDING = 8
end

@cenum ib_uverbs_qp_type::UInt32 begin
    IB_UVERBS_QPT_RC = 2
    IB_UVERBS_QPT_UC = 3
    IB_UVERBS_QPT_UD = 4
    IB_UVERBS_QPT_RAW_PACKET = 8
    IB_UVERBS_QPT_XRC_INI = 9
    IB_UVERBS_QPT_XRC_TGT = 10
    IB_UVERBS_QPT_DRIVER = 255
end

@cenum ib_uverbs_qp_create_flags::UInt32 begin
    IB_UVERBS_QP_CREATE_BLOCK_MULTICAST_LOOPBACK = 2
    IB_UVERBS_QP_CREATE_SCATTER_FCS = 256
    IB_UVERBS_QP_CREATE_CVLAN_STRIPPING = 512
    IB_UVERBS_QP_CREATE_PCI_WRITE_END_PADDING = 2048
    IB_UVERBS_QP_CREATE_SQ_SIG_ALL = 4096
end

@cenum ib_uverbs_query_port_cap_flags::UInt32 begin
    IB_UVERBS_PCF_SM = 2
    IB_UVERBS_PCF_NOTICE_SUP = 4
    IB_UVERBS_PCF_TRAP_SUP = 8
    IB_UVERBS_PCF_OPT_IPD_SUP = 16
    IB_UVERBS_PCF_AUTO_MIGR_SUP = 32
    IB_UVERBS_PCF_SL_MAP_SUP = 64
    IB_UVERBS_PCF_MKEY_NVRAM = 128
    IB_UVERBS_PCF_PKEY_NVRAM = 256
    IB_UVERBS_PCF_LED_INFO_SUP = 512
    IB_UVERBS_PCF_SM_DISABLED = 1024
    IB_UVERBS_PCF_SYS_IMAGE_GUID_SUP = 2048
    IB_UVERBS_PCF_PKEY_SW_EXT_PORT_TRAP_SUP = 4096
    IB_UVERBS_PCF_EXTENDED_SPEEDS_SUP = 16384
    IB_UVERBS_PCF_CM_SUP = 65536
    IB_UVERBS_PCF_SNMP_TUNNEL_SUP = 131072
    IB_UVERBS_PCF_REINIT_SUP = 262144
    IB_UVERBS_PCF_DEVICE_MGMT_SUP = 524288
    IB_UVERBS_PCF_VENDOR_CLASS_SUP = 1048576
    IB_UVERBS_PCF_DR_NOTICE_SUP = 2097152
    IB_UVERBS_PCF_CAP_MASK_NOTICE_SUP = 4194304
    IB_UVERBS_PCF_BOOT_MGMT_SUP = 8388608
    IB_UVERBS_PCF_LINK_LATENCY_SUP = 16777216
    IB_UVERBS_PCF_CLIENT_REG_SUP = 33554432
    IB_UVERBS_PCF_LINK_SPEED_WIDTH_TABLE_SUP = 134217728
    IB_UVERBS_PCF_VENDOR_SPECIFIC_MADS_TABLE_SUP = 268435456
    IB_UVERBS_PCF_MCAST_PKEY_TRAP_SUPPRESSION_SUP = 536870912
    IB_UVERBS_PCF_MCAST_FDB_TOP_SUP = 1073741824
    IB_UVERBS_PCF_HIERARCHY_INFO_SUP = 0x0000000080000000
    IB_UVERBS_PCF_IP_BASED_GIDS = 67108864
end

@cenum ib_uverbs_query_port_flags::UInt32 begin
    IB_UVERBS_QPF_GRH_REQUIRED = 1
end

@cenum ib_uverbs_flow_action_esp_keymat::UInt32 begin
    IB_UVERBS_FLOW_ACTION_ESP_KEYMAT_AES_GCM = 0
end

@cenum ib_uverbs_flow_action_esp_keymat_aes_gcm_iv_algo::UInt32 begin
    IB_UVERBS_FLOW_ACTION_IV_ALGO_SEQ = 0
end

struct ib_uverbs_flow_action_esp_keymat_aes_gcm
    data::NTuple{56, UInt8}
end

function Base.getproperty(x::Ptr{ib_uverbs_flow_action_esp_keymat_aes_gcm}, f::Symbol)
    f === :iv && return Ptr{__u64}(x + 0)
    f === :iv_algo && return Ptr{__u32}(x + 8)
    f === :salt && return Ptr{__u32}(x + 12)
    f === :icv_len && return Ptr{__u32}(x + 16)
    f === :key_len && return Ptr{__u32}(x + 20)
    f === :aes_key && return Ptr{NTuple{8, __u32}}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::ib_uverbs_flow_action_esp_keymat_aes_gcm, f::Symbol)
    r = Ref{ib_uverbs_flow_action_esp_keymat_aes_gcm}(x)
    ptr = Base.unsafe_convert(Ptr{ib_uverbs_flow_action_esp_keymat_aes_gcm}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{ib_uverbs_flow_action_esp_keymat_aes_gcm}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum ib_uverbs_flow_action_esp_replay::UInt32 begin
    IB_UVERBS_FLOW_ACTION_ESP_REPLAY_NONE = 0
    IB_UVERBS_FLOW_ACTION_ESP_REPLAY_BMP = 1
end

struct ib_uverbs_flow_action_esp_replay_bmp
    size::__u32
end

@cenum ib_uverbs_flow_action_esp_flags::UInt32 begin
    IB_UVERBS_FLOW_ACTION_ESP_FLAGS_INLINE_CRYPTO = 0
    IB_UVERBS_FLOW_ACTION_ESP_FLAGS_FULL_OFFLOAD = 1
    IB_UVERBS_FLOW_ACTION_ESP_FLAGS_TUNNEL = 0
    IB_UVERBS_FLOW_ACTION_ESP_FLAGS_TRANSPORT = 2
    IB_UVERBS_FLOW_ACTION_ESP_FLAGS_DECRYPT = 0
    IB_UVERBS_FLOW_ACTION_ESP_FLAGS_ENCRYPT = 4
    IB_UVERBS_FLOW_ACTION_ESP_FLAGS_ESN_NEW_WINDOW = 8
end

struct ib_uverbs_flow_action_esp_encap
    data::NTuple{24, UInt8}
end

function Base.getproperty(x::Ptr{ib_uverbs_flow_action_esp_encap}, f::Symbol)
    f === :val_ptr && return Ptr{Ptr{Cvoid}}(x + 0)
    f === :val_ptr_data_u64 && return Ptr{__u64}(x + 0)
    f === :next_ptr && return Ptr{Ptr{ib_uverbs_flow_action_esp_encap}}(x + 8)
    f === :next_ptr_data_u64 && return Ptr{__u64}(x + 8)
    f === :len && return Ptr{__u16}(x + 16)
    f === :type && return Ptr{__u16}(x + 18)
    return getfield(x, f)
end

function Base.getproperty(x::ib_uverbs_flow_action_esp_encap, f::Symbol)
    r = Ref{ib_uverbs_flow_action_esp_encap}(x)
    ptr = Base.unsafe_convert(Ptr{ib_uverbs_flow_action_esp_encap}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{ib_uverbs_flow_action_esp_encap}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct ib_uverbs_flow_action_esp
    data::NTuple{24, UInt8}
end

function Base.getproperty(x::Ptr{ib_uverbs_flow_action_esp}, f::Symbol)
    f === :spi && return Ptr{__u32}(x + 0)
    f === :seq && return Ptr{__u32}(x + 4)
    f === :tfc_pad && return Ptr{__u32}(x + 8)
    f === :flags && return Ptr{__u32}(x + 12)
    f === :hard_limit_pkts && return Ptr{__u64}(x + 16)
    return getfield(x, f)
end

function Base.getproperty(x::ib_uverbs_flow_action_esp, f::Symbol)
    r = Ref{ib_uverbs_flow_action_esp}(x)
    ptr = Base.unsafe_convert(Ptr{ib_uverbs_flow_action_esp}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{ib_uverbs_flow_action_esp}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum ib_uverbs_read_counters_flags::UInt32 begin
    IB_UVERBS_READ_COUNTERS_PREFER_CACHED = 1
end

@cenum ib_uverbs_advise_mr_advice::UInt32 begin
    IB_UVERBS_ADVISE_MR_ADVICE_PREFETCH = 0
    IB_UVERBS_ADVISE_MR_ADVICE_PREFETCH_WRITE = 1
    IB_UVERBS_ADVISE_MR_ADVICE_PREFETCH_NO_FAULT = 2
end

@cenum ib_uverbs_advise_mr_flag::UInt32 begin
    IB_UVERBS_ADVISE_MR_FLAG_FLUSH = 1
end

struct ib_uverbs_query_port_resp_ex
    legacy_resp::ib_uverbs_query_port_resp
    port_cap_flags2::__u16
    reserved::NTuple{2, __u8}
    active_speed_ex::__u32
end

struct ib_uverbs_qp_cap
    max_send_wr::__u32
    max_recv_wr::__u32
    max_send_sge::__u32
    max_recv_sge::__u32
    max_inline_data::__u32
end

@cenum rdma_driver_id::UInt32 begin
    RDMA_DRIVER_UNKNOWN = 0
    RDMA_DRIVER_MLX5 = 1
    RDMA_DRIVER_MLX4 = 2
    RDMA_DRIVER_CXGB3 = 3
    RDMA_DRIVER_CXGB4 = 4
    RDMA_DRIVER_MTHCA = 5
    RDMA_DRIVER_BNXT_RE = 6
    RDMA_DRIVER_OCRDMA = 7
    RDMA_DRIVER_NES = 8
    RDMA_DRIVER_I40IW = 9
    RDMA_DRIVER_IRDMA = 9
    RDMA_DRIVER_VMW_PVRDMA = 10
    RDMA_DRIVER_QEDR = 11
    RDMA_DRIVER_HNS = 12
    RDMA_DRIVER_USNIC = 13
    RDMA_DRIVER_RXE = 14
    RDMA_DRIVER_HFI1 = 15
    RDMA_DRIVER_QIB = 16
    RDMA_DRIVER_EFA = 17
    RDMA_DRIVER_SIW = 18
    RDMA_DRIVER_ERDMA = 19
    RDMA_DRIVER_MANA = 20
end

@cenum ib_uverbs_gid_type::UInt32 begin
    IB_UVERBS_GID_TYPE_IB = 0
    IB_UVERBS_GID_TYPE_ROCE_V1 = 1
    IB_UVERBS_GID_TYPE_ROCE_V2 = 2
end

struct ib_uverbs_gid_entry
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{ib_uverbs_gid_entry}, f::Symbol)
    f === :gid && return Ptr{NTuple{2, __u64}}(x + 0)
    f === :gid_index && return Ptr{__u32}(x + 16)
    f === :port_num && return Ptr{__u32}(x + 20)
    f === :gid_type && return Ptr{__u32}(x + 24)
    f === :netdev_ifindex && return Ptr{__u32}(x + 28)
    return getfield(x, f)
end

function Base.getproperty(x::ib_uverbs_gid_entry, f::Symbol)
    r = Ref{ib_uverbs_gid_entry}(x)
    ptr = Base.unsafe_convert(Ptr{ib_uverbs_gid_entry}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{ib_uverbs_gid_entry}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum ibv_gid_type::UInt32 begin
    IBV_GID_TYPE_IB = 0
    IBV_GID_TYPE_ROCE_V1 = 1
    IBV_GID_TYPE_ROCE_V2 = 2
end

struct ibv_gid_entry
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{ibv_gid_entry}, f::Symbol)
    f === :gid && return Ptr{ibv_gid}(x + 0)
    f === :gid_index && return Ptr{UInt32}(x + 16)
    f === :port_num && return Ptr{UInt32}(x + 20)
    f === :gid_type && return Ptr{UInt32}(x + 24)
    f === :ndev_ifindex && return Ptr{UInt32}(x + 28)
    return getfield(x, f)
end

function Base.getproperty(x::ibv_gid_entry, f::Symbol)
    r = Ref{ibv_gid_entry}(x)
    ptr = Base.unsafe_convert(Ptr{ibv_gid_entry}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{ibv_gid_entry}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum ibv_device_cap_flags::UInt32 begin
    IBV_DEVICE_RESIZE_MAX_WR = 1
    IBV_DEVICE_BAD_PKEY_CNTR = 2
    IBV_DEVICE_BAD_QKEY_CNTR = 4
    IBV_DEVICE_RAW_MULTI = 8
    IBV_DEVICE_AUTO_PATH_MIG = 16
    IBV_DEVICE_CHANGE_PHY_PORT = 32
    IBV_DEVICE_UD_AV_PORT_ENFORCE = 64
    IBV_DEVICE_CURR_QP_STATE_MOD = 128
    IBV_DEVICE_SHUTDOWN_PORT = 256
    IBV_DEVICE_INIT_TYPE = 512
    IBV_DEVICE_PORT_ACTIVE_EVENT = 1024
    IBV_DEVICE_SYS_IMAGE_GUID = 2048
    IBV_DEVICE_RC_RNR_NAK_GEN = 4096
    IBV_DEVICE_SRQ_RESIZE = 8192
    IBV_DEVICE_N_NOTIFY_CQ = 16384
    IBV_DEVICE_MEM_WINDOW = 131072
    IBV_DEVICE_UD_IP_CSUM = 262144
    IBV_DEVICE_XRC = 1048576
    IBV_DEVICE_MEM_MGT_EXTENSIONS = 2097152
    IBV_DEVICE_MEM_WINDOW_TYPE_2A = 8388608
    IBV_DEVICE_MEM_WINDOW_TYPE_2B = 16777216
    IBV_DEVICE_RC_IP_CSUM = 33554432
    IBV_DEVICE_RAW_IP_CSUM = 67108864
    IBV_DEVICE_MANAGED_FLOW_STEERING = 536870912
end

@cenum ibv_fork_status::UInt32 begin
    IBV_FORK_DISABLED = 0
    IBV_FORK_ENABLED = 1
    IBV_FORK_UNNEEDED = 2
end

@cenum ibv_atomic_cap::UInt32 begin
    IBV_ATOMIC_NONE = 0
    IBV_ATOMIC_HCA = 1
    IBV_ATOMIC_GLOB = 2
end

struct ibv_alloc_dm_attr
    length::Csize_t
    log_align_req::UInt32
    comp_mask::UInt32
end

@cenum ibv_dm_mask::UInt32 begin
    IBV_DM_MASK_HANDLE = 1
end

struct ibv_dm
    context::Ptr{ibv_context}
    memcpy_to_dm::Ptr{Cvoid}
    memcpy_from_dm::Ptr{Cvoid}
    comp_mask::UInt32
    handle::UInt32
end

struct ibv_device_attr
    fw_ver::NTuple{64, Cchar}
    node_guid::__be64
    sys_image_guid::__be64
    max_mr_size::UInt64
    page_size_cap::UInt64
    vendor_id::UInt32
    vendor_part_id::UInt32
    hw_ver::UInt32
    max_qp::Cint
    max_qp_wr::Cint
    device_cap_flags::Cuint
    max_sge::Cint
    max_sge_rd::Cint
    max_cq::Cint
    max_cqe::Cint
    max_mr::Cint
    max_pd::Cint
    max_qp_rd_atom::Cint
    max_ee_rd_atom::Cint
    max_res_rd_atom::Cint
    max_qp_init_rd_atom::Cint
    max_ee_init_rd_atom::Cint
    atomic_cap::ibv_atomic_cap
    max_ee::Cint
    max_rdd::Cint
    max_mw::Cint
    max_raw_ipv6_qp::Cint
    max_raw_ethy_qp::Cint
    max_mcast_grp::Cint
    max_mcast_qp_attach::Cint
    max_total_mcast_qp_attach::Cint
    max_ah::Cint
    max_fmr::Cint
    max_map_per_fmr::Cint
    max_srq::Cint
    max_srq_wr::Cint
    max_srq_sge::Cint
    max_pkeys::UInt16
    local_ca_ack_delay::UInt8
    phys_port_cnt::UInt8
end

struct ibv_query_device_ex_input
    comp_mask::UInt32
end

@cenum ibv_odp_general_caps::UInt32 begin
    IBV_ODP_SUPPORT = 1
    IBV_ODP_SUPPORT_IMPLICIT = 2
end

@cenum ibv_odp_transport_cap_bits::UInt32 begin
    IBV_ODP_SUPPORT_SEND = 1
    IBV_ODP_SUPPORT_RECV = 2
    IBV_ODP_SUPPORT_WRITE = 4
    IBV_ODP_SUPPORT_READ = 8
    IBV_ODP_SUPPORT_ATOMIC = 16
    IBV_ODP_SUPPORT_SRQ_RECV = 32
    IBV_ODP_SUPPORT_FLUSH = 64
    IBV_ODP_SUPPORT_ATOMIC_WRITE = 128
end

struct var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:249:2)"
    rc_odp_caps::UInt32
    uc_odp_caps::UInt32
    ud_odp_caps::UInt32
end

struct ibv_odp_caps
    data::NTuple{24, UInt8}
end

function Base.getproperty(x::Ptr{ibv_odp_caps}, f::Symbol)
    f === :general_caps && return Ptr{UInt64}(x + 0)
    f === :per_transport_caps && return Ptr{var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:249:2)"}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::ibv_odp_caps, f::Symbol)
    r = Ref{ibv_odp_caps}(x)
    ptr = Base.unsafe_convert(Ptr{ibv_odp_caps}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{ibv_odp_caps}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct ibv_tso_caps
    max_tso::UInt32
    supported_qpts::UInt32
end

@cenum ibv_rx_hash_function_flags::UInt32 begin
    IBV_RX_HASH_FUNC_TOEPLITZ = 1
end

@cenum ibv_rx_hash_fields::UInt32 begin
    IBV_RX_HASH_SRC_IPV4 = 1
    IBV_RX_HASH_DST_IPV4 = 2
    IBV_RX_HASH_SRC_IPV6 = 4
    IBV_RX_HASH_DST_IPV6 = 8
    IBV_RX_HASH_SRC_PORT_TCP = 16
    IBV_RX_HASH_DST_PORT_TCP = 32
    IBV_RX_HASH_SRC_PORT_UDP = 64
    IBV_RX_HASH_DST_PORT_UDP = 128
    IBV_RX_HASH_IPSEC_SPI = 256
    IBV_RX_HASH_INNER = 0x0000000080000000
end

struct ibv_rss_caps
    supported_qpts::UInt32
    max_rwq_indirection_tables::UInt32
    max_rwq_indirection_table_size::UInt32
    rx_hash_fields_mask::UInt64
    rx_hash_function::UInt8
end

struct ibv_packet_pacing_caps
    qp_rate_limit_min::UInt32
    qp_rate_limit_max::UInt32
    supported_qpts::UInt32
end

@cenum ibv_raw_packet_caps::UInt32 begin
    IBV_RAW_PACKET_CAP_CVLAN_STRIPPING = 1
    IBV_RAW_PACKET_CAP_SCATTER_FCS = 2
    IBV_RAW_PACKET_CAP_IP_CSUM = 4
    IBV_RAW_PACKET_CAP_DELAY_DROP = 8
end

@cenum ibv_tm_cap_flags::UInt32 begin
    IBV_TM_CAP_RC = 1
end

struct ibv_tm_caps
    max_rndv_hdr_size::UInt32
    max_num_tags::UInt32
    flags::UInt32
    max_ops::UInt32
    max_sge::UInt32
end

struct ibv_cq_moderation_caps
    max_cq_count::UInt16
    max_cq_period::UInt16
end

@cenum ibv_pci_atomic_op_size::UInt32 begin
    IBV_PCI_ATOMIC_OPERATION_4_BYTE_SIZE_SUP = 1
    IBV_PCI_ATOMIC_OPERATION_8_BYTE_SIZE_SUP = 2
    IBV_PCI_ATOMIC_OPERATION_16_BYTE_SIZE_SUP = 4
end

struct ibv_pci_atomic_caps
    fetch_add::UInt16
    swap::UInt16
    compare_swap::UInt16
end

struct ibv_device_attr_ex
    data::NTuple{400, UInt8}
end

function Base.getproperty(x::Ptr{ibv_device_attr_ex}, f::Symbol)
    f === :orig_attr && return Ptr{ibv_device_attr}(x + 0)
    f === :comp_mask && return Ptr{UInt32}(x + 232)
    f === :odp_caps && return Ptr{ibv_odp_caps}(x + 240)
    f === :completion_timestamp_mask && return Ptr{UInt64}(x + 264)
    f === :hca_core_clock && return Ptr{UInt64}(x + 272)
    f === :device_cap_flags_ex && return Ptr{UInt64}(x + 280)
    f === :tso_caps && return Ptr{ibv_tso_caps}(x + 288)
    f === :rss_caps && return Ptr{ibv_rss_caps}(x + 296)
    f === :max_wq_type_rq && return Ptr{UInt32}(x + 328)
    f === :packet_pacing_caps && return Ptr{ibv_packet_pacing_caps}(x + 332)
    f === :raw_packet_caps && return Ptr{UInt32}(x + 344)
    f === :tm_caps && return Ptr{ibv_tm_caps}(x + 348)
    f === :cq_mod_caps && return Ptr{ibv_cq_moderation_caps}(x + 368)
    f === :max_dm_size && return Ptr{UInt64}(x + 376)
    f === :pci_atomic_caps && return Ptr{ibv_pci_atomic_caps}(x + 384)
    f === :xrc_odp_caps && return Ptr{UInt32}(x + 392)
    f === :phys_port_cnt_ex && return Ptr{UInt32}(x + 396)
    return getfield(x, f)
end

function Base.getproperty(x::ibv_device_attr_ex, f::Symbol)
    r = Ref{ibv_device_attr_ex}(x)
    ptr = Base.unsafe_convert(Ptr{ibv_device_attr_ex}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{ibv_device_attr_ex}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum var"##Ctag#244"::UInt32 begin
    IBV_LINK_LAYER_UNSPECIFIED = 0
    IBV_LINK_LAYER_INFINIBAND = 1
    IBV_LINK_LAYER_ETHERNET = 2
end

@cenum ibv_port_cap_flags::UInt32 begin
    IBV_PORT_SM = 2
    IBV_PORT_NOTICE_SUP = 4
    IBV_PORT_TRAP_SUP = 8
    IBV_PORT_OPT_IPD_SUP = 16
    IBV_PORT_AUTO_MIGR_SUP = 32
    IBV_PORT_SL_MAP_SUP = 64
    IBV_PORT_MKEY_NVRAM = 128
    IBV_PORT_PKEY_NVRAM = 256
    IBV_PORT_LED_INFO_SUP = 512
    IBV_PORT_SYS_IMAGE_GUID_SUP = 2048
    IBV_PORT_PKEY_SW_EXT_PORT_TRAP_SUP = 4096
    IBV_PORT_EXTENDED_SPEEDS_SUP = 16384
    IBV_PORT_CAP_MASK2_SUP = 32768
    IBV_PORT_CM_SUP = 65536
    IBV_PORT_SNMP_TUNNEL_SUP = 131072
    IBV_PORT_REINIT_SUP = 262144
    IBV_PORT_DEVICE_MGMT_SUP = 524288
    IBV_PORT_VENDOR_CLASS_SUP = 1048576
    IBV_PORT_DR_NOTICE_SUP = 2097152
    IBV_PORT_CAP_MASK_NOTICE_SUP = 4194304
    IBV_PORT_BOOT_MGMT_SUP = 8388608
    IBV_PORT_LINK_LATENCY_SUP = 16777216
    IBV_PORT_CLIENT_REG_SUP = 33554432
    IBV_PORT_IP_BASED_GIDS = 67108864
end

@cenum ibv_port_cap_flags2::UInt32 begin
    IBV_PORT_SET_NODE_DESC_SUP = 1
    IBV_PORT_INFO_EXT_SUP = 2
    IBV_PORT_VIRT_SUP = 4
    IBV_PORT_SWITCH_PORT_STATE_TABLE_SUP = 8
    IBV_PORT_LINK_WIDTH_2X_SUP = 16
    IBV_PORT_LINK_SPEED_HDR_SUP = 32
    IBV_PORT_LINK_SPEED_NDR_SUP = 1024
    IBV_PORT_LINK_SPEED_XDR_SUP = 4096
end

@cenum ibv_event_type::UInt32 begin
    IBV_EVENT_CQ_ERR = 0
    IBV_EVENT_QP_FATAL = 1
    IBV_EVENT_QP_REQ_ERR = 2
    IBV_EVENT_QP_ACCESS_ERR = 3
    IBV_EVENT_COMM_EST = 4
    IBV_EVENT_SQ_DRAINED = 5
    IBV_EVENT_PATH_MIG = 6
    IBV_EVENT_PATH_MIG_ERR = 7
    IBV_EVENT_DEVICE_FATAL = 8
    IBV_EVENT_PORT_ACTIVE = 9
    IBV_EVENT_PORT_ERR = 10
    IBV_EVENT_LID_CHANGE = 11
    IBV_EVENT_PKEY_CHANGE = 12
    IBV_EVENT_SM_CHANGE = 13
    IBV_EVENT_SRQ_ERR = 14
    IBV_EVENT_SRQ_LIMIT_REACHED = 15
    IBV_EVENT_QP_LAST_WQE_REACHED = 16
    IBV_EVENT_CLIENT_REREGISTER = 17
    IBV_EVENT_GID_CHANGE = 18
    IBV_EVENT_WQ_FATAL = 19
end

struct var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:477:2)"
    data::NTuple{8, UInt8}
end

function Base.getproperty(x::Ptr{var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:477:2)"}, f::Symbol)
    f === :cq && return Ptr{Ptr{ibv_cq}}(x + 0)
    f === :qp && return Ptr{Ptr{ibv_qp}}(x + 0)
    f === :srq && return Ptr{Ptr{ibv_srq}}(x + 0)
    f === :wq && return Ptr{Ptr{ibv_wq}}(x + 0)
    f === :port_num && return Ptr{Cint}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:477:2)", f::Symbol)
    r = Ref{var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:477:2)"}(x)
    ptr = Base.unsafe_convert(Ptr{var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:477:2)"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:477:2)"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct ibv_async_event
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{ibv_async_event}, f::Symbol)
    f === :element && return Ptr{var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:477:2)"}(x + 0)
    f === :event_type && return Ptr{ibv_event_type}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::ibv_async_event, f::Symbol)
    r = Ref{ibv_async_event}(x)
    ptr = Base.unsafe_convert(Ptr{ibv_async_event}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{ibv_async_event}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum ibv_wc_status::UInt32 begin
    IBV_WC_SUCCESS = 0
    IBV_WC_LOC_LEN_ERR = 1
    IBV_WC_LOC_QP_OP_ERR = 2
    IBV_WC_LOC_EEC_OP_ERR = 3
    IBV_WC_LOC_PROT_ERR = 4
    IBV_WC_WR_FLUSH_ERR = 5
    IBV_WC_MW_BIND_ERR = 6
    IBV_WC_BAD_RESP_ERR = 7
    IBV_WC_LOC_ACCESS_ERR = 8
    IBV_WC_REM_INV_REQ_ERR = 9
    IBV_WC_REM_ACCESS_ERR = 10
    IBV_WC_REM_OP_ERR = 11
    IBV_WC_RETRY_EXC_ERR = 12
    IBV_WC_RNR_RETRY_EXC_ERR = 13
    IBV_WC_LOC_RDD_VIOL_ERR = 14
    IBV_WC_REM_INV_RD_REQ_ERR = 15
    IBV_WC_REM_ABORT_ERR = 16
    IBV_WC_INV_EECN_ERR = 17
    IBV_WC_INV_EEC_STATE_ERR = 18
    IBV_WC_FATAL_ERR = 19
    IBV_WC_RESP_TIMEOUT_ERR = 20
    IBV_WC_GENERAL_ERR = 21
    IBV_WC_TM_ERR = 22
    IBV_WC_TM_RNDV_INCOMPLETE = 23
end

function ibv_wc_status_str(status)
    ccall((:ibv_wc_status_str, libibverbs), Ptr{Cchar}, (ibv_wc_status,), status)
end

@cenum ibv_wc_opcode::UInt32 begin
    IBV_WC_SEND = 0
    IBV_WC_RDMA_WRITE = 1
    IBV_WC_RDMA_READ = 2
    IBV_WC_COMP_SWAP = 3
    IBV_WC_FETCH_ADD = 4
    IBV_WC_BIND_MW = 5
    IBV_WC_LOCAL_INV = 6
    IBV_WC_TSO = 7
    IBV_WC_FLUSH = 8
    IBV_WC_ATOMIC_WRITE = 9
    IBV_WC_RECV = 128
    IBV_WC_RECV_RDMA_WITH_IMM = 129
    IBV_WC_TM_ADD = 130
    IBV_WC_TM_DEL = 131
    IBV_WC_TM_SYNC = 132
    IBV_WC_TM_RECV = 133
    IBV_WC_TM_NO_TAG = 134
    IBV_WC_DRIVER1 = 135
    IBV_WC_DRIVER2 = 136
    IBV_WC_DRIVER3 = 137
end

@cenum var"##Ctag#245"::UInt32 begin
    IBV_WC_IP_CSUM_OK_SHIFT = 2
end

@cenum ibv_create_cq_wc_flags::UInt32 begin
    IBV_WC_EX_WITH_BYTE_LEN = 1
    IBV_WC_EX_WITH_IMM = 2
    IBV_WC_EX_WITH_QP_NUM = 4
    IBV_WC_EX_WITH_SRC_QP = 8
    IBV_WC_EX_WITH_SLID = 16
    IBV_WC_EX_WITH_SL = 32
    IBV_WC_EX_WITH_DLID_PATH_BITS = 64
    IBV_WC_EX_WITH_COMPLETION_TIMESTAMP = 128
    IBV_WC_EX_WITH_CVLAN = 256
    IBV_WC_EX_WITH_FLOW_TAG = 512
    IBV_WC_EX_WITH_TM_INFO = 1024
    IBV_WC_EX_WITH_COMPLETION_TIMESTAMP_WALLCLOCK = 2048
end

@cenum var"##Ctag#246"::UInt32 begin
    IBV_WC_STANDARD_FLAGS = 127
end

@cenum var"##Ctag#247"::UInt32 begin
    IBV_CREATE_CQ_SUP_WC_FLAGS = 4095
end

@cenum ibv_wc_flags::UInt32 begin
    IBV_WC_GRH = 1
    IBV_WC_WITH_IMM = 2
    IBV_WC_IP_CSUM_OK = 4
    IBV_WC_WITH_INV = 8
    IBV_WC_TM_SYNC_REQ = 16
    IBV_WC_TM_MATCH = 32
    IBV_WC_TM_DATA_VALID = 64
end

struct ibv_wc
    data::NTuple{48, UInt8}
end

function Base.getproperty(x::Ptr{ibv_wc}, f::Symbol)
    f === :wr_id && return Ptr{UInt64}(x + 0)
    f === :status && return Ptr{ibv_wc_status}(x + 8)
    f === :opcode && return Ptr{ibv_wc_opcode}(x + 12)
    f === :vendor_err && return Ptr{UInt32}(x + 16)
    f === :byte_len && return Ptr{UInt32}(x + 20)
    f === :imm_data && return Ptr{__be32}(x + 24)
    f === :invalidated_rkey && return Ptr{UInt32}(x + 24)
    f === :qp_num && return Ptr{UInt32}(x + 28)
    f === :src_qp && return Ptr{UInt32}(x + 32)
    f === :wc_flags && return Ptr{Cuint}(x + 36)
    f === :pkey_index && return Ptr{UInt16}(x + 40)
    f === :slid && return Ptr{UInt16}(x + 42)
    f === :sl && return Ptr{UInt8}(x + 44)
    f === :dlid_path_bits && return Ptr{UInt8}(x + 45)
    return getfield(x, f)
end

function Base.getproperty(x::ibv_wc, f::Symbol)
    r = Ref{ibv_wc}(x)
    ptr = Base.unsafe_convert(Ptr{ibv_wc}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{ibv_wc}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum ibv_access_flags::UInt32 begin
    IBV_ACCESS_LOCAL_WRITE = 1
    IBV_ACCESS_REMOTE_WRITE = 2
    IBV_ACCESS_REMOTE_READ = 4
    IBV_ACCESS_REMOTE_ATOMIC = 8
    IBV_ACCESS_MW_BIND = 16
    IBV_ACCESS_ZERO_BASED = 32
    IBV_ACCESS_ON_DEMAND = 64
    IBV_ACCESS_HUGETLB = 128
    IBV_ACCESS_FLUSH_GLOBAL = 256
    IBV_ACCESS_FLUSH_PERSISTENT = 512
    IBV_ACCESS_RELAXED_ORDERING = 1048576
end

struct ibv_mw_bind_info
    mr::Ptr{ibv_mr}
    addr::UInt64
    length::UInt64
    mw_access_flags::Cuint
end

struct ibv_td_init_attr
    comp_mask::UInt32
end

struct ibv_td
    context::Ptr{ibv_context}
end

@cenum ibv_xrcd_init_attr_mask::UInt32 begin
    IBV_XRCD_INIT_ATTR_FD = 1
    IBV_XRCD_INIT_ATTR_OFLAGS = 2
    IBV_XRCD_INIT_ATTR_RESERVED = 4
end

struct ibv_xrcd_init_attr
    comp_mask::UInt32
    fd::Cint
    oflags::Cint
end

struct ibv_xrcd
    context::Ptr{ibv_context}
end

@cenum ibv_rereg_mr_flags::UInt32 begin
    IBV_REREG_MR_CHANGE_TRANSLATION = 1
    IBV_REREG_MR_CHANGE_PD = 2
    IBV_REREG_MR_CHANGE_ACCESS = 4
    IBV_REREG_MR_FLAGS_SUPPORTED = 7
end

@cenum ibv_mw_type::UInt32 begin
    IBV_MW_TYPE_1 = 1
    IBV_MW_TYPE_2 = 2
end

struct ibv_mw
    context::Ptr{ibv_context}
    pd::Ptr{ibv_pd}
    rkey::UInt32
    handle::UInt32
    type::ibv_mw_type
end

struct ibv_global_route
    data::NTuple{24, UInt8}
end

function Base.getproperty(x::Ptr{ibv_global_route}, f::Symbol)
    f === :dgid && return Ptr{ibv_gid}(x + 0)
    f === :flow_label && return Ptr{UInt32}(x + 16)
    f === :sgid_index && return Ptr{UInt8}(x + 20)
    f === :hop_limit && return Ptr{UInt8}(x + 21)
    f === :traffic_class && return Ptr{UInt8}(x + 22)
    return getfield(x, f)
end

function Base.getproperty(x::ibv_global_route, f::Symbol)
    r = Ref{ibv_global_route}(x)
    ptr = Base.unsafe_convert(Ptr{ibv_global_route}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{ibv_global_route}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct ibv_grh
    data::NTuple{40, UInt8}
end

function Base.getproperty(x::Ptr{ibv_grh}, f::Symbol)
    f === :version_tclass_flow && return Ptr{__be32}(x + 0)
    f === :paylen && return Ptr{__be16}(x + 4)
    f === :next_hdr && return Ptr{UInt8}(x + 6)
    f === :hop_limit && return Ptr{UInt8}(x + 7)
    f === :sgid && return Ptr{ibv_gid}(x + 8)
    f === :dgid && return Ptr{ibv_gid}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::ibv_grh, f::Symbol)
    r = Ref{ibv_grh}(x)
    ptr = Base.unsafe_convert(Ptr{ibv_grh}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{ibv_grh}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum ibv_rate::UInt32 begin
    IBV_RATE_MAX = 0
    IBV_RATE_2_5_GBPS = 2
    IBV_RATE_5_GBPS = 5
    IBV_RATE_10_GBPS = 3
    IBV_RATE_20_GBPS = 6
    IBV_RATE_30_GBPS = 4
    IBV_RATE_40_GBPS = 7
    IBV_RATE_60_GBPS = 8
    IBV_RATE_80_GBPS = 9
    IBV_RATE_120_GBPS = 10
    IBV_RATE_14_GBPS = 11
    IBV_RATE_56_GBPS = 12
    IBV_RATE_112_GBPS = 13
    IBV_RATE_168_GBPS = 14
    IBV_RATE_25_GBPS = 15
    IBV_RATE_100_GBPS = 16
    IBV_RATE_200_GBPS = 17
    IBV_RATE_300_GBPS = 18
    IBV_RATE_28_GBPS = 19
    IBV_RATE_50_GBPS = 20
    IBV_RATE_400_GBPS = 21
    IBV_RATE_600_GBPS = 22
    IBV_RATE_800_GBPS = 23
    IBV_RATE_1200_GBPS = 24
end

function ibv_rate_to_mult(rate)
    ccall((:ibv_rate_to_mult, libibverbs), Cint, (ibv_rate,), rate)
end

function mult_to_ibv_rate(mult)
    ccall((:mult_to_ibv_rate, libibverbs), ibv_rate, (Cint,), mult)
end

function ibv_rate_to_mbps(rate)
    ccall((:ibv_rate_to_mbps, libibverbs), Cint, (ibv_rate,), rate)
end

function mbps_to_ibv_rate(mbps)
    ccall((:mbps_to_ibv_rate, libibverbs), ibv_rate, (Cint,), mbps)
end

struct ibv_ah_attr
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{ibv_ah_attr}, f::Symbol)
    f === :grh && return Ptr{ibv_global_route}(x + 0)
    f === :dlid && return Ptr{UInt16}(x + 24)
    f === :sl && return Ptr{UInt8}(x + 26)
    f === :src_path_bits && return Ptr{UInt8}(x + 27)
    f === :static_rate && return Ptr{UInt8}(x + 28)
    f === :is_global && return Ptr{UInt8}(x + 29)
    f === :port_num && return Ptr{UInt8}(x + 30)
    return getfield(x, f)
end

function Base.getproperty(x::ibv_ah_attr, f::Symbol)
    r = Ref{ibv_ah_attr}(x)
    ptr = Base.unsafe_convert(Ptr{ibv_ah_attr}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{ibv_ah_attr}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum ibv_srq_attr_mask::UInt32 begin
    IBV_SRQ_MAX_WR = 1
    IBV_SRQ_LIMIT = 2
end

struct ibv_srq_attr
    max_wr::UInt32
    max_sge::UInt32
    srq_limit::UInt32
end

struct ibv_srq_init_attr
    srq_context::Ptr{Cvoid}
    attr::ibv_srq_attr
end

@cenum ibv_srq_type::UInt32 begin
    IBV_SRQT_BASIC = 0
    IBV_SRQT_XRC = 1
    IBV_SRQT_TM = 2
end

@cenum ibv_srq_init_attr_mask::UInt32 begin
    IBV_SRQ_INIT_ATTR_TYPE = 1
    IBV_SRQ_INIT_ATTR_PD = 2
    IBV_SRQ_INIT_ATTR_XRCD = 4
    IBV_SRQ_INIT_ATTR_CQ = 8
    IBV_SRQ_INIT_ATTR_TM = 16
    IBV_SRQ_INIT_ATTR_RESERVED = 32
end

struct ibv_tm_cap
    max_num_tags::UInt32
    max_ops::UInt32
end

struct ibv_comp_channel
    context::Ptr{ibv_context}
    fd::Cint
    refcnt::Cint
end

struct ibv_cq
    context::Ptr{ibv_context}
    channel::Ptr{ibv_comp_channel}
    cq_context::Ptr{Cvoid}
    handle::UInt32
    cqe::Cint
    mutex::pthread_mutex_t
    cond::pthread_cond_t
    comp_events_completed::UInt32
    async_events_completed::UInt32
end

struct ibv_srq_init_attr_ex
    srq_context::Ptr{Cvoid}
    attr::ibv_srq_attr
    comp_mask::UInt32
    srq_type::ibv_srq_type
    pd::Ptr{ibv_pd}
    xrcd::Ptr{ibv_xrcd}
    cq::Ptr{ibv_cq}
    tm_cap::ibv_tm_cap
end

@cenum ibv_wq_type::UInt32 begin
    IBV_WQT_RQ = 0
end

@cenum ibv_wq_init_attr_mask::UInt32 begin
    IBV_WQ_INIT_ATTR_FLAGS = 1
    IBV_WQ_INIT_ATTR_RESERVED = 2
end

@cenum ibv_wq_flags::UInt32 begin
    IBV_WQ_FLAGS_CVLAN_STRIPPING = 1
    IBV_WQ_FLAGS_SCATTER_FCS = 2
    IBV_WQ_FLAGS_DELAY_DROP = 4
    IBV_WQ_FLAGS_PCI_WRITE_END_PADDING = 8
    IBV_WQ_FLAGS_RESERVED = 16
end

struct ibv_wq_init_attr
    wq_context::Ptr{Cvoid}
    wq_type::ibv_wq_type
    max_wr::UInt32
    max_sge::UInt32
    pd::Ptr{ibv_pd}
    cq::Ptr{ibv_cq}
    comp_mask::UInt32
    create_flags::UInt32
end

@cenum ibv_wq_state::UInt32 begin
    IBV_WQS_RESET = 0
    IBV_WQS_RDY = 1
    IBV_WQS_ERR = 2
    IBV_WQS_UNKNOWN = 3
end

@cenum ibv_wq_attr_mask::UInt32 begin
    IBV_WQ_ATTR_STATE = 1
    IBV_WQ_ATTR_CURR_STATE = 2
    IBV_WQ_ATTR_FLAGS = 4
    IBV_WQ_ATTR_RESERVED = 8
end

struct ibv_wq_attr
    attr_mask::UInt32
    wq_state::ibv_wq_state
    curr_wq_state::ibv_wq_state
    flags::UInt32
    flags_mask::UInt32
end

struct ibv_rwq_ind_table
    context::Ptr{ibv_context}
    ind_tbl_handle::Cint
    ind_tbl_num::Cint
    comp_mask::UInt32
end

@cenum ibv_ind_table_init_attr_mask::UInt32 begin
    IBV_CREATE_IND_TABLE_RESERVED = 1
end

struct ibv_wq
    context::Ptr{ibv_context}
    wq_context::Ptr{Cvoid}
    pd::Ptr{ibv_pd}
    cq::Ptr{ibv_cq}
    wq_num::UInt32
    handle::UInt32
    state::ibv_wq_state
    wq_type::ibv_wq_type
    post_recv::Ptr{Cvoid}
    mutex::pthread_mutex_t
    cond::pthread_cond_t
    events_completed::UInt32
    comp_mask::UInt32
end

struct ibv_rwq_ind_table_init_attr
    log_ind_tbl_size::UInt32
    ind_tbl::Ptr{Ptr{ibv_wq}}
    comp_mask::UInt32
end

@cenum ibv_qp_type::UInt32 begin
    IBV_QPT_RC = 2
    IBV_QPT_UC = 3
    IBV_QPT_UD = 4
    IBV_QPT_RAW_PACKET = 8
    IBV_QPT_XRC_SEND = 9
    IBV_QPT_XRC_RECV = 10
    IBV_QPT_DRIVER = 255
end

struct ibv_qp_cap
    max_send_wr::UInt32
    max_recv_wr::UInt32
    max_send_sge::UInt32
    max_recv_sge::UInt32
    max_inline_data::UInt32
end

struct ibv_srq
    context::Ptr{ibv_context}
    srq_context::Ptr{Cvoid}
    pd::Ptr{ibv_pd}
    handle::UInt32
    mutex::pthread_mutex_t
    cond::pthread_cond_t
    events_completed::UInt32
end

struct ibv_qp_init_attr
    qp_context::Ptr{Cvoid}
    send_cq::Ptr{ibv_cq}
    recv_cq::Ptr{ibv_cq}
    srq::Ptr{ibv_srq}
    cap::ibv_qp_cap
    qp_type::ibv_qp_type
    sq_sig_all::Cint
end

@cenum ibv_qp_init_attr_mask::UInt32 begin
    IBV_QP_INIT_ATTR_PD = 1
    IBV_QP_INIT_ATTR_XRCD = 2
    IBV_QP_INIT_ATTR_CREATE_FLAGS = 4
    IBV_QP_INIT_ATTR_MAX_TSO_HEADER = 8
    IBV_QP_INIT_ATTR_IND_TABLE = 16
    IBV_QP_INIT_ATTR_RX_HASH = 32
    IBV_QP_INIT_ATTR_SEND_OPS_FLAGS = 64
end

@cenum ibv_qp_create_flags::UInt32 begin
    IBV_QP_CREATE_BLOCK_SELF_MCAST_LB = 2
    IBV_QP_CREATE_SCATTER_FCS = 256
    IBV_QP_CREATE_CVLAN_STRIPPING = 512
    IBV_QP_CREATE_SOURCE_QPN = 1024
    IBV_QP_CREATE_PCI_WRITE_END_PADDING = 2048
end

@cenum ibv_qp_create_send_ops_flags::UInt32 begin
    IBV_QP_EX_WITH_RDMA_WRITE = 1
    IBV_QP_EX_WITH_RDMA_WRITE_WITH_IMM = 2
    IBV_QP_EX_WITH_SEND = 4
    IBV_QP_EX_WITH_SEND_WITH_IMM = 8
    IBV_QP_EX_WITH_RDMA_READ = 16
    IBV_QP_EX_WITH_ATOMIC_CMP_AND_SWP = 32
    IBV_QP_EX_WITH_ATOMIC_FETCH_AND_ADD = 64
    IBV_QP_EX_WITH_LOCAL_INV = 128
    IBV_QP_EX_WITH_BIND_MW = 256
    IBV_QP_EX_WITH_SEND_WITH_INV = 512
    IBV_QP_EX_WITH_TSO = 1024
    IBV_QP_EX_WITH_FLUSH = 2048
    IBV_QP_EX_WITH_ATOMIC_WRITE = 4096
end

struct ibv_rx_hash_conf
    rx_hash_function::UInt8
    rx_hash_key_len::UInt8
    rx_hash_key::Ptr{UInt8}
    rx_hash_fields_mask::UInt64
end

struct ibv_qp_init_attr_ex
    qp_context::Ptr{Cvoid}
    send_cq::Ptr{ibv_cq}
    recv_cq::Ptr{ibv_cq}
    srq::Ptr{ibv_srq}
    cap::ibv_qp_cap
    qp_type::ibv_qp_type
    sq_sig_all::Cint
    comp_mask::UInt32
    pd::Ptr{ibv_pd}
    xrcd::Ptr{ibv_xrcd}
    create_flags::UInt32
    max_tso_header::UInt16
    rwq_ind_tbl::Ptr{ibv_rwq_ind_table}
    rx_hash_conf::ibv_rx_hash_conf
    source_qpn::UInt32
    send_ops_flags::UInt64
end

@cenum ibv_qp_open_attr_mask::UInt32 begin
    IBV_QP_OPEN_ATTR_NUM = 1
    IBV_QP_OPEN_ATTR_XRCD = 2
    IBV_QP_OPEN_ATTR_CONTEXT = 4
    IBV_QP_OPEN_ATTR_TYPE = 8
    IBV_QP_OPEN_ATTR_RESERVED = 16
end

struct ibv_qp_open_attr
    comp_mask::UInt32
    qp_num::UInt32
    xrcd::Ptr{ibv_xrcd}
    qp_context::Ptr{Cvoid}
    qp_type::ibv_qp_type
end

@cenum ibv_qp_attr_mask::UInt32 begin
    IBV_QP_STATE = 1
    IBV_QP_CUR_STATE = 2
    IBV_QP_EN_SQD_ASYNC_NOTIFY = 4
    IBV_QP_ACCESS_FLAGS = 8
    IBV_QP_PKEY_INDEX = 16
    IBV_QP_PORT = 32
    IBV_QP_QKEY = 64
    IBV_QP_AV = 128
    IBV_QP_PATH_MTU = 256
    IBV_QP_TIMEOUT = 512
    IBV_QP_RETRY_CNT = 1024
    IBV_QP_RNR_RETRY = 2048
    IBV_QP_RQ_PSN = 4096
    IBV_QP_MAX_QP_RD_ATOMIC = 8192
    IBV_QP_ALT_PATH = 16384
    IBV_QP_MIN_RNR_TIMER = 32768
    IBV_QP_SQ_PSN = 65536
    IBV_QP_MAX_DEST_RD_ATOMIC = 131072
    IBV_QP_PATH_MIG_STATE = 262144
    IBV_QP_CAP = 524288
    IBV_QP_DEST_QPN = 1048576
    IBV_QP_RATE_LIMIT = 33554432
end

@cenum ibv_query_qp_data_in_order_flags::UInt32 begin
    IBV_QUERY_QP_DATA_IN_ORDER_RETURN_CAPS = 1
end

@cenum ibv_query_qp_data_in_order_caps::UInt32 begin
    IBV_QUERY_QP_DATA_IN_ORDER_WHOLE_MSG = 1
    IBV_QUERY_QP_DATA_IN_ORDER_ALIGNED_128_BYTES = 2
end

@cenum ibv_qp_state::UInt32 begin
    IBV_QPS_RESET = 0
    IBV_QPS_INIT = 1
    IBV_QPS_RTR = 2
    IBV_QPS_RTS = 3
    IBV_QPS_SQD = 4
    IBV_QPS_SQE = 5
    IBV_QPS_ERR = 6
    IBV_QPS_UNKNOWN = 7
end

@cenum ibv_mig_state::UInt32 begin
    IBV_MIG_MIGRATED = 0
    IBV_MIG_REARM = 1
    IBV_MIG_ARMED = 2
end

struct ibv_qp_attr
    data::NTuple{144, UInt8}
end

function Base.getproperty(x::Ptr{ibv_qp_attr}, f::Symbol)
    f === :qp_state && return Ptr{ibv_qp_state}(x + 0)
    f === :cur_qp_state && return Ptr{ibv_qp_state}(x + 4)
    f === :path_mtu && return Ptr{ibv_mtu}(x + 8)
    f === :path_mig_state && return Ptr{ibv_mig_state}(x + 12)
    f === :qkey && return Ptr{UInt32}(x + 16)
    f === :rq_psn && return Ptr{UInt32}(x + 20)
    f === :sq_psn && return Ptr{UInt32}(x + 24)
    f === :dest_qp_num && return Ptr{UInt32}(x + 28)
    f === :qp_access_flags && return Ptr{Cuint}(x + 32)
    f === :cap && return Ptr{ibv_qp_cap}(x + 36)
    f === :ah_attr && return Ptr{ibv_ah_attr}(x + 56)
    f === :alt_ah_attr && return Ptr{ibv_ah_attr}(x + 88)
    f === :pkey_index && return Ptr{UInt16}(x + 120)
    f === :alt_pkey_index && return Ptr{UInt16}(x + 122)
    f === :en_sqd_async_notify && return Ptr{UInt8}(x + 124)
    f === :sq_draining && return Ptr{UInt8}(x + 125)
    f === :max_rd_atomic && return Ptr{UInt8}(x + 126)
    f === :max_dest_rd_atomic && return Ptr{UInt8}(x + 127)
    f === :min_rnr_timer && return Ptr{UInt8}(x + 128)
    f === :port_num && return Ptr{UInt8}(x + 129)
    f === :timeout && return Ptr{UInt8}(x + 130)
    f === :retry_cnt && return Ptr{UInt8}(x + 131)
    f === :rnr_retry && return Ptr{UInt8}(x + 132)
    f === :alt_port_num && return Ptr{UInt8}(x + 133)
    f === :alt_timeout && return Ptr{UInt8}(x + 134)
    f === :rate_limit && return Ptr{UInt32}(x + 136)
    return getfield(x, f)
end

function Base.getproperty(x::ibv_qp_attr, f::Symbol)
    r = Ref{ibv_qp_attr}(x)
    ptr = Base.unsafe_convert(Ptr{ibv_qp_attr}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{ibv_qp_attr}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct ibv_qp_rate_limit_attr
    rate_limit::UInt32
    max_burst_sz::UInt32
    typical_pkt_sz::UInt16
    comp_mask::UInt32
end

@cenum ibv_wr_opcode::UInt32 begin
    IBV_WR_RDMA_WRITE = 0
    IBV_WR_RDMA_WRITE_WITH_IMM = 1
    IBV_WR_SEND = 2
    IBV_WR_SEND_WITH_IMM = 3
    IBV_WR_RDMA_READ = 4
    IBV_WR_ATOMIC_CMP_AND_SWP = 5
    IBV_WR_ATOMIC_FETCH_AND_ADD = 6
    IBV_WR_LOCAL_INV = 7
    IBV_WR_BIND_MW = 8
    IBV_WR_SEND_WITH_INV = 9
    IBV_WR_TSO = 10
    IBV_WR_DRIVER1 = 11
    IBV_WR_FLUSH = 14
    IBV_WR_ATOMIC_WRITE = 15
end

function ibv_wr_opcode_str(opcode)
    ccall((:ibv_wr_opcode_str, libibverbs), Ptr{Cchar}, (ibv_wr_opcode,), opcode)
end

@cenum ibv_send_flags::UInt32 begin
    IBV_SEND_FENCE = 1
    IBV_SEND_SIGNALED = 2
    IBV_SEND_SOLICITED = 4
    IBV_SEND_INLINE = 8
    IBV_SEND_IP_CSUM = 16
end

@cenum ibv_placement_type::UInt32 begin
    IBV_FLUSH_GLOBAL = 1
    IBV_FLUSH_PERSISTENT = 2
end

@cenum ibv_selectivity_level::UInt32 begin
    IBV_FLUSH_RANGE = 0
    IBV_FLUSH_MR = 1
end

struct ibv_data_buf
    addr::Ptr{Cvoid}
    length::Csize_t
end

struct ibv_sge
    addr::UInt64
    length::UInt32
    lkey::UInt32
end

struct ibv_fd_arr
    arr::Ptr{Cint}
    count::UInt32
end

struct var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1172:2)"
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1172:2)"}, f::Symbol)
    f === :rdma && return Ptr{var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1173:3)"}(x + 0)
    f === :atomic && return Ptr{var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1177:3)"}(x + 0)
    f === :ud && return Ptr{var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1183:3)"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1172:2)", f::Symbol)
    r = Ref{var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1172:2)"}(x)
    ptr = Base.unsafe_convert(Ptr{var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1172:2)"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1172:2)"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1189:2)"
    data::NTuple{4, UInt8}
end

function Base.getproperty(x::Ptr{var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1189:2)"}, f::Symbol)
    f === :xrc && return Ptr{var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1190:3)"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1189:2)", f::Symbol)
    r = Ref{var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1189:2)"}(x)
    ptr = Base.unsafe_convert(Ptr{var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1189:2)"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1189:2)"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct ibv_send_wr
    data::NTuple{128, UInt8}
end

function Base.getproperty(x::Ptr{ibv_send_wr}, f::Symbol)
    f === :wr_id && return Ptr{UInt64}(x + 0)
    f === :next && return Ptr{Ptr{ibv_send_wr}}(x + 8)
    f === :sg_list && return Ptr{Ptr{ibv_sge}}(x + 16)
    f === :num_sge && return Ptr{Cint}(x + 24)
    f === :opcode && return Ptr{ibv_wr_opcode}(x + 28)
    f === :send_flags && return Ptr{Cuint}(x + 32)
    f === :imm_data && return Ptr{__be32}(x + 36)
    f === :invalidate_rkey && return Ptr{UInt32}(x + 36)
    f === :wr && return Ptr{var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1172:2)"}(x + 40)
    f === :qp_type && return Ptr{var"union (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1189:2)"}(x + 72)
    f === :bind_mw && return Ptr{Cvoid}(x + 80)
    f === :tso && return Ptr{Cvoid}(x + 80)
    return getfield(x, f)
end

function Base.getproperty(x::ibv_send_wr, f::Symbol)
    r = Ref{ibv_send_wr}(x)
    ptr = Base.unsafe_convert(Ptr{ibv_send_wr}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{ibv_send_wr}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct ibv_recv_wr
    wr_id::UInt64
    next::Ptr{ibv_recv_wr}
    sg_list::Ptr{ibv_sge}
    num_sge::Cint
end

@cenum ibv_ops_wr_opcode::UInt32 begin
    IBV_WR_TAG_ADD = 0
    IBV_WR_TAG_DEL = 1
    IBV_WR_TAG_SYNC = 2
end

@cenum ibv_ops_flags::UInt32 begin
    IBV_OPS_SIGNALED = 1
    IBV_OPS_TM_SYNC = 2
end

struct var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1234:3)"
    recv_wr_id::UInt64
    sg_list::Ptr{ibv_sge}
    num_sge::Cint
    tag::UInt64
    mask::UInt64
end

struct var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1231:2)"
    data::NTuple{48, UInt8}
end

function Base.getproperty(x::Ptr{var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1231:2)"}, f::Symbol)
    f === :unexpected_cnt && return Ptr{UInt32}(x + 0)
    f === :handle && return Ptr{UInt32}(x + 4)
    f === :add && return Ptr{var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1234:3)"}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1231:2)", f::Symbol)
    r = Ref{var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1231:2)"}(x)
    ptr = Base.unsafe_convert(Ptr{var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1231:2)"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1231:2)"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct ibv_ops_wr
    data::NTuple{72, UInt8}
end

function Base.getproperty(x::Ptr{ibv_ops_wr}, f::Symbol)
    f === :wr_id && return Ptr{UInt64}(x + 0)
    f === :next && return Ptr{Ptr{ibv_ops_wr}}(x + 8)
    f === :opcode && return Ptr{ibv_ops_wr_opcode}(x + 16)
    f === :flags && return Ptr{Cint}(x + 20)
    f === :tm && return Ptr{var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1231:2)"}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::ibv_ops_wr, f::Symbol)
    r = Ref{ibv_ops_wr}(x)
    ptr = Base.unsafe_convert(Ptr{ibv_ops_wr}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{ibv_ops_wr}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct ibv_mw_bind
    wr_id::UInt64
    send_flags::Cuint
    bind_info::ibv_mw_bind_info
end

struct ibv_qp
    context::Ptr{ibv_context}
    qp_context::Ptr{Cvoid}
    pd::Ptr{ibv_pd}
    send_cq::Ptr{ibv_cq}
    recv_cq::Ptr{ibv_cq}
    srq::Ptr{ibv_srq}
    handle::UInt32
    qp_num::UInt32
    state::ibv_qp_state
    qp_type::ibv_qp_type
    mutex::pthread_mutex_t
    cond::pthread_cond_t
    events_completed::UInt32
end

struct ibv_qp_ex
    qp_base::ibv_qp
    comp_mask::UInt64
    wr_id::UInt64
    wr_flags::Cuint
    wr_atomic_cmp_swp::Ptr{Cvoid}
    wr_atomic_fetch_add::Ptr{Cvoid}
    wr_bind_mw::Ptr{Cvoid}
    wr_local_inv::Ptr{Cvoid}
    wr_rdma_read::Ptr{Cvoid}
    wr_rdma_write::Ptr{Cvoid}
    wr_rdma_write_imm::Ptr{Cvoid}
    wr_send::Ptr{Cvoid}
    wr_send_imm::Ptr{Cvoid}
    wr_send_inv::Ptr{Cvoid}
    wr_send_tso::Ptr{Cvoid}
    wr_set_ud_addr::Ptr{Cvoid}
    wr_set_xrc_srqn::Ptr{Cvoid}
    wr_set_inline_data::Ptr{Cvoid}
    wr_set_inline_data_list::Ptr{Cvoid}
    wr_set_sge::Ptr{Cvoid}
    wr_set_sge_list::Ptr{Cvoid}
    wr_start::Ptr{Cvoid}
    wr_complete::Ptr{Cvoid}
    wr_abort::Ptr{Cvoid}
    wr_atomic_write::Ptr{Cvoid}
    wr_flush::Ptr{Cvoid}
end

function ibv_qp_to_qp_ex(qp)
    ccall((:ibv_qp_to_qp_ex, libibverbs), Ptr{ibv_qp_ex}, (Ptr{ibv_qp},), qp)
end

function ibv_wr_atomic_cmp_swp(qp, rkey, remote_addr, compare, swap)
    ccall((:ibv_wr_atomic_cmp_swp, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, UInt32, UInt64, UInt64, UInt64), qp, rkey, remote_addr, compare, swap)
end

function ibv_wr_atomic_fetch_add(qp, rkey, remote_addr, add)
    ccall((:ibv_wr_atomic_fetch_add, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, UInt32, UInt64, UInt64), qp, rkey, remote_addr, add)
end

function ibv_wr_bind_mw(qp, mw, rkey, bind_info)
    ccall((:ibv_wr_bind_mw, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, Ptr{ibv_mw}, UInt32, Ptr{ibv_mw_bind_info}), qp, mw, rkey, bind_info)
end

function ibv_wr_local_inv(qp, invalidate_rkey)
    ccall((:ibv_wr_local_inv, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, UInt32), qp, invalidate_rkey)
end

function ibv_wr_rdma_read(qp, rkey, remote_addr)
    ccall((:ibv_wr_rdma_read, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, UInt32, UInt64), qp, rkey, remote_addr)
end

function ibv_wr_rdma_write(qp, rkey, remote_addr)
    ccall((:ibv_wr_rdma_write, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, UInt32, UInt64), qp, rkey, remote_addr)
end

function ibv_wr_flush(qp, rkey, remote_addr, len, type, level)
    ccall((:ibv_wr_flush, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, UInt32, UInt64, Csize_t, UInt8, UInt8), qp, rkey, remote_addr, len, type, level)
end

function ibv_wr_rdma_write_imm(qp, rkey, remote_addr, imm_data)
    ccall((:ibv_wr_rdma_write_imm, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, UInt32, UInt64, __be32), qp, rkey, remote_addr, imm_data)
end

function ibv_wr_send(qp)
    ccall((:ibv_wr_send, libibverbs), Cvoid, (Ptr{ibv_qp_ex},), qp)
end

function ibv_wr_send_imm(qp, imm_data)
    ccall((:ibv_wr_send_imm, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, __be32), qp, imm_data)
end

function ibv_wr_send_inv(qp, invalidate_rkey)
    ccall((:ibv_wr_send_inv, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, UInt32), qp, invalidate_rkey)
end

function ibv_wr_send_tso(qp, hdr, hdr_sz, mss)
    ccall((:ibv_wr_send_tso, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, Ptr{Cvoid}, UInt16, UInt16), qp, hdr, hdr_sz, mss)
end

struct ibv_ah
    context::Ptr{ibv_context}
    pd::Ptr{ibv_pd}
    handle::UInt32
end

function ibv_wr_set_ud_addr(qp, ah, remote_qpn, remote_qkey)
    ccall((:ibv_wr_set_ud_addr, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, Ptr{ibv_ah}, UInt32, UInt32), qp, ah, remote_qpn, remote_qkey)
end

function ibv_wr_set_xrc_srqn(qp, remote_srqn)
    ccall((:ibv_wr_set_xrc_srqn, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, UInt32), qp, remote_srqn)
end

function ibv_wr_set_inline_data(qp, addr, length)
    ccall((:ibv_wr_set_inline_data, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, Ptr{Cvoid}, Csize_t), qp, addr, length)
end

function ibv_wr_set_inline_data_list(qp, num_buf, buf_list)
    ccall((:ibv_wr_set_inline_data_list, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, Csize_t, Ptr{ibv_data_buf}), qp, num_buf, buf_list)
end

function ibv_wr_set_sge(qp, lkey, addr, length)
    ccall((:ibv_wr_set_sge, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, UInt32, UInt64, UInt32), qp, lkey, addr, length)
end

function ibv_wr_set_sge_list(qp, num_sge, sg_list)
    ccall((:ibv_wr_set_sge_list, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, Csize_t, Ptr{ibv_sge}), qp, num_sge, sg_list)
end

function ibv_wr_start(qp)
    ccall((:ibv_wr_start, libibverbs), Cvoid, (Ptr{ibv_qp_ex},), qp)
end

function ibv_wr_complete(qp)
    ccall((:ibv_wr_complete, libibverbs), Cint, (Ptr{ibv_qp_ex},), qp)
end

function ibv_wr_abort(qp)
    ccall((:ibv_wr_abort, libibverbs), Cvoid, (Ptr{ibv_qp_ex},), qp)
end

function ibv_wr_atomic_write(qp, rkey, remote_addr, atomic_wr)
    ccall((:ibv_wr_atomic_write, libibverbs), Cvoid, (Ptr{ibv_qp_ex}, UInt32, UInt64, Ptr{Cvoid}), qp, rkey, remote_addr, atomic_wr)
end

struct ibv_ece
    vendor_id::UInt32
    options::UInt32
    comp_mask::UInt32
end

struct ibv_poll_cq_attr
    comp_mask::UInt32
end

struct ibv_wc_tm_info
    tag::UInt64
    priv::UInt32
end

struct ibv_cq_ex
    context::Ptr{ibv_context}
    channel::Ptr{ibv_comp_channel}
    cq_context::Ptr{Cvoid}
    handle::UInt32
    cqe::Cint
    mutex::pthread_mutex_t
    cond::pthread_cond_t
    comp_events_completed::UInt32
    async_events_completed::UInt32
    comp_mask::UInt32
    status::ibv_wc_status
    wr_id::UInt64
    start_poll::Ptr{Cvoid}
    next_poll::Ptr{Cvoid}
    end_poll::Ptr{Cvoid}
    read_opcode::Ptr{Cvoid}
    read_vendor_err::Ptr{Cvoid}
    read_byte_len::Ptr{Cvoid}
    read_imm_data::Ptr{Cvoid}
    read_qp_num::Ptr{Cvoid}
    read_src_qp::Ptr{Cvoid}
    read_wc_flags::Ptr{Cvoid}
    read_slid::Ptr{Cvoid}
    read_sl::Ptr{Cvoid}
    read_dlid_path_bits::Ptr{Cvoid}
    read_completion_ts::Ptr{Cvoid}
    read_cvlan::Ptr{Cvoid}
    read_flow_tag::Ptr{Cvoid}
    read_tm_info::Ptr{Cvoid}
    read_completion_wallclock_ns::Ptr{Cvoid}
end

function ibv_cq_ex_to_cq(cq)
    ccall((:ibv_cq_ex_to_cq, libibverbs), Ptr{ibv_cq}, (Ptr{ibv_cq_ex},), cq)
end

@cenum ibv_cq_attr_mask::UInt32 begin
    IBV_CQ_ATTR_MODERATE = 1
    IBV_CQ_ATTR_RESERVED = 2
end

struct ibv_moderate_cq
    cq_count::UInt16
    cq_period::UInt16
end

struct ibv_modify_cq_attr
    attr_mask::UInt32
    moderate::ibv_moderate_cq
end

function ibv_start_poll(cq, attr)
    ccall((:ibv_start_poll, libibverbs), Cint, (Ptr{ibv_cq_ex}, Ptr{ibv_poll_cq_attr}), cq, attr)
end

function ibv_next_poll(cq)
    ccall((:ibv_next_poll, libibverbs), Cint, (Ptr{ibv_cq_ex},), cq)
end

function ibv_end_poll(cq)
    ccall((:ibv_end_poll, libibverbs), Cvoid, (Ptr{ibv_cq_ex},), cq)
end

function ibv_wc_read_opcode(cq)
    ccall((:ibv_wc_read_opcode, libibverbs), ibv_wc_opcode, (Ptr{ibv_cq_ex},), cq)
end

function ibv_wc_read_vendor_err(cq)
    ccall((:ibv_wc_read_vendor_err, libibverbs), UInt32, (Ptr{ibv_cq_ex},), cq)
end

function ibv_wc_read_byte_len(cq)
    ccall((:ibv_wc_read_byte_len, libibverbs), UInt32, (Ptr{ibv_cq_ex},), cq)
end

function ibv_wc_read_imm_data(cq)
    ccall((:ibv_wc_read_imm_data, libibverbs), __be32, (Ptr{ibv_cq_ex},), cq)
end

function ibv_wc_read_invalidated_rkey(cq)
    ccall((:ibv_wc_read_invalidated_rkey, libibverbs), UInt32, (Ptr{ibv_cq_ex},), cq)
end

function ibv_wc_read_qp_num(cq)
    ccall((:ibv_wc_read_qp_num, libibverbs), UInt32, (Ptr{ibv_cq_ex},), cq)
end

function ibv_wc_read_src_qp(cq)
    ccall((:ibv_wc_read_src_qp, libibverbs), UInt32, (Ptr{ibv_cq_ex},), cq)
end

function ibv_wc_read_wc_flags(cq)
    ccall((:ibv_wc_read_wc_flags, libibverbs), Cuint, (Ptr{ibv_cq_ex},), cq)
end

function ibv_wc_read_slid(cq)
    ccall((:ibv_wc_read_slid, libibverbs), UInt32, (Ptr{ibv_cq_ex},), cq)
end

function ibv_wc_read_sl(cq)
    ccall((:ibv_wc_read_sl, libibverbs), UInt8, (Ptr{ibv_cq_ex},), cq)
end

function ibv_wc_read_dlid_path_bits(cq)
    ccall((:ibv_wc_read_dlid_path_bits, libibverbs), UInt8, (Ptr{ibv_cq_ex},), cq)
end

function ibv_wc_read_completion_ts(cq)
    ccall((:ibv_wc_read_completion_ts, libibverbs), UInt64, (Ptr{ibv_cq_ex},), cq)
end

function ibv_wc_read_completion_wallclock_ns(cq)
    ccall((:ibv_wc_read_completion_wallclock_ns, libibverbs), UInt64, (Ptr{ibv_cq_ex},), cq)
end

function ibv_wc_read_cvlan(cq)
    ccall((:ibv_wc_read_cvlan, libibverbs), UInt16, (Ptr{ibv_cq_ex},), cq)
end

function ibv_wc_read_flow_tag(cq)
    ccall((:ibv_wc_read_flow_tag, libibverbs), UInt32, (Ptr{ibv_cq_ex},), cq)
end

function ibv_wc_read_tm_info(cq, tm_info)
    ccall((:ibv_wc_read_tm_info, libibverbs), Cvoid, (Ptr{ibv_cq_ex}, Ptr{ibv_wc_tm_info}), cq, tm_info)
end

function ibv_post_wq_recv(wq, recv_wr, bad_recv_wr)
    ccall((:ibv_post_wq_recv, libibverbs), Cint, (Ptr{ibv_wq}, Ptr{ibv_recv_wr}, Ptr{Ptr{ibv_recv_wr}}), wq, recv_wr, bad_recv_wr)
end

@cenum ibv_flow_flags::UInt32 begin
    IBV_FLOW_ATTR_FLAGS_DONT_TRAP = 2
    IBV_FLOW_ATTR_FLAGS_EGRESS = 4
end

@cenum ibv_flow_attr_type::UInt32 begin
    IBV_FLOW_ATTR_NORMAL = 0
    IBV_FLOW_ATTR_ALL_DEFAULT = 1
    IBV_FLOW_ATTR_MC_DEFAULT = 2
    IBV_FLOW_ATTR_SNIFFER = 3
end

@cenum ibv_flow_spec_type::UInt32 begin
    IBV_FLOW_SPEC_ETH = 32
    IBV_FLOW_SPEC_IPV4 = 48
    IBV_FLOW_SPEC_IPV6 = 49
    IBV_FLOW_SPEC_IPV4_EXT = 50
    IBV_FLOW_SPEC_ESP = 52
    IBV_FLOW_SPEC_TCP = 64
    IBV_FLOW_SPEC_UDP = 65
    IBV_FLOW_SPEC_VXLAN_TUNNEL = 80
    IBV_FLOW_SPEC_GRE = 81
    IBV_FLOW_SPEC_MPLS = 96
    IBV_FLOW_SPEC_INNER = 256
    IBV_FLOW_SPEC_ACTION_TAG = 4096
    IBV_FLOW_SPEC_ACTION_DROP = 4097
    IBV_FLOW_SPEC_ACTION_HANDLE = 4098
    IBV_FLOW_SPEC_ACTION_COUNT = 4099
end

struct ibv_flow_eth_filter
    dst_mac::NTuple{6, UInt8}
    src_mac::NTuple{6, UInt8}
    ether_type::UInt16
    vlan_tag::UInt16
end

struct ibv_flow_spec_eth
    type::ibv_flow_spec_type
    size::UInt16
    val::ibv_flow_eth_filter
    mask::ibv_flow_eth_filter
end

struct ibv_flow_ipv4_filter
    src_ip::UInt32
    dst_ip::UInt32
end

struct ibv_flow_spec_ipv4
    type::ibv_flow_spec_type
    size::UInt16
    val::ibv_flow_ipv4_filter
    mask::ibv_flow_ipv4_filter
end

struct ibv_flow_ipv4_ext_filter
    src_ip::UInt32
    dst_ip::UInt32
    proto::UInt8
    tos::UInt8
    ttl::UInt8
    flags::UInt8
end

struct ibv_flow_spec_ipv4_ext
    type::ibv_flow_spec_type
    size::UInt16
    val::ibv_flow_ipv4_ext_filter
    mask::ibv_flow_ipv4_ext_filter
end

struct ibv_flow_ipv6_filter
    src_ip::NTuple{16, UInt8}
    dst_ip::NTuple{16, UInt8}
    flow_label::UInt32
    next_hdr::UInt8
    traffic_class::UInt8
    hop_limit::UInt8
end

struct ibv_flow_spec_ipv6
    type::ibv_flow_spec_type
    size::UInt16
    val::ibv_flow_ipv6_filter
    mask::ibv_flow_ipv6_filter
end

struct ibv_flow_esp_filter
    spi::UInt32
    seq::UInt32
end

struct ibv_flow_spec_esp
    type::ibv_flow_spec_type
    size::UInt16
    val::ibv_flow_esp_filter
    mask::ibv_flow_esp_filter
end

struct ibv_flow_tcp_udp_filter
    dst_port::UInt16
    src_port::UInt16
end

struct ibv_flow_spec_tcp_udp
    type::ibv_flow_spec_type
    size::UInt16
    val::ibv_flow_tcp_udp_filter
    mask::ibv_flow_tcp_udp_filter
end

struct ibv_flow_gre_filter
    c_ks_res0_ver::UInt16
    protocol::UInt16
    key::UInt32
end

struct ibv_flow_spec_gre
    type::ibv_flow_spec_type
    size::UInt16
    val::ibv_flow_gre_filter
    mask::ibv_flow_gre_filter
end

struct ibv_flow_mpls_filter
    label::UInt32
end

struct ibv_flow_spec_mpls
    type::ibv_flow_spec_type
    size::UInt16
    val::ibv_flow_mpls_filter
    mask::ibv_flow_mpls_filter
end

struct ibv_flow_tunnel_filter
    tunnel_id::UInt32
end

struct ibv_flow_spec_tunnel
    type::ibv_flow_spec_type
    size::UInt16
    val::ibv_flow_tunnel_filter
    mask::ibv_flow_tunnel_filter
end

struct ibv_flow_spec_action_tag
    type::ibv_flow_spec_type
    size::UInt16
    tag_id::UInt32
end

struct ibv_flow_spec_action_drop
    type::ibv_flow_spec_type
    size::UInt16
end

struct ibv_flow_action
    context::Ptr{ibv_context}
end

struct ibv_flow_spec_action_handle
    type::ibv_flow_spec_type
    size::UInt16
    action::Ptr{ibv_flow_action}
end

struct ibv_counters
    context::Ptr{ibv_context}
end

struct ibv_flow_spec_counter_action
    type::ibv_flow_spec_type
    size::UInt16
    counters::Ptr{ibv_counters}
end

struct ibv_flow_spec
    data::NTuple{88, UInt8}
end

function Base.getproperty(x::Ptr{ibv_flow_spec}, f::Symbol)
    f === :hdr && return Ptr{Cvoid}(x + 0)
    f === :eth && return Ptr{ibv_flow_spec_eth}(x + 0)
    f === :ipv4 && return Ptr{ibv_flow_spec_ipv4}(x + 0)
    f === :tcp_udp && return Ptr{ibv_flow_spec_tcp_udp}(x + 0)
    f === :ipv4_ext && return Ptr{ibv_flow_spec_ipv4_ext}(x + 0)
    f === :ipv6 && return Ptr{ibv_flow_spec_ipv6}(x + 0)
    f === :esp && return Ptr{ibv_flow_spec_esp}(x + 0)
    f === :tunnel && return Ptr{ibv_flow_spec_tunnel}(x + 0)
    f === :gre && return Ptr{ibv_flow_spec_gre}(x + 0)
    f === :mpls && return Ptr{ibv_flow_spec_mpls}(x + 0)
    f === :flow_tag && return Ptr{ibv_flow_spec_action_tag}(x + 0)
    f === :drop && return Ptr{ibv_flow_spec_action_drop}(x + 0)
    f === :handle && return Ptr{ibv_flow_spec_action_handle}(x + 0)
    f === :flow_count && return Ptr{ibv_flow_spec_counter_action}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::ibv_flow_spec, f::Symbol)
    r = Ref{ibv_flow_spec}(x)
    ptr = Base.unsafe_convert(Ptr{ibv_flow_spec}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{ibv_flow_spec}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct ibv_flow_attr
    comp_mask::UInt32
    type::ibv_flow_attr_type
    size::UInt16
    priority::UInt16
    num_of_specs::UInt8
    port::UInt8
    flags::UInt32
end

struct ibv_flow
    comp_mask::UInt32
    context::Ptr{ibv_context}
    handle::UInt32
end

@cenum ibv_flow_action_esp_mask::UInt32 begin
    IBV_FLOW_ACTION_ESP_MASK_ESN = 1
end

struct ibv_flow_action_esp_attr
    esp_attr::Ptr{ib_uverbs_flow_action_esp}
    keymat_proto::ib_uverbs_flow_action_esp_keymat
    keymat_len::UInt16
    keymat_ptr::Ptr{Cvoid}
    replay_proto::ib_uverbs_flow_action_esp_replay
    replay_len::UInt16
    replay_ptr::Ptr{Cvoid}
    esp_encap::Ptr{ib_uverbs_flow_action_esp_encap}
    comp_mask::UInt32
    esn::UInt32
end

@cenum var"##Ctag#248"::UInt32 begin
    IBV_SYSFS_NAME_MAX = 64
    IBV_SYSFS_PATH_MAX = 256
end

mutable struct _compat_ibv_port_attr end

@cenum ibv_cq_init_attr_mask::UInt32 begin
    IBV_CQ_INIT_ATTR_MASK_FLAGS = 1
    IBV_CQ_INIT_ATTR_MASK_PD = 2
end

@cenum ibv_create_cq_attr_flags::UInt32 begin
    IBV_CREATE_CQ_ATTR_SINGLE_THREADED = 1
    IBV_CREATE_CQ_ATTR_IGNORE_OVERRUN = 2
end

struct ibv_cq_init_attr_ex
    cqe::UInt32
    cq_context::Ptr{Cvoid}
    channel::Ptr{ibv_comp_channel}
    comp_vector::UInt32
    wc_flags::UInt64
    comp_mask::UInt32
    flags::UInt32
    parent_domain::Ptr{ibv_pd}
end

@cenum ibv_parent_domain_init_attr_mask::UInt32 begin
    IBV_PARENT_DOMAIN_INIT_ATTR_ALLOCATORS = 1
    IBV_PARENT_DOMAIN_INIT_ATTR_PD_CONTEXT = 2
end

struct ibv_parent_domain_init_attr
    pd::Ptr{ibv_pd}
    td::Ptr{ibv_td}
    comp_mask::UInt32
    alloc::Ptr{Cvoid}
    free::Ptr{Cvoid}
    pd_context::Ptr{Cvoid}
end

struct ibv_counters_init_attr
    comp_mask::UInt32
end

@cenum ibv_counter_description::UInt32 begin
    IBV_COUNTER_PACKETS = 0
    IBV_COUNTER_BYTES = 1
end

struct ibv_counter_attach_attr
    counter_desc::ibv_counter_description
    index::UInt32
    comp_mask::UInt32
end

@cenum ibv_read_counters_flags::UInt32 begin
    IBV_READ_COUNTERS_ATTR_PREFER_CACHED = 1
end

@cenum ibv_values_mask::UInt32 begin
    IBV_VALUES_MASK_RAW_CLOCK = 1
    IBV_VALUES_MASK_RESERVED = 2
end

struct ibv_values_ex
    comp_mask::UInt32
    raw_clock::timespec
end

function ibv_get_device_list(num_devices)
    ccall((:ibv_get_device_list, libibverbs), Ptr{Ptr{ibv_device}}, (Ptr{Cint},), num_devices)
end

function ibv_free_device_list(list)
    ccall((:ibv_free_device_list, libibverbs), Cvoid, (Ptr{Ptr{ibv_device}},), list)
end

function ibv_get_device_name(device)
    ccall((:ibv_get_device_name, libibverbs), Ptr{Cchar}, (Ptr{ibv_device},), device)
end

function ibv_get_device_index(device)
    ccall((:ibv_get_device_index, libibverbs), Cint, (Ptr{ibv_device},), device)
end

function ibv_get_device_guid(device)
    ccall((:ibv_get_device_guid, libibverbs), __be64, (Ptr{ibv_device},), device)
end

function ibv_open_device(device)
    ccall((:ibv_open_device, libibverbs), Ptr{ibv_context}, (Ptr{ibv_device},), device)
end

function ibv_close_device(context)
    ccall((:ibv_close_device, libibverbs), Cint, (Ptr{ibv_context},), context)
end

function ibv_import_device(cmd_fd)
    ccall((:ibv_import_device, libibverbs), Ptr{ibv_context}, (Cint,), cmd_fd)
end

function ibv_import_pd(context, pd_handle)
    ccall((:ibv_import_pd, libibverbs), Ptr{ibv_pd}, (Ptr{ibv_context}, UInt32), context, pd_handle)
end

function ibv_unimport_pd(pd)
    ccall((:ibv_unimport_pd, libibverbs), Cvoid, (Ptr{ibv_pd},), pd)
end

function ibv_import_mr(pd, mr_handle)
    ccall((:ibv_import_mr, libibverbs), Ptr{ibv_mr}, (Ptr{ibv_pd}, UInt32), pd, mr_handle)
end

function ibv_unimport_mr(mr)
    ccall((:ibv_unimport_mr, libibverbs), Cvoid, (Ptr{ibv_mr},), mr)
end

function ibv_import_dm(context, dm_handle)
    ccall((:ibv_import_dm, libibverbs), Ptr{ibv_dm}, (Ptr{ibv_context}, UInt32), context, dm_handle)
end

function ibv_unimport_dm(dm)
    ccall((:ibv_unimport_dm, libibverbs), Cvoid, (Ptr{ibv_dm},), dm)
end

function ibv_get_async_event(context, event)
    ccall((:ibv_get_async_event, libibverbs), Cint, (Ptr{ibv_context}, Ptr{ibv_async_event}), context, event)
end

function ibv_ack_async_event(event)
    ccall((:ibv_ack_async_event, libibverbs), Cvoid, (Ptr{ibv_async_event},), event)
end

function ibv_query_device(context, device_attr)
    ccall((:ibv_query_device, libibverbs), Cint, (Ptr{ibv_context}, Ptr{ibv_device_attr}), context, device_attr)
end

function ibv_query_gid(context, port_num, index, gid)
    ccall((:ibv_query_gid, libibverbs), Cint, (Ptr{ibv_context}, UInt8, Cint, Ptr{ibv_gid}), context, port_num, index, gid)
end

function _ibv_query_gid_ex(context, port_num, gid_index, entry, flags, entry_size)
    ccall((:_ibv_query_gid_ex, libibverbs), Cint, (Ptr{ibv_context}, UInt32, UInt32, Ptr{ibv_gid_entry}, UInt32, Csize_t), context, port_num, gid_index, entry, flags, entry_size)
end

function ibv_query_gid_ex(context, port_num, gid_index, entry, flags)
    ccall((:ibv_query_gid_ex, libibverbs), Cint, (Ptr{ibv_context}, UInt32, UInt32, Ptr{ibv_gid_entry}, UInt32), context, port_num, gid_index, entry, flags)
end

function _ibv_query_gid_table(context, entries, max_entries, flags, entry_size)
    ccall((:_ibv_query_gid_table, libibverbs), Cssize_t, (Ptr{ibv_context}, Ptr{ibv_gid_entry}, Csize_t, UInt32, Csize_t), context, entries, max_entries, flags, entry_size)
end

function ibv_query_gid_table(context, entries, max_entries, flags)
    ccall((:ibv_query_gid_table, libibverbs), Cssize_t, (Ptr{ibv_context}, Ptr{ibv_gid_entry}, Csize_t, UInt32), context, entries, max_entries, flags)
end

function ibv_query_pkey(context, port_num, index, pkey)
    ccall((:ibv_query_pkey, libibverbs), Cint, (Ptr{ibv_context}, UInt8, Cint, Ptr{__be16}), context, port_num, index, pkey)
end

function ibv_get_pkey_index(context, port_num, pkey)
    ccall((:ibv_get_pkey_index, libibverbs), Cint, (Ptr{ibv_context}, UInt8, __be16), context, port_num, pkey)
end

function ibv_alloc_pd(context)
    ccall((:ibv_alloc_pd, libibverbs), Ptr{ibv_pd}, (Ptr{ibv_context},), context)
end

function ibv_dealloc_pd(pd)
    ccall((:ibv_dealloc_pd, libibverbs), Cint, (Ptr{ibv_pd},), pd)
end

function ibv_create_flow(qp, flow)
    ccall((:ibv_create_flow, libibverbs), Ptr{ibv_flow}, (Ptr{ibv_qp}, Ptr{ibv_flow_attr}), qp, flow)
end

function ibv_destroy_flow(flow_id)
    ccall((:ibv_destroy_flow, libibverbs), Cint, (Ptr{ibv_flow},), flow_id)
end

function ibv_create_flow_action_esp(ctx, esp)
    ccall((:ibv_create_flow_action_esp, libibverbs), Ptr{ibv_flow_action}, (Ptr{ibv_context}, Ptr{ibv_flow_action_esp_attr}), ctx, esp)
end

function ibv_modify_flow_action_esp(action, esp)
    ccall((:ibv_modify_flow_action_esp, libibverbs), Cint, (Ptr{ibv_flow_action}, Ptr{ibv_flow_action_esp_attr}), action, esp)
end

function ibv_destroy_flow_action(action)
    ccall((:ibv_destroy_flow_action, libibverbs), Cint, (Ptr{ibv_flow_action},), action)
end

function ibv_open_xrcd(context, xrcd_init_attr)
    ccall((:ibv_open_xrcd, libibverbs), Ptr{ibv_xrcd}, (Ptr{ibv_context}, Ptr{ibv_xrcd_init_attr}), context, xrcd_init_attr)
end

function ibv_close_xrcd(xrcd)
    ccall((:ibv_close_xrcd, libibverbs), Cint, (Ptr{ibv_xrcd},), xrcd)
end

function ibv_reg_mr_iova2(pd, addr, length, iova, access)
    ccall((:ibv_reg_mr_iova2, libibverbs), Ptr{ibv_mr}, (Ptr{ibv_pd}, Ptr{Cvoid}, Csize_t, UInt64, Cuint), pd, addr, length, iova, access)
end

function ibv_reg_dmabuf_mr(pd, offset, length, iova, fd, access)
    ccall((:ibv_reg_dmabuf_mr, libibverbs), Ptr{ibv_mr}, (Ptr{ibv_pd}, UInt64, Csize_t, UInt64, Cint, Cint), pd, offset, length, iova, fd, access)
end

@cenum ibv_rereg_mr_err_code::Int32 begin
    IBV_REREG_MR_ERR_INPUT = -1
    IBV_REREG_MR_ERR_DONT_FORK_NEW = -2
    IBV_REREG_MR_ERR_DO_FORK_OLD = -3
    IBV_REREG_MR_ERR_CMD = -4
    IBV_REREG_MR_ERR_CMD_AND_DO_FORK_NEW = -5
end

function ibv_rereg_mr(mr, flags, pd, addr, length, access)
    ccall((:ibv_rereg_mr, libibverbs), Cint, (Ptr{ibv_mr}, Cint, Ptr{ibv_pd}, Ptr{Cvoid}, Csize_t, Cint), mr, flags, pd, addr, length, access)
end

function ibv_dereg_mr(mr)
    ccall((:ibv_dereg_mr, libibverbs), Cint, (Ptr{ibv_mr},), mr)
end

function ibv_alloc_mw(pd, type)
    ccall((:ibv_alloc_mw, libibverbs), Ptr{ibv_mw}, (Ptr{ibv_pd}, ibv_mw_type), pd, type)
end

function ibv_dealloc_mw(mw)
    ccall((:ibv_dealloc_mw, libibverbs), Cint, (Ptr{ibv_mw},), mw)
end

function ibv_inc_rkey(rkey)
    ccall((:ibv_inc_rkey, libibverbs), UInt32, (UInt32,), rkey)
end

function ibv_bind_mw(qp, mw, mw_bind)
    ccall((:ibv_bind_mw, libibverbs), Cint, (Ptr{ibv_qp}, Ptr{ibv_mw}, Ptr{ibv_mw_bind}), qp, mw, mw_bind)
end

function ibv_create_comp_channel(context)
    ccall((:ibv_create_comp_channel, libibverbs), Ptr{ibv_comp_channel}, (Ptr{ibv_context},), context)
end

function ibv_destroy_comp_channel(channel)
    ccall((:ibv_destroy_comp_channel, libibverbs), Cint, (Ptr{ibv_comp_channel},), channel)
end

function ibv_advise_mr(pd, advice, flags, sg_list, num_sge)
    ccall((:ibv_advise_mr, libibverbs), Cint, (Ptr{ibv_pd}, ib_uverbs_advise_mr_advice, UInt32, Ptr{ibv_sge}, UInt32), pd, advice, flags, sg_list, num_sge)
end

function ibv_alloc_dm(context, attr)
    ccall((:ibv_alloc_dm, libibverbs), Ptr{ibv_dm}, (Ptr{ibv_context}, Ptr{ibv_alloc_dm_attr}), context, attr)
end

function ibv_free_dm(dm)
    ccall((:ibv_free_dm, libibverbs), Cint, (Ptr{ibv_dm},), dm)
end

function ibv_memcpy_to_dm(dm, dm_offset, host_addr, length)
    ccall((:ibv_memcpy_to_dm, libibverbs), Cint, (Ptr{ibv_dm}, UInt64, Ptr{Cvoid}, Csize_t), dm, dm_offset, host_addr, length)
end

function ibv_memcpy_from_dm(host_addr, dm, dm_offset, length)
    ccall((:ibv_memcpy_from_dm, libibverbs), Cint, (Ptr{Cvoid}, Ptr{ibv_dm}, UInt64, Csize_t), host_addr, dm, dm_offset, length)
end

function ibv_alloc_null_mr(pd)
    ccall((:ibv_alloc_null_mr, libibverbs), Ptr{ibv_mr}, (Ptr{ibv_pd},), pd)
end

function ibv_reg_dm_mr(pd, dm, dm_offset, length, access)
    ccall((:ibv_reg_dm_mr, libibverbs), Ptr{ibv_mr}, (Ptr{ibv_pd}, Ptr{ibv_dm}, UInt64, Csize_t, Cuint), pd, dm, dm_offset, length, access)
end

function ibv_create_cq(context, cqe, cq_context, channel, comp_vector)
    ccall((:ibv_create_cq, libibverbs), Ptr{ibv_cq}, (Ptr{ibv_context}, Cint, Ptr{Cvoid}, Ptr{ibv_comp_channel}, Cint), context, cqe, cq_context, channel, comp_vector)
end

function ibv_create_cq_ex(context, cq_attr)
    ccall((:ibv_create_cq_ex, libibverbs), Ptr{ibv_cq_ex}, (Ptr{ibv_context}, Ptr{ibv_cq_init_attr_ex}), context, cq_attr)
end

function ibv_resize_cq(cq, cqe)
    ccall((:ibv_resize_cq, libibverbs), Cint, (Ptr{ibv_cq}, Cint), cq, cqe)
end

function ibv_destroy_cq(cq)
    ccall((:ibv_destroy_cq, libibverbs), Cint, (Ptr{ibv_cq},), cq)
end

function ibv_get_cq_event(channel, cq, cq_context)
    ccall((:ibv_get_cq_event, libibverbs), Cint, (Ptr{ibv_comp_channel}, Ptr{Ptr{ibv_cq}}, Ptr{Ptr{Cvoid}}), channel, cq, cq_context)
end

function ibv_ack_cq_events(cq, nevents)
    ccall((:ibv_ack_cq_events, libibverbs), Cvoid, (Ptr{ibv_cq}, Cuint), cq, nevents)
end

function ibv_poll_cq(cq, num_entries, wc)
    ccall((:ibv_poll_cq, libibverbs), Cint, (Ptr{ibv_cq}, Cint, Ptr{ibv_wc}), cq, num_entries, wc)
end

function ibv_req_notify_cq(cq, solicited_only)
    ccall((:ibv_req_notify_cq, libibverbs), Cint, (Ptr{ibv_cq}, Cint), cq, solicited_only)
end

function ibv_modify_cq(cq, attr)
    ccall((:ibv_modify_cq, libibverbs), Cint, (Ptr{ibv_cq}, Ptr{ibv_modify_cq_attr}), cq, attr)
end

function ibv_create_srq(pd, srq_init_attr)
    ccall((:ibv_create_srq, libibverbs), Ptr{ibv_srq}, (Ptr{ibv_pd}, Ptr{ibv_srq_init_attr}), pd, srq_init_attr)
end

function ibv_create_srq_ex(context, srq_init_attr_ex)
    ccall((:ibv_create_srq_ex, libibverbs), Ptr{ibv_srq}, (Ptr{ibv_context}, Ptr{ibv_srq_init_attr_ex}), context, srq_init_attr_ex)
end

function ibv_modify_srq(srq, srq_attr, srq_attr_mask)
    ccall((:ibv_modify_srq, libibverbs), Cint, (Ptr{ibv_srq}, Ptr{ibv_srq_attr}, Cint), srq, srq_attr, srq_attr_mask)
end

function ibv_query_srq(srq, srq_attr)
    ccall((:ibv_query_srq, libibverbs), Cint, (Ptr{ibv_srq}, Ptr{ibv_srq_attr}), srq, srq_attr)
end

function ibv_get_srq_num(srq, srq_num)
    ccall((:ibv_get_srq_num, libibverbs), Cint, (Ptr{ibv_srq}, Ptr{UInt32}), srq, srq_num)
end

function ibv_destroy_srq(srq)
    ccall((:ibv_destroy_srq, libibverbs), Cint, (Ptr{ibv_srq},), srq)
end

function ibv_post_srq_recv(srq, recv_wr, bad_recv_wr)
    ccall((:ibv_post_srq_recv, libibverbs), Cint, (Ptr{ibv_srq}, Ptr{ibv_recv_wr}, Ptr{Ptr{ibv_recv_wr}}), srq, recv_wr, bad_recv_wr)
end

function ibv_post_srq_ops(srq, op, bad_op)
    ccall((:ibv_post_srq_ops, libibverbs), Cint, (Ptr{ibv_srq}, Ptr{ibv_ops_wr}, Ptr{Ptr{ibv_ops_wr}}), srq, op, bad_op)
end

function ibv_create_qp(pd, qp_init_attr)
    ccall((:ibv_create_qp, libibverbs), Ptr{ibv_qp}, (Ptr{ibv_pd}, Ptr{ibv_qp_init_attr}), pd, qp_init_attr)
end

function ibv_create_qp_ex(context, qp_init_attr_ex)
    ccall((:ibv_create_qp_ex, libibverbs), Ptr{ibv_qp}, (Ptr{ibv_context}, Ptr{ibv_qp_init_attr_ex}), context, qp_init_attr_ex)
end

function ibv_alloc_td(context, init_attr)
    ccall((:ibv_alloc_td, libibverbs), Ptr{ibv_td}, (Ptr{ibv_context}, Ptr{ibv_td_init_attr}), context, init_attr)
end

function ibv_dealloc_td(td)
    ccall((:ibv_dealloc_td, libibverbs), Cint, (Ptr{ibv_td},), td)
end

function ibv_alloc_parent_domain(context, attr)
    ccall((:ibv_alloc_parent_domain, libibverbs), Ptr{ibv_pd}, (Ptr{ibv_context}, Ptr{ibv_parent_domain_init_attr}), context, attr)
end

function ibv_query_rt_values_ex(context, values)
    ccall((:ibv_query_rt_values_ex, libibverbs), Cint, (Ptr{ibv_context}, Ptr{ibv_values_ex}), context, values)
end

function ibv_query_device_ex(context, input, attr)
    ccall((:ibv_query_device_ex, libibverbs), Cint, (Ptr{ibv_context}, Ptr{ibv_query_device_ex_input}, Ptr{ibv_device_attr_ex}), context, input, attr)
end

function ibv_open_qp(context, qp_open_attr)
    ccall((:ibv_open_qp, libibverbs), Ptr{ibv_qp}, (Ptr{ibv_context}, Ptr{ibv_qp_open_attr}), context, qp_open_attr)
end

function ibv_modify_qp(qp, attr, attr_mask)
    ccall((:ibv_modify_qp, libibverbs), Cint, (Ptr{ibv_qp}, Ptr{ibv_qp_attr}, Cint), qp, attr, attr_mask)
end

function ibv_modify_qp_rate_limit(qp, attr)
    ccall((:ibv_modify_qp_rate_limit, libibverbs), Cint, (Ptr{ibv_qp}, Ptr{ibv_qp_rate_limit_attr}), qp, attr)
end

function ibv_query_qp_data_in_order(qp, op, flags)
    ccall((:ibv_query_qp_data_in_order, libibverbs), Cint, (Ptr{ibv_qp}, ibv_wr_opcode, UInt32), qp, op, flags)
end

function ibv_query_qp(qp, attr, attr_mask, init_attr)
    ccall((:ibv_query_qp, libibverbs), Cint, (Ptr{ibv_qp}, Ptr{ibv_qp_attr}, Cint, Ptr{ibv_qp_init_attr}), qp, attr, attr_mask, init_attr)
end

function ibv_destroy_qp(qp)
    ccall((:ibv_destroy_qp, libibverbs), Cint, (Ptr{ibv_qp},), qp)
end

function ibv_create_wq(context, wq_init_attr)
    ccall((:ibv_create_wq, libibverbs), Ptr{ibv_wq}, (Ptr{ibv_context}, Ptr{ibv_wq_init_attr}), context, wq_init_attr)
end

function ibv_modify_wq(wq, wq_attr)
    ccall((:ibv_modify_wq, libibverbs), Cint, (Ptr{ibv_wq}, Ptr{ibv_wq_attr}), wq, wq_attr)
end

function ibv_destroy_wq(wq)
    ccall((:ibv_destroy_wq, libibverbs), Cint, (Ptr{ibv_wq},), wq)
end

function ibv_create_rwq_ind_table(context, init_attr)
    ccall((:ibv_create_rwq_ind_table, libibverbs), Ptr{ibv_rwq_ind_table}, (Ptr{ibv_context}, Ptr{ibv_rwq_ind_table_init_attr}), context, init_attr)
end

function ibv_destroy_rwq_ind_table(rwq_ind_table)
    ccall((:ibv_destroy_rwq_ind_table, libibverbs), Cint, (Ptr{ibv_rwq_ind_table},), rwq_ind_table)
end

function ibv_post_send(qp, wr, bad_wr)
    ccall((:ibv_post_send, libibverbs), Cint, (Ptr{ibv_qp}, Ptr{ibv_send_wr}, Ptr{Ptr{ibv_send_wr}}), qp, wr, bad_wr)
end

function ibv_post_recv(qp, wr, bad_wr)
    ccall((:ibv_post_recv, libibverbs), Cint, (Ptr{ibv_qp}, Ptr{ibv_recv_wr}, Ptr{Ptr{ibv_recv_wr}}), qp, wr, bad_wr)
end

function ibv_create_ah(pd, attr)
    ccall((:ibv_create_ah, libibverbs), Ptr{ibv_ah}, (Ptr{ibv_pd}, Ptr{ibv_ah_attr}), pd, attr)
end

function ibv_init_ah_from_wc(context, port_num, wc, grh, ah_attr)
    ccall((:ibv_init_ah_from_wc, libibverbs), Cint, (Ptr{ibv_context}, UInt8, Ptr{ibv_wc}, Ptr{ibv_grh}, Ptr{ibv_ah_attr}), context, port_num, wc, grh, ah_attr)
end

function ibv_create_ah_from_wc(pd, wc, grh, port_num)
    ccall((:ibv_create_ah_from_wc, libibverbs), Ptr{ibv_ah}, (Ptr{ibv_pd}, Ptr{ibv_wc}, Ptr{ibv_grh}, UInt8), pd, wc, grh, port_num)
end

function ibv_destroy_ah(ah)
    ccall((:ibv_destroy_ah, libibverbs), Cint, (Ptr{ibv_ah},), ah)
end

function ibv_attach_mcast(qp, gid, lid)
    ccall((:ibv_attach_mcast, libibverbs), Cint, (Ptr{ibv_qp}, Ptr{ibv_gid}, UInt16), qp, gid, lid)
end

function ibv_detach_mcast(qp, gid, lid)
    ccall((:ibv_detach_mcast, libibverbs), Cint, (Ptr{ibv_qp}, Ptr{ibv_gid}, UInt16), qp, gid, lid)
end

function ibv_fork_init()
    ccall((:ibv_fork_init, libibverbs), Cint, ())
end

function ibv_is_fork_initialized()
    ccall((:ibv_is_fork_initialized, libibverbs), ibv_fork_status, ())
end

function ibv_node_type_str(node_type)
    ccall((:ibv_node_type_str, libibverbs), Ptr{Cchar}, (ibv_node_type,), node_type)
end

function ibv_port_state_str(port_state)
    ccall((:ibv_port_state_str, libibverbs), Ptr{Cchar}, (ibv_port_state,), port_state)
end

function ibv_event_type_str(event)
    ccall((:ibv_event_type_str, libibverbs), Ptr{Cchar}, (ibv_event_type,), event)
end

function ibv_resolve_eth_l2_from_gid(context, attr, eth_mac, vid)
    ccall((:ibv_resolve_eth_l2_from_gid, libibverbs), Cint, (Ptr{ibv_context}, Ptr{ibv_ah_attr}, Ptr{UInt8}, Ptr{UInt16}), context, attr, eth_mac, vid)
end

function ibv_is_qpt_supported(caps, qpt)
    ccall((:ibv_is_qpt_supported, libibverbs), Cint, (UInt32, ibv_qp_type), caps, qpt)
end

function ibv_create_counters(context, init_attr)
    ccall((:ibv_create_counters, libibverbs), Ptr{ibv_counters}, (Ptr{ibv_context}, Ptr{ibv_counters_init_attr}), context, init_attr)
end

function ibv_destroy_counters(counters)
    ccall((:ibv_destroy_counters, libibverbs), Cint, (Ptr{ibv_counters},), counters)
end

function ibv_attach_counters_point_flow(counters, attr, flow)
    ccall((:ibv_attach_counters_point_flow, libibverbs), Cint, (Ptr{ibv_counters}, Ptr{ibv_counter_attach_attr}, Ptr{ibv_flow}), counters, attr, flow)
end

function ibv_read_counters(counters, counters_value, ncounters, flags)
    ccall((:ibv_read_counters, libibverbs), Cint, (Ptr{ibv_counters}, Ptr{UInt64}, UInt32, UInt32), counters, counters_value, ncounters, flags)
end

function ibv_flow_label_to_udp_sport(fl)
    ccall((:ibv_flow_label_to_udp_sport, libibverbs), UInt16, (UInt32,), fl)
end

function ibv_set_ece(qp, ece)
    ccall((:ibv_set_ece, libibverbs), Cint, (Ptr{ibv_qp}, Ptr{ibv_ece}), qp, ece)
end

function ibv_query_ece(qp, ece)
    ccall((:ibv_query_ece, libibverbs), Cint, (Ptr{ibv_qp}, Ptr{ibv_ece}), qp, ece)
end

struct var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:67:2)"
    subnet_prefix::__be64
    interface_id::__be64
end

struct __pthread_mutex_s
    __lock::Cint
    __count::Cuint
    __owner::Cint
    __nusers::Cuint
    __kind::Cint
    __spins::Cint
    __list::__pthread_list_t
end

struct var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1173:3)"
    remote_addr::UInt64
    rkey::UInt32
end

struct var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1177:3)"
    remote_addr::UInt64
    compare_add::UInt64
    swap::UInt64
    rkey::UInt32
end

struct var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1183:3)"
    ah::Ptr{ibv_ah}
    remote_qpn::UInt32
    remote_qkey::UInt32
end

struct var"struct (unnamed at /home/davidm/.julia/artifacts/404b21a31d8b64fef8960ea1f4f6d1a2773799fc/include/infiniband/verbs.h:1190:3)"
    remote_srqn::UInt32
end

struct var"struct (unnamed at /home/davidm/.julia/artifacts/305c8b171016c46dfbb8ca234a543a99b6e3d045/x86_64-linux-gnu/sys-root/usr/include/bits/pthreadtypes.h:117:3)"
    __lock::Cint
    __futex::Cuint
    __total_seq::Culonglong
    __wakeup_seq::Culonglong
    __woken_seq::Culonglong
    __mutex::Ptr{Cvoid}
    __nwaiters::Cuint
    __broadcast_seq::Cuint
end

const IB_UVERBS_ACCESS_OPTIONAL_FIRST = 1 << 20

const IB_UVERBS_ACCESS_OPTIONAL_LAST = 1 << 29

const ibv_flow_action_esp_keymat = ib_uverbs_flow_action_esp_keymat

const IBV_FLOW_ACTION_ESP_KEYMAT_AES_GCM = IB_UVERBS_FLOW_ACTION_ESP_KEYMAT_AES_GCM

const ibv_flow_action_esp_keymat_aes_gcm_iv_algo = ib_uverbs_flow_action_esp_keymat_aes_gcm_iv_algo

const IBV_FLOW_ACTION_IV_ALGO_SEQ = IB_UVERBS_FLOW_ACTION_IV_ALGO_SEQ

const ibv_flow_action_esp_keymat_aes_gcm = ib_uverbs_flow_action_esp_keymat_aes_gcm

const ibv_flow_action_esp_replay = ib_uverbs_flow_action_esp_replay

const IBV_FLOW_ACTION_ESP_REPLAY_NONE = IB_UVERBS_FLOW_ACTION_ESP_REPLAY_NONE

const IBV_FLOW_ACTION_ESP_REPLAY_BMP = IB_UVERBS_FLOW_ACTION_ESP_REPLAY_BMP

const ibv_flow_action_esp_replay_bmp = ib_uverbs_flow_action_esp_replay_bmp

const ibv_flow_action_esp_flags = ib_uverbs_flow_action_esp_flags

const IBV_FLOW_ACTION_ESP_FLAGS_INLINE_CRYPTO = IB_UVERBS_FLOW_ACTION_ESP_FLAGS_INLINE_CRYPTO

const IBV_FLOW_ACTION_ESP_FLAGS_FULL_OFFLOAD = IB_UVERBS_FLOW_ACTION_ESP_FLAGS_FULL_OFFLOAD

const IBV_FLOW_ACTION_ESP_FLAGS_TUNNEL = IB_UVERBS_FLOW_ACTION_ESP_FLAGS_TUNNEL

const IBV_FLOW_ACTION_ESP_FLAGS_TRANSPORT = IB_UVERBS_FLOW_ACTION_ESP_FLAGS_TRANSPORT

const IBV_FLOW_ACTION_ESP_FLAGS_DECRYPT = IB_UVERBS_FLOW_ACTION_ESP_FLAGS_DECRYPT

const IBV_FLOW_ACTION_ESP_FLAGS_ENCRYPT = IB_UVERBS_FLOW_ACTION_ESP_FLAGS_ENCRYPT

const IBV_FLOW_ACTION_ESP_FLAGS_ESN_NEW_WINDOW = IB_UVERBS_FLOW_ACTION_ESP_FLAGS_ESN_NEW_WINDOW

const ibv_flow_action_esp_encap = ib_uverbs_flow_action_esp_encap

const ibv_flow_action_esp = ib_uverbs_flow_action_esp

const ibv_advise_mr_advice = ib_uverbs_advise_mr_advice

const IBV_ADVISE_MR_ADVICE_PREFETCH = IB_UVERBS_ADVISE_MR_ADVICE_PREFETCH

const IBV_ADVISE_MR_ADVICE_PREFETCH_WRITE = IB_UVERBS_ADVISE_MR_ADVICE_PREFETCH_WRITE

const IBV_ADVISE_MR_ADVICE_PREFETCH_NO_FAULT = IB_UVERBS_ADVISE_MR_ADVICE_PREFETCH_NO_FAULT

const IBV_ADVISE_MR_FLAG_FLUSH = IB_UVERBS_ADVISE_MR_FLAG_FLUSH

const IBV_QPF_GRH_REQUIRED = IB_UVERBS_QPF_GRH_REQUIRED

const IBV_ACCESS_OPTIONAL_RANGE = IB_UVERBS_ACCESS_OPTIONAL_RANGE

const IBV_ACCESS_OPTIONAL_FIRST = IB_UVERBS_ACCESS_OPTIONAL_FIRST

# Skipping MacroDefinition: __attribute_const __attribute__ ( ( const ) )

# Skipping MacroDefinition: __VERBS_ABI_IS_EXTENDED ( ( void * ) UINTPTR_MAX )

const IBV_DEVICE_RAW_SCATTER_FCS = Culonglong(1) << 34

const IBV_DEVICE_PCI_WRITE_END_PADDING = Culonglong(1) << 36

const ETHERNET_LL_SIZE = ETH_ALEN

# Skipping MacroDefinition: IBV_ALLOCATOR_USE_DEFAULT ( ( void * ) - 1 )

const IB_ROCE_UDP_ENCAP_VALID_PORT_MIN = 0xc000

const IB_ROCE_UDP_ENCAP_VALID_PORT_MAX = 0xffff

const IB_GRH_FLOWLABEL_MASK = 0x000fffff

# ibv_query port

export ibv_query_port

function ibv_query_port(context, port_num, port_attr)
    ccall((:ibv_query_port, libibverbs), Cint, (Ptr{ibv_context}, UInt8, Ptr{ibv_port_attr}), context, port_num, port_attr)
end


# exports
const PREFIXES = ["IBV", "ibv_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
