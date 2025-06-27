using InfinibandVerbs.API

function print_ibv_devices(io=stdout)
    num_devices = Ref{Cint}(0)

    dev_list = ibv_get_device_list(num_devices)
    if dev_list == C_NULL
        error("Failed to get IB devices list")
    end

    println(io, "    ", rpad("device", 16), "\t   node GUID")
    println(io, "    ", rpad("------", 16), "\t----------------")
  
    for i = 1:num_devices[]
        dev = unsafe_load(dev_list, i)
        name = ibv_get_device_name(dev)|>unsafe_string
        guid = ibv_get_device_guid(dev)

        println(io, "    ",
            rpad(name, 16), "\t",
            string(ntoh(guid), base=16, pad=16)
        )
    end
  
    ibv_free_device_list(dev_list)
end

print_ibv_devices()
