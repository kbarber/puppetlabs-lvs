Puppet::Type.type(:keepalived_vrrp_sync_group).provide(:augeas) do
  desc "Augeas based provider for managing vrrp_sync_group entries in keepalived.conf"

  require 'puppet/util/keepalived'

  defaultfor :kernel => 'Linux'

  def create
    groups = Puppet::Util::Keepalived::VrrpSyncGroup.new

    options = {
      "group" => resource[:group].to_s,
    }
    groups.create(resource[:name].to_s, options)
  end

  def destroy
    groups = Puppet::Util::Keepalived::VrrpSyncGroup.new
    groups.delete(resource[:name].to_s)
  end

  def exists?
    groups = Puppet::Util::Keepalived::VrrpSyncGroup.new
    groups[resource[:name].to_s] ? true : false
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
  def group 
    groups = Puppet::Util::Keepalived::VrrpSyncGroup.new
    groups[resource[:name].to_s][:group]
  end

  def group=(val)
    groups = Puppet::Util::Keepalived::VrrpSyncGroup.new
    groups.set(resource[:name].to_s, "group", val)
  end

  def notify_master
  end
  def notify_master=(val)
  end

  def notify_backup
  end
  def notify_backup=(val)
  end

  def notify_fault
  end
  def notify_fault=(val)
  end

  def notify_all
  end
  def notify_all=(val)
  end

  def smtp_alert
  end
  def smtp_alert=(val)
  end
end
