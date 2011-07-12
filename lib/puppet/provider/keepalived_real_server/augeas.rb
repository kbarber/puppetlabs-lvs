Puppet::Type.type(:keepalived_real_server).provide(:augeas) do
  desc "Augeas based provider for managing real_server"

  require 'puppet/util/keepalived'

  defaultfor :kernel => 'Linux'

  def create
    inst = Puppet::Util::Keepalived::RealServer.new
    options = {}
    resource.eachproperty do |prop|
      next if prop == "ensure"
      options[prop.to_s] = prop.value if prop.value
    end
    inst.create(resource[:name].to_s, options)
  end

  def destroy
    inst = Puppet::Util::Keepalived::RealServer.new
    inst.delete(resource[:name])
  end

  def exists?
    inst = Puppet::Util::Keepalived::RealServer.new
    inst[resource[:name]] ? true : false
  end

  def self.instances
    instances = []

    inst = Puppet::Util::Keepalived::RealServer.new

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
  def weight
    inst = Puppet::Util::Keepalived::RealServer.new
    inst[resource[:name]][:weight]
  end

  def weight=(val)
    inst = Puppet::Util::Keepalived::RealServer.new
    inst.set(resource[:name],"weight",val)
  end

  def healthcheck
    inst = Puppet::Util::Keepalived::RealServer.new
    inst[resource[:name]][:healthcheck]
  end

  def healthcheck=(val)
    inst = Puppet::Util::Keepalived::RealServer.new
    inst.set(resource[:name],"healthcheck",val)
  end

  def url
    inst = Puppet::Util::Keepalived::RealServer.new
    inst[resource[:name]][:url]
  end

  def url=(val)
    inst = Puppet::Util::Keepalived::RealServer.new
    inst.set(resource[:name],"url",val)
  end

  def connect_port
    inst = Puppet::Util::Keepalived::RealServer.new
    inst[resource[:name]][:connect_port]
  end

  def connect_port=(val)
    inst = Puppet::Util::Keepalived::RealServer.new
    inst.set(resource[:name],"connect_port",val)
  end

  def bindto
    inst = Puppet::Util::Keepalived::RealServer.new
    inst[resource[:name]][:bindto]
  end

  def bindto=(val)
    inst = Puppet::Util::Keepalived::RealServer.new
    inst.set(resource[:name],"bindto",val)
  end

  def connect_timeout
    inst = Puppet::Util::Keepalived::RealServer.new
    inst[resource[:name]][:connect_timeout]
  end

  def connect_timeout=(val)
    inst = Puppet::Util::Keepalived::RealServer.new
    inst.set(resource[:name],"connect_timeout",val)
  end

  def nb_get_retry
    inst = Puppet::Util::Keepalived::RealServer.new
    inst[resource[:name]][:nb_get_retry]
  end

  def nb_get_retry=(val)
    inst = Puppet::Util::Keepalived::RealServer.new
    inst.set(resource[:name],"nb_get_retry",val)
  end

  def delay_before_retry
    inst = Puppet::Util::Keepalived::RealServer.new
    inst[resource[:name]][:delay_before_retry]
  end

  def delay_before_retry=(val)
    inst = Puppet::Util::Keepalived::RealServer.new
    inst.set(resource[:name],"delay_before_retry",val)
  end

  def retry
    inst = Puppet::Util::Keepalived::RealServer.new
    inst[resource[:name]][:retry]
  end

  def retry=(val)
    inst = Puppet::Util::Keepalived::RealServer.new
    inst.set(resource[:name],"retry",val)
  end

  def helo_name
    inst = Puppet::Util::Keepalived::RealServer.new
    inst[resource[:name]][:helo_name]
  end

  def helo_name=(val)
    inst = Puppet::Util::Keepalived::RealServer.new
    inst.set(resource[:name],"helo_name",val)
  end

  def misc_path
    inst = Puppet::Util::Keepalived::RealServer.new
    inst[resource[:name]][:misc_path]
  end

  def misc_path=(val)
    inst = Puppet::Util::Keepalived::RealServer.new
    inst.set(resource[:name],"misc_path",val)
  end

  def misc_timeout
    inst = Puppet::Util::Keepalived::RealServer.new
    inst[resource[:name]][:misc_timeout]
  end

  def misc_timeout=(val)
    inst = Puppet::Util::Keepalived::RealServer.new
    inst.set(resource[:name],"misc_timeout",val)
  end

  def misc_dynamic
    inst = Puppet::Util::Keepalived::RealServer.new
    inst[resource[:name]][:misc_dynamic]
  end

  def misc_dynamic=(val)
    inst = Puppet::Util::Keepalived::RealServer.new
    inst.set(resource[:name],"misc_dynamic",val)
  end

  def notify_down
    inst = Puppet::Util::Keepalived::RealServer.new
    inst[resource[:name]][:notify_down]
  end

  def notify_down=(val)
    inst = Puppet::Util::Keepalived::RealServer.new
    inst.set(resource[:name],"notify_down",val)
  end

  def notify_up
    inst = Puppet::Util::Keepalived::RealServer.new
    inst[resource[:name]][:notify_up]
  end

  def notify_up=(val)
    inst = Puppet::Util::Keepalived::RealServer.new
    inst.set(resource[:name],"notify_up",val)
  end

  def notify_all
    inst = Puppet::Util::Keepalived::RealServer.new
    inst[resource[:name]][:notify]
  end

  def notify_all=(val)
    inst = Puppet::Util::Keepalived::RealServer.new
    inst.set(resource[:name],"notify",val)
  end

  def inhibit_on_failure
  end
  def inhibit_on_failure=(val)
  end

end
