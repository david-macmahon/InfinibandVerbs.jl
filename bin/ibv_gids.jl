using InfinibandVerbs.API

function print_ibv_gids(io=stdout)
    # Get device list
    num_devices = Ref{Cint}(0)
    dev_list = ibv_get_device_list(num_devices)
    if dev_list == C_NULL
        error("failed to get IB devices list")
    end

    try
        if num_devices[] == 0
            @warn "no devices found"
        end

        # For each device
        for i = 1:num_devices[]
            # Load device
            dev = unsafe_load(dev_list, i)
            if dev == C_NULL
                @error "unexpected NULL pointer for device $i"
                continue
            end
            devname = ibv_get_device_name(dev)|>unsafe_string
            println(io, "$(devname):")

            # Open device
            ctx = ibv_open_device(dev)
            if ctx == C_NULL
                @error "opening device unsafe_string() NULL pointer for device $i"
                continue
            end

            # Query device
            dattr = Ref{ibv_device_attr}()
            if ibv_query_device(ctx, dattr) != 0
                @error "error querying device $devname"
                ibv_close_device(ctx)
                continue
            end

            # For each port of device (NB: pidx is 1-based)
            for pidx = 1:dattr[].phys_port_cnt
                # Query port
                pattr = Ref{ibv_port_attr}()
                if ibv_query_port(ctx, pidx, pattr) != 0
                    @error "error querying device $devname port $pidx"
                    continue
                end
                println(io, "    port $pidx:")

                # For each GID of port (NB: gidx is 0-based)
                for gidx = 0:pattr[].gid_tbl_len-1
                    # Query GID
                    gid = Ref{ibv_gid}()
                    if ibv_query_gid(ctx, pidx, gidx, gid) != 0
                        @error "error querying device $devname port $pidx gid $gidx"
                        continue
                    end

                    if gid[].subnet_prefix == 0 && gid[].interface_id == 0
                        continue
                    end

                    print(io, "        gid $(lpad(gidx, 3)): ")
                    print(io, "$(string(gid[].subnet_prefix, base=16, pad=16)):")
                    println(io, "$(string(gid[].interface_id, base=16, pad=16))")
                end # foreach gid
            end # foreach port
        end # foreach device
    finally
        ibv_free_device_list(dev_list)
    end
end

print_ibv_gids()
