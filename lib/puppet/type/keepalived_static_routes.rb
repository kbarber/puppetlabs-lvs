Puppet::Type.newtype(:keepalived_static_routes) do
  @doc = "Type for managing static_routes entries for keepalived"

  require 'ipaddr'

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto :present
  end

  newparam(:name) do
    desc "Name of static_routes option in the form src|destination"

    isnamevar

    validate do |value|
      raise ArgumentError, "Invalid name #{value.inspect} must be of the form 'srcip/prefix|dstip/prefix'." unless value =~ /\|/
      src, dest = value.split("|")
      
      raise ArgumentError, "Invalid name #{value.inspect} must be of the form 'srcip/prefix|dstip/prefix'." unless src =~ /\// or dst =~ /\//

      srcip, srcprefix = src.split("/")
      dstip, dstprefix = src.split("/")

      srcip_obj = IPAddr.new(srcip)
      raise ArgumentError, "Invalid source ip #{srcip.inspect} must be an ipv4 or ipv6 address." unless srcip_obj.ipv4? or srcip_obj.ipv6?

      dstip_obj = IPAddr.new(dstip)
      raise ArgumentError, "Invalid destination ip #{srcip.inspect} must be an ipv4 or ipv6 address." unless dstip_obj.ipv4? or dstip_obj.ipv6?
    end
  end

  newproperty(:dev) do
    desc "The device to route to"

    validate do |value|
      raise ArgumentError, "Device #{value.inspect} cannot accept space" if value =~ /\s/
    end
  end

  newproperty(:via) do
    desc "The IP address to route to"

    defaultto "0.0.0.0"

    validate do |value|
      ip = IPAddr.new(value)
      raise ArgumentError, "Invalid via #{value.inspect} must be an ipv4 or ipv6 address." unless ip.ipv4? or ip.ipv6?
    end
  end

end
