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
    dmac::NTuple{6, UInt8}=(0x00, 0x00, 0x00, 0x00, 0x00, 0x00),
    smac::NTuple{6, UInt8}=(0x00, 0x00, 0x00, 0x00, 0x00, 0x00),
    ethtype=0, vlan=0,
    sip=0, dip=0,
    dport=0, sport=0, tcpudp=:udp
)
    # Convert/sanity check flow_type
    flow_attr = flow_type == :normal  ? IBV_FLOW_ATTR_NORMAL      :
                flow_type == :all     ? IBV_FLOW_ATTR_ALL_DEFAULT :
                flow_type == :mc      ? IBV_FLOW_ATTR_MC_DEFAULT  :
                flow_type == :sniffer ? IBV_FLOW_ATTR_SNIFFER     :
                error("invalid flow_type $flow_type")

    # Convert/sanity check tcpudp
    tcp_udp_flow_type = tcpudp == :tcp ? IBV_FLOW_SPEC_TCP :
                        tcpudp == :udp ? IBV_FLOW_SPEC_UDP :
                        error("invalid tcpudp $tcpudp")

    # May be overridden below
    num_specs = 0
    rule_size = sizeof(ibv_flow_attr)

    dmac_mask = get_mask(dmac)
    smac_mask = get_mask(smac)
    ethtype_mask = get_mask(UInt16, ethtype)
    vlan_mask = get_mask(UInt16, vlan)
    sip_mask = get_mask(UInt32, sip)
    dip_mask = get_mask(UInt32, dip)
    dport_mask = get_mask(UInt16, dport)
    sport_mask = get_mask(UInt16, sport)

    if dmac !== (0x00, 0x00, 0x00, 0x00, 0x00, 0x00) ||
            smac !== (0x00, 0x00, 0x00, 0x00, 0x00, 0x00) ||
            ethtype != 0
            vlan != 0
        # May be overridden below
        num_specs = 1
        rule_size = sizeof(ibv_flow_attr) +
            sizeof(ibv_flow_spec_eth)
    end

    if sip != 0 || dip != 0
        # May be overridden below
        num_specs = 2
        rule_size = sizeof(ibv_flow_attr) +
            sizeof(ibv_flow_spec_eth) +
            sizeof(ibv_flow_spec_ipv4)
    end

    if dport != 0 || sport != 0
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
                dmac, smac, htobe16(ethtype), htobe16(vlan)
            ),
            ibv_flow_eth_filter(
                dmac_mask, smac_mask, ethtype_mask, vlan_mask
            )
        ),
        ibv_flow_spec_ipv4(
            IBV_FLOW_SPEC_IPV4,
            sizeof(ibv_flow_spec_ipv4),
            ibv_flow_ipv4_filter(htobe32(sip), htobe32(dip)),
            ibv_flow_ipv4_filter(sip_mask, dip_mask)
        ),
        ibv_flow_spec_tcp_udp(
            tcp_udp_flow_type,
            sizeof(ibv_flow_spec_tcp_udp),
            ibv_flow_tcp_udp_filter(htobe16(dport), htobe16(sport)),
            ibv_flow_tcp_udp_filter(dport_mask, sport_mask)
        )
    )
end

"""
    create_flow(qp, port_num; <kwargs>) -> Ptr{ibv_flow}
    create_flow(ctx::Context; <kwargs>) -> Ptr{ibv_flow}

Create a flow rule to specify which packets to receive.

The flow rule will be created for queue pair `qp`, port number `port_num` (or
`ctx.qp` and `ctx.port_num`).

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
    - `dmac::NTuple{6, UInt8}`: destination MAC address to match
    - `smac::NTuple{6, UInt8}`: source MAC address to match
    - `ethtype`: EtherType value to match (e.g. `0x0800` for IPv4 packets)
    - `vlan`: VLAN tag to match
  - IPv4 layer selectors (can be `UInt32` or `IPv4`)
    - `sip` source IPv4 address (e.g. `0x0a000123` or `ip"10.0.1.35"`)
    - `dip` destination IPv4 address
  - TCP/UDP layer selectors
    - `dport`: destination TCP/UDP port to match
    - `sport`: source TCP/UDP port to match
    - `tcpudp`: one of `:udp` (default) or `:tcp`.  Specifies whether
      `sport`/`dport` are UDP or TCP ports.  You must pass a non-zero `dport`
      and/or `sport` to match UDP or TCP packets specifically.  Matching all UDP
      and/or all TCP packets is not (yet) supported.
"""
function create_flow(qp, port_num;
    flow_type=:normal, priority=0, flags=0,
    dmac::NTuple{6, UInt8}=(0x00, 0x00, 0x00, 0x00, 0x00, 0x00),
    smac::NTuple{6, UInt8}=(0x00, 0x00, 0x00, 0x00, 0x00, 0x00),
    ethtype=0, vlan=0,
    sip=0, dip=0,
    dport=0, sport=0, tcpudp=:udp
)
    flow_rule = Ref(FlowRule(port_num;
        flow_type, priority, flags,
        dmac, smac, ethtype, vlan,
        sip, dip,
        dport, sport, tcpudp
    ))

    flow_rule_ptr = Ptr{ibv_flow_attr}(pointer_from_objref(flow_rule))
    @GC.preserve flow_rule ibv_create_flow(qp, flow_rule_ptr)
end

function create_flow(ctx;
    flow_type=:normal, priority=0, flags=0,
    dmac::NTuple{6, UInt8}=(0x00, 0x00, 0x00, 0x00, 0x00, 0x00),
    smac::NTuple{6, UInt8}=(0x00, 0x00, 0x00, 0x00, 0x00, 0x00),
    ethtype=0, vlan=0,
    sip=0, dip=0,
    dport=0, sport=0, tcpudp=:udp
)
    create_flow(ctx.qp, ctx.port_num;
        flow_type, priority, flags,
        dmac,
        smac,
        ethtype, vlan,
        sip, dip,
        dport, sport, tcpudp
    )
end

"""
    destroy_flow(flow) -> nothing

Destroy `flow` that was created by `create_flow`.  Packets specified by `flow`
will no longer be received from the flow's device and port.
"""
function destroy_flow(flow)
    errno = ibv_destroy_flow(flow)
    errno == 0 || throw(SystemError("ibv_destroy_flow", errno))
    nothing
end
