struct FlowRule
    attr::ibv_flow_attr
    spec_eth::ibv_flow_spec_eth
    spec_ipv4::ibv_flow_spec_ipv4
    spec_tcp_udp::ibv_flow_spec_tcp_udp
end

function get_mask(val::NTuple{6, UInt8})
    val === (0x00, 0x00, 0x00, 0x00, 0x00, 0x00) ? val : (0xff, 0xff, 0xff, 0xff, 0xff, 0xff)
end

function get_mask(::Type{T}, val) where T<:Unsigned
    T(val) === zero(T) ? zero(T) : typemax(T)
end

function FlowRule(port_num;
    flow_type=:normal, priority=0, flags=0,
    dst_mac::NTuple{6, UInt8}=(0x00, 0x00, 0x00, 0x00, 0x00, 0x00),
    src_mac::NTuple{6, UInt8}=(0x00, 0x00, 0x00, 0x00, 0x00, 0x00),
    ether_type=0, vlan_tag=0,
    src_ip=0, dst_ip=0,
    dst_port=0, src_port=0, tcp_udp_type=:udp
)
    # Convert/sanity check flow_type
    flow_attr = flow_type == :normal  ? IBV_FLOW_ATTR_NORMAL      :
                flow_type == :all     ? IBV_FLOW_ATTR_ALL_DEFAULT :
                flow_type == :mc      ? IBV_FLOW_ATTR_MC_DEFAULT  :
                flow_type == :sniffer ? IBV_FLOW_ATTR_SNIFFER     :
                error("invalid flow_type $flow_type")

    # Convert/sanity check tcp_udp_type
    tcp_udp_flow_type = tcp_udp_type == :tcp ? IBV_FLOW_SPEC_TCP :
                        tcp_udp_type == :udp ? IBV_FLOW_SPEC_UDP :
                        error("invalid tcp_udp_type $tcp_udp_type")

    # May be overridden below
    num_specs = 0
    rule_size = sizeof(ibv_flow_attr)

    dst_mac_mask = get_mask(dst_mac)
    src_mac_mask = get_mask(src_mac)
    ether_type_mask = get_mask(UInt16, ether_type)
    vlan_tag_mask = get_mask(UInt16, vlan_tag)
    src_ip_mask = get_mask(UInt32, src_ip)
    dst_ip_mask = get_mask(UInt32, dst_ip)
    dst_port_mask = get_mask(UInt16, dst_port)
    src_port_mask = get_mask(UInt16, src_port)

    if dst_mac !== (0x00, 0x00, 0x00, 0x00, 0x00, 0x00) ||
            src_mac !== (0x00, 0x00, 0x00, 0x00, 0x00, 0x00) ||
            ether_type != 0
            vlan_tag != 0
        # May be overridden below
        num_specs = 1
        rule_size = sizeof(ibv_flow_attr) +
            sizeof(ibv_flow_spec_eth)
    end

    if src_ip != 0 || dst_ip != 0
        # May be overridden below
        num_specs = 2
        rule_size = sizeof(ibv_flow_attr) +
            sizeof(ibv_flow_spec_eth) +
            sizeof(ibv_flow_spec_ipv4)
    end

    if dst_port != 0 || src_port != 0
        # May be overridden below
        num_specs = 3
        rule_size = sizeof(ibv_flow_attr) +
            sizeof(ibv_flow_spec_eth) +
            sizeof(ibv_flow_spec_ipv4) +
            sizeof(ibv_flow_spec_tcp_udp)
    end

    FlowRule(
        ibv_flow_attr(
            0,         # comp_mask::UInt32
            flow_attr, # type::ibv_flow_attr_type
            rule_size, # size, size::UInt16
            priority,  # priority::UInt16
            num_specs, # num_of_specs::UInt8
            port_num,  # port::UInt8
            flags      # flags::UInt32
        ),
        ibv_flow_spec_eth(
            IBV_FLOW_SPEC_ETH,
            sizeof(ibv_flow_spec_eth),
            ibv_flow_eth_filter(
                dst_mac, src_mac, htobe16(ether_type), htobe16(vlan_tag)
            ),
            ibv_flow_eth_filter(
                dst_mac_mask, src_mac_mask, ether_type_mask, vlan_tag_mask
            )
        ),
        ibv_flow_spec_ipv4(
            IBV_FLOW_SPEC_IPV4,
            sizeof(ibv_flow_spec_ipv4),
            ibv_flow_ipv4_filter(htobe32(src_ip), htobe32(dst_ip)),
            ibv_flow_ipv4_filter(src_ip_mask, dst_ip_mask)
        ),
        ibv_flow_spec_tcp_udp(
            tcp_udp_flow_type,
            sizeof(ibv_flow_spec_tcp_udp),
            ibv_flow_tcp_udp_filter(htobe16(dst_port), htobe16(src_port)),
            ibv_flow_tcp_udp_filter(dst_port_mask, src_port_mask)
        )
    )
