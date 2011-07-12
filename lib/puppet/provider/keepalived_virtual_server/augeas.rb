Puppet::Type.type(:keepalived_virtual_server).provide(:augeas) do
  desc "Augeas based provider for managing virtual_server"

  require 'puppet/util/keepalived'

  defaultfor :kernel => 'Linux'

  def create
    inst = Puppet::Util::Keepalived::VirtualServer.new
    options = {
      "delay_loop" => resource[:delay_loop],
      "lb_algo" => resource[:lb_algo],
      "lb_kind" => resource[:lb_kind],
      "persistence_timeout" => resource[:persistence_timeout],
    }
    inst.create(resource[:name], options)
  end

  def destroy
    inst = Puppet::Util::Keepalived::VirtualServer.new
    inst.delete(resource[:name])
  end

  def exists?
    inst = Puppet::Util::Keepalived::VirtualServer.new
    inst[resource[:name]] ? true : false
  end

  def self.instances
    instances = []

    inst = Puppet::Util::Keepalived::VirtualServer.new

    inst.each do |key,value|
      hash = {
        :provider => self.name.to_s,
        :name => key,
      }
      instances << new(hash)
    end
    
    instances
  end

  # Properties
  def delay_loop
    inst = Puppet::Util::Keepalived::VirtualServer.new
    inst[resource[:name]][:delay_loop]
  end

  def delay_loop=(val)
    inst = Puppet::Util::Keepalived::VirtualServer.new
    inst.set(resource[:name],"delay_loop",val)
  end

  def lb_algo
    inst = Puppet::Util::Keepalived::VirtualServer.new
    inst[resource[:name]][:lb_algo]
  end

  def lb_algo=(val)
    inst = Puppet::Util::Keepalived::VirtualServer.new
    inst.set(resource[:name],"lb_algo",val)
  end

  def lb_kind
    inst = Puppet::Util::Keepalived::VirtualServer.new
    inst[resource[:name]][:lb_kind]
  end

  def lb_kind=(val)
    inst = Puppet::Util::Keepalived::VirtualServer.new
    inst.set(resource[:name],"lb_kind",val)
  end

  def persistence_timeout
    inst = Puppet::Util::Keepalived::VirtualServer.new
    inst[resource[:name]][:persistence_timeout]
  end

  def persistence_timeout=(val)
    inst = Puppet::Util::Keepalived::VirtualServer.new
    inst.set(resource[:name],"persistence_timeout",val)
  end

  def virtualhost
  end
  def virtualhost=(val)
  end

  def sorry_server
  end
  def sorry_server=(val)
  end

  def quorum_up
  end
  def quorum_up=(val)
  end

  def quorum_down
  end
  def quorum_down=(val)
  end

  def quorum
  end
  def quorum=(val)
  end

  def protocol
  end
  def protocol=(val)
  end

  def persistence_granularity
  end
  def persistence_granularity=(val)
  end

  def hysteresis
  end
  def hysteresis=(val)
  end

  def alpha
  end
  def alpha=(val)
  end

  def omega
  end
  def omega=(val)
  end

  def ha_suspend
  end
  def ha_suspend=(val)
  end
end
