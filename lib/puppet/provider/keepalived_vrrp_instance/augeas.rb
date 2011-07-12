Puppet::Type.type(:keepalived_vrrp_instance).provide(:augeas) do
  desc "Augeas based provider for managing vrrp_instance"

  require 'puppet/util/keepalived'

  defaultfor :kernel => 'Linux'

  def create
    inst = Puppet::Util::Keepalived::VrrpInstance.new
    options = {
      "priority" => resource[:priority],
      "virtual_router_id" => resource[:virtual_router_id],
      "interface" => resource[:interface],
      "virtual_ipaddress" => resource[:virtual_ipaddress],
      "lvs_sync_daemon_interface" => resource[:lvs_sync_daemon_interface],
    }
    inst.create(resource[:name], options)
  end

  def destroy
    inst = Puppet::Util::Keepalived::VrrpInstance.new
    inst.delete(resource[:name])
  end

  def exists?
    inst = Puppet::Util::Keepalived::VrrpInstance.new
    inst[resource[:name]] ? true : false
  end

  def self.instances
    instances = []

    inst = Puppet::Util::Keepalived::VrrpInstance.new

    inst.each do |key,value|
      hash = {
        :provider => self.name.to_s,
        :name => key,
        :lvs_sync_daemon_interface => value[:lvs_sync_daemon_interface],
      }
      instances << new(hash)
    end
    
    instances
  end

  # Properties
  def priority
    inst = Puppet::Util::Keepalived::VrrpInstance.new
    inst[resource[:name]][:priority]
  end

  def priority=(val)
    inst = Puppet::Util::Keepalived::VrrpInstance.new
    inst.set(resource[:name],"priority",val)
  end

  def virtual_router_id
    inst = Puppet::Util::Keepalived::VrrpInstance.new
    inst[resource[:name]][:virtual_router_id]
  end

  def virtual_router_id=(val)
    inst = Puppet::Util::Keepalived::VrrpInstance.new
    inst.set(resource[:name],"virtual_router_id",val)
  end

  def interface
    inst = Puppet::Util::Keepalived::VrrpInstance.new
    inst[resource[:name]][:interface]
  end

  def interface=(val)
    inst = Puppet::Util::Keepalived::VrrpInstance.new
    inst.set(resource[:name],"interface",val)
  end

  def virtual_ipaddress
    inst = Puppet::Util::Keepalived::VrrpInstance.new
    inst[resource[:name]][:virtual_ipaddress]
  end

  def virtual_ipaddress=(val)
    inst = Puppet::Util::Keepalived::VrrpInstance.new
    inst.set(resource[:name],"virtual_ipaddress",val)
  end

  def lvs_sync_daemon_interface
    inst = Puppet::Util::Keepalived::VrrpInstance.new
    inst[resource[:name]][:lvs_sync_daemon_interface]
  end

  def lvs_sync_daemon_interface=(val)
    inst = Puppet::Util::Keepalived::VrrpInstance.new
    inst.set(resource[:name],"lvs_sync_daemon_interface",val)
  end

  def state
    inst = Puppet::Util::Keepalived::VrrpInstance.new
    inst[resource[:name]][:state]
  end

  def state=(val)
    inst = Puppet::Util::Keepalived::VrrpInstance.new
    inst.set(resource[:name],"state",val)
  end

  def dont_track_primary
  end
  def dont_track_primary=(val)
  end

  def track_interface
  end
  def track_interface=(val)
  end

  def mcast_src_ip
  end
  def mcast_src_ip=(val)
  end

  def garp_master_delay
  end
  def garp_master_delay=(val)
  end

  def advert_int
  end
  def advert_int=(val)
  end

  def auth_type
  end
  def auth_type=(val)
  end

  def auth_pass
  end
  def auth_pass=(val)
  end

  def virtual_ipaddress_excluded
  end
  def virtual_ipaddress_excluded=(val)
  end

  def virtual_routes
  end
  def virtual_routes=(val)
  end

  def nopreempt
  end
  def nopreempt=(val)
  end 

  def preempt_delay
  end
  def preempt_delay=(val)
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

end