end

"""
    create_flow(qp, port_num; <kwargs>) -> Ptr{ibv_flow}

Create a flow rule to select which packets to receive from queue pair `qp`, port
number `port_num`.

Various attributes and selectors of the flow rule can be specified by keyword
arguments as described in the extended help.  The returned `Ptr{ibv_flow}` can
be passed to `ibv_destroy_flow` to remove the flow rule.

# Extended help

## Attributes
These keyword arguments set general attributes of the flow rule.  See the Linux
manual page for `ibv_create_flow` for more details.
- General flow rule attributes:
  - `flow_type` one of `:normal` (default), `:all`, `:mc`, or `:sniffer`
  - `priority` defaults to 0
  - `flags` defaults to 0
## Selectors
Keyword arguments that are unspecified (or zero) are not used for matching.
Integer values will be converted to network byte order as necessary.
  - Ethernet layer selectors
    - `dst_mac::NTuple{6, UInt8}`: destination MAC address to match
    - `src_mac::NTuple{6, UInt8}`: source MAC address to match
    - `ether_type`: EtherType value to match (e.g. `0x0800` for IPv4 packets)
    - `vlan_tag`: VLAN tag to match
  - IPv4 layer selectors (can be `UInt32` or `IPv4`)
    - `src_ip` source IPv4 address (e.g. `0x0a000123` for `10.0.1.35`)
    - `dst_ip` destination IPv4 address
  - TCP/UDP layer selectors
    - `dst_port`: destination TCP/UDP port to match
    - `src_port`: source TCP/UDP port to match
    - `tcp_udp_type`: one of `:udp` (default) or `:tcp`.  Specifies whether
      `src_port`/`dst_port` are UDP or TCP ports.  You must pass a non-zero
      `dst_port` and/or `src_port` to match UDP or TCP packets specifically.
      Matching all UDP and/or all TCP packets is not (yet) supported.
"""
function create_flow(qp, port_num;
    flow_type=:normal, priority=0, flags=0,
    dst_mac::NTuple{6, UInt8}=(0x00, 0x00, 0x00, 0x00, 0x00, 0x00),
    src_mac::NTuple{6, UInt8}=(0x00, 0x00, 0x00, 0x00, 0x00, 0x00),
    ether_type=0, vlan_tag=0,
    src_ip=0, dst_ip=0,
    dst_port=0, src_port=0, tcp_udp_type=:udp
)
    flow_rule = Ref(FlowRule(port_num;
        flow_type, priority, flags,
        dst_mac, src_mac, ether_type, vlan_tag,
        src_ip, dst_ip,
        dst_port, src_port, tcp_udp_type
    ))

    flow_rule_ptr = Ptr{ibv_flow_attr}(pointer_from_objref(flow_rule))
    @GC.preserve flow_rule ibv_create_flow(qp, flow_rule_ptr)
end
