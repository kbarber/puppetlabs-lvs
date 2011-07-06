Puppet::Type.type(:keepalived_static_routes).provide(:augeas) do
  desc "Augeas based provider for managing static_routes entries in keepalived.conf"

  require 'puppet/util/keepalived/static_routes'

  defaultfor :kernel => 'Linux'

  def create
    routes = Puppet::Util::Keepalived::StaticRoutes.new
    routes.create(resource[:name], resource[:dev], resource[:via] ? resource[:via] : "0.0.0.0")
  end

  def destroy
    routes = Puppet::Util::Keepalived::StaticRoutes.new
    routes.delete(resource[:name])
  end

  def exists?
    routes = Puppet::Util::Keepalived::StaticRoutes.new
    routes[resource[:name]] ? true : false
  end

  def self.instances
    instances = []

    routes = Puppet::Util::Keepalived::StaticRoutes.new

    routes.each do |key,value|
      hash = {}
      hash[:provider] = self.name.to_s
      hash[:name] = key
      hash[:via] = value[:via]
      hash[:dev] = value[:dev]
      instances << new(hash)
    end

    instances
  end

  # Properties
  def dev
    routes = Puppet::Util::Keepalived::StaticRoutes.new
    routes[resource[:name]][:dev]
  end

  def dev=(val)
    routes = Puppet::Util::Keepalived::StaticRoutes.new
    routes.set(resource[:name], "dev", val)
  end

  def via
    routes = Puppet::Util::Keepalived::StaticRoutes.new
    routes[resource[:name]][:via]
  end

  def via=(val)
    routes = Puppet::Util::Keepalived::StaticRoutes.new
    routes.set(resource[:name], "via", val)
  end

end
