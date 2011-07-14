require 'puppet/property/list'
require 'puppet/property/ordered_list'
require 'puppet/property/keyvalue'

Puppet::Type.newtype(:keepalived_real_server) do
  @doc = "Type for managing real_server entries for keepalived"

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
    desc "Name of real_server"

    isnamevar
  end

  newproperty(:weight) do
    desc "weight"

    validate do |value|
      raise ArgumentError, "Invalid weight #{value.inspect} must be a number." unless /^\d+$/.match(value)
    end
  end

  newproperty(:healthcheck) do
    desc "healthcheck hash"

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end

  newproperty(:notify_down) do
  end
 
  newproperty(:notify_up) do
  end

  newproperty(:inhibit_on_failure, :boolean => true) do
    newvalues(:true,:false)
  end

  autorequire(:keepalived_virtual_server) do
    name = @parameters[:name].value
    name.split("/")[0]
  end

end
