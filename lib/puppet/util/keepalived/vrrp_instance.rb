require 'augeas'

module Puppet::Util::Keepalived

  class VrrpInstance

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

    def set(vrrp_inst, key, value)
      Augeas::open(@rootaug,@lenses,Augeas::NO_MODL_AUTOLOAD) { |aug|
        aug.transform(
          :lens => "keepalived.lns",
          :incl => "/etc/keepalived/keepalived.conf"
        )
        aug.load

        path = self[vrrp_inst][:path]
        if key == "virtual_ipaddress" then
          # first remove - easier this way
          aug.rm(path + "/virtual_ipaddress")
          value.each { |k|
            ip, prefix = k.split("/")
            #debug("path: #{path} ip: #{ip} prefix: #{prefix}")
            aug.set(path + "/virtual_ipaddress/ipaddr[last()+1]", ip)
            aug.set(path + "/virtual_ipaddress/ipaddr[last()]/prefixlen", prefix ? prefix : "32")
          }
        else
          aug.set(path + "/" + key, value)
        end

        unless aug.save
          raise IOError, "Failed to save changes"
        end
      }
    end

    def delete(vrrp_inst)
      Augeas::open(@rootaug,@lenses,Augeas::NO_MODL_AUTOLOAD) { |aug|
        aug.transform(
          :lens => "keepalived.lns",
          :incl => "/etc/keepalived/keepalived.conf"
        )
        aug.load

        path = self[vrrp_inst][:path]
        aug.rm(path)
        unless aug.save
          raise IOError, "Failed to save changes"
        end
      }
    end
  
    def get_all
      paths = @aug.match("/files/etc/keepalived/keepalived.conf/vrrp_instance")
  
      defs = {}   
      paths.each { |path| 
        name = @aug.get(path)

        # collect virtual_ipaddress
        vips = []
        virtips_paths = @aug.match(path + "/virtual_ipaddress/*")
        virtips_paths.each { |vippath|
          vip = @aug.get(vippath)
          prefix = @aug.get(vippath + "/prefixlen")
          address = vip + "/" + (prefix ? prefix : "32")
          vips << address
        }

        # prepare hash to be returned
        defs[name] = {
          :interface => @aug.get(path + "/interface"),
          :virtual_router_id => @aug.get(path + "/virtual_router_id"),
          :priority => @aug.get(path + "/priority"),
          :virtual_ipaddress => vips,
          :lvs_sync_daemon_interface => @aug.get(path + "/lvs_sync_daemon_interface"),
          :path => path,
        }
      }
  
      # return definitions
      defs
    end
  end
end
