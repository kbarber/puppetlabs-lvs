Puppet::Type.type(:keepalived_global_defs).provide(:augeas) do
  desc "Augeas based provider for managing global_defs"

  require 'puppet/util/keepalived'

  defaultfor :kernel => 'Linux'

  def create
    Puppet::Util::Keepalived.set_global_defs(resource[:name],resource[:value])
  end

  def destroy
    Puppet::Util::Keepalived.rm_global_def(resource[:name])
  end

  def exists?
    defs = Puppet::Util::Keepalived.get_global_defs
    defs.has_key?(resource[:name])
  end

  def self.instances
    instances = []

    defs = Puppet::Util::Keepalived.get_global_defs

    defs.each do |key,value|
      hash = {}
      hash[:provider] = self.name.to_s
      hash[:name] = key
      hash[:value] = value
      instances << new(hash)
    end
    
    instances
  end

  # Properties
  def value
    defs = Puppet::Util::Keepalived.get_global_defs
    defs[resource[:name]]
  end

  def value=(val)
    Puppet::Util::Keepalived.set_global_defs(resource[:name],val)
  end
end
