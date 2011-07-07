Puppet::Type.type(:keepalived_vrrp_sync_group).provide(:augeas) do
  desc "Augeas based provider for managing vrrp_sync_group entries in keepalived.conf"

  require 'puppet/util/keepalived'

  defaultfor :kernel => 'Linux'

  def create
    groups = Puppet::Util::Keepalived::VrrpSyncGroup.new

    options = {
      "groups" => resource[:groups],
    }
    groups.create(resource[:name], options)
  end

  def destroy
    groups = Puppet::Util::Keepalived::VrrpSyncGroup.new
    groups.delete(resource[:name])
  end

  def exists?
    groups = Puppet::Util::Keepalived::VrrpSyncGroup.new
    groups[resource[:name]] ? true : false
  end

  def self.instances
    instances = []

    groups = Puppet::Util::Keepalived::VrrpSyncGroup.new

    groups.each do |key,value|
      hash = {
        :provider => self.name.to_s,
        :name => key,
      }
      instances << new(hash)
    end

    instances
  end

  # Properties
  def groups 
    groups = Puppet::Util::Keepalived::VrrpSyncGroup.new
    groups[resource[:name]][:groups]
  end

  def groups=(val)
    groups = Puppet::Util::Keepalived::VrrpSyncGroup.new
    groups.set(resource[:name], "groups", val)
  end

end
