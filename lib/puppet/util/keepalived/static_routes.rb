require 'augeas'
require 'puppet/util/keepalived'

module Puppet::Util::Keepalived 

  class StaticRoutes < Common

    def initialize(lenses = "/var/lib/puppet/modules/lvs/augeas_lenses", 
      root = "/")
      @aug = augload(lenses,root)
    end

    def set(srcto, param, value)
      rootpath = self[srcto][:path]
      path = ""
      case param
      when "dev"
        path += rootpath + "/dev"
      when "via"
        path += rootpath + "/via/ipaddr"
      end

      augsave do |aug|
        aug.set(path, value)
      end
    end

    def create(name, dev, via)
      src, to = name.split("|") 
      src, src_prefix = src.split("/")
      to, to_prefix = to.split("/")

      if to_prefix == nil then
        to_prefix = 32
      end

      if src_prefix == nil then
        src_prefix = 32
      end

      augsave do |aug|
        aug.defnode("srpath", "$root/static_routes/route[last()+1]", nil)
        aug.set("$srpath/src/ipaddr", src)
        aug.set("$srpath/src/ipaddr/prefixlen", src_prefix)
        aug.set("$srpath/to/ipaddr", to)
        aug.set("$srpath/to/ipaddr/prefixlen", to_prefix)
        aug.set("$srpath/via/ipaddr", via)
        aug.set("$srpath/dev", dev)
      end
    end

    def delete(name)
      route = self[name]
      augsave do |aug|
        aug.rm(route[:path])
      end
    end
  
    def get_all
      paths = @aug.match("$root/static_routes/*")
  
      defs = {}   
      paths.each { |path| 
        src_ipaddr = @aug.get(path + "/src/ipaddr")
        src_prefixlen = @aug.get(path + "/src/ipaddr/prefixlen")
        to_ipaddr = @aug.get(path + "/to/ipaddr")
        to_prefixlen = @aug.get(path + "/to/ipaddr/prefixlen")
        via = @aug.get(path + "/via/ipaddr")
        dev = @aug.get(path + "/dev")
  
        label = ""
        label += src_ipaddr ? src_ipaddr + "/" + (src_prefixlen ? src_prefixlen : "0") : "0.0.0.0/0"
        label += "|"
        label += to_ipaddr ? to_ipaddr + "/" + (to_prefixlen ? to_prefixlen : "0") : "0.0.0.0/0"
  
        defs[label] = {}
        defs[label][:dev] = dev if dev
        defs[label][:via] = via if via
        defs[label][:path] = path
      }
  
      # return definitions
      defs
    end

  end

end
