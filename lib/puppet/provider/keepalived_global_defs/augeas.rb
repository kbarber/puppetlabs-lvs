Puppet::Type.type(:keepalived_global_defs).provide(:augeas) do
  desc "Augeas based provider for managing global_defs"

  require 'puppet/util/keepalived'

  defaultfor :kernel => 'Linux'

  def create
    defs = Puppet::Util::Keepalived::GlobalDefs.new
    defs.set(resource[:name].to_s, resource[:value].to_s)
  end

  def destroy
    defs = Puppet::Util::Keepalived::GlobalDefs.new
    defs.delete(resource[:name].to_s)
  end

  def exists?
    defs = Puppet::Util::Keepalived::GlobalDefs.new
    defs[resource[:name].to_s] ? true : false
  end

  def self.instances
    instances = []

    defs = Puppet::Util::Keepalived::GlobalDefs.new

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
    defs = Puppet::Util::Keepalived::GlobalDefs.new
    defs[resource[:name].to_s]
  end

  def value=(val)
    defs = Puppet::Util::Keepalived::GlobalDefs.new
    defs.set(resource[:name].to_s, val)
  end
end
