require 'augeas'

module Puppet::Util::Keepalived

  class VirtualServer

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

    def create(vs, options)
      Augeas::open(@rootaug,@lenses,Augeas::NO_MODL_AUTOLOAD) { |aug|
        aug.transform(
          :lens => "keepalived.lns",
          :incl => "/etc/keepalived/keepalived.conf"
        )
        aug.load

        # Grab elements from title
        ip, port, protocol = vs.split("|")
        options["ip"] = ip
        options["port"] = port
        options["protocol"] = protocol

        path = "/files/etc/keepalived/keepalived.conf/virtual_server"
        aug.set(path + "[last()+1]", nil)

        allowed_params = ["ip","port","protocol","delay_loop","lb_algo",
          "lb_kind","persistence_timeout"]
        allowed_params.each { |k|
          aug.set(path + "[last()]/" + k, options[k].to_s) if options[k]
        }

        unless aug.save
          raise IOError, "Failed to save changes"
        end
      }

    end

    def set(inst, key, value)
      Augeas::open(@rootaug,@lenses,Augeas::NO_MODL_AUTOLOAD) { |aug|
        aug.transform(
          :lens => "keepalived.lns",
          :incl => "/etc/keepalived/keepalived.conf"
        )
        aug.load

        path = self[inst][:path]
        aug.set(path + "/" + key, value)

        unless aug.save
          raise IOError, "Failed to save changes"
        end
      }
    end

    def delete(inst)
      Augeas::open(@rootaug,@lenses,Augeas::NO_MODL_AUTOLOAD) { |aug|
        aug.transform(
          :lens => "keepalived.lns",
          :incl => "/etc/keepalived/keepalived.conf"
        )
        aug.load

        path = self[inst][:path]
        aug.rm(path)

        unless aug.save
          raise IOError, "Failed to save changes"
        end
      }
    end
  
    def get_all
      paths = @aug.match("/files/etc/keepalived/keepalived.conf/virtual_server")
  
      defs = {}   
      paths.each { |path| 
        ip = @aug.get(path + "/ip")
        port = @aug.get(path + "/port")
        protocol = @aug.get(path + "/protocol")
        name = ip + "|" + port + "|" + protocol

        # prepare hash to be returned
        defs[name] = {
          :delay_loop => @aug.get(path + "/delay_loop"),
          :lb_algo => @aug.get(path + "/lb_algo"),
          :lb_kind => @aug.get(path + "/lb_kind"),
          :persistence_timeout => @aug.get(path + "/persistence_timeout"),
          :path => path,
        }
      }
  
      # return definitions
      defs
    end
  end
end
