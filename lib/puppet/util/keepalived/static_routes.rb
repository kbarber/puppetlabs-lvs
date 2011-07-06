require 'augeas'
require 'puppet/util/keepalived'

module Puppet::Util::Keepalived 

  class StaticRoutes

    def initialize(lenses = "/var/lib/puppet/modules/lvs/augeas_lenses", 
      root = "/")

      @lenses = lenses
      @rootaug = root

      @aug = Augeas::open(root,lenses,Augeas::NO_MODL_AUTOLOAD)
      @aug.transform(
        :lens => "keepalived.lns",
        :incl => "/etc/keepalived/keepalived.conf"
      )
      @aug.load

    end

    def [](index)
      all = self.get_all
      all[index]
    end

    def each
      all = self.get_all
      all.each { |a| yield a }
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

      Augeas::open(@rootaug,@lenses,Augeas::NO_MODL_AUTOLOAD) { |aug|
        aug.transform(
          :lens => "keepalived.lns",
          :incl => "/etc/keepalived/keepalived.conf"
        )
        aug.load

        aug.set(path, value)
        unless aug.save
          raise IOError, "Failed to save changes"
        end
      }
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

      Augeas::open(@rootaug,@lenses,Augeas::NO_MODL_AUTOLOAD) { |aug|
        aug.transform(
          :lens => "keepalived.lns",
          :incl => "/etc/keepalived/keepalived.conf"
        )
        aug.load

        pref = "/files/etc/keepalived/keepalived.conf"
        aug.set(pref + "/static_routes/route[last()+1]/src/ipaddr", src)
        aug.set(pref + "/static_routes/route[last()]/src/ipaddr/prefixlen", src_prefix)
        aug.set(pref + "/static_routes/route[last()]/to/ipaddr", to)
        aug.set(pref + "/static_routes/route[last()]/to/ipaddr/prefixlen", to_prefix)
        aug.set(pref + "/static_routes/route[last()]/via/ipaddr", via)
        aug.set(pref + "/static_routes/route[last()]/dev", dev)

        unless aug.save
          raise IOError, "Failed to save changes"
        end
      }
    end

    def delete(name)
      route = self[name]
      Augeas::open(@rootaug,@lenses,Augeas::NO_MODL_AUTOLOAD) { |aug|
        aug.transform(
          :lens => "keepalived.lns",
          :incl => "/etc/keepalived/keepalived.conf"
        )
        aug.load

        aug.rm(route[:path])
        unless aug.save
          raise IOError, "Failed to save changes"
        end
      }
    end
  
    def get_all
      paths = @aug.match("/files/etc/keepalived/keepalived.conf/static_routes/*")
  
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
  
      @aug.close
  
      # return definitions
      defs
    end

  end

end
