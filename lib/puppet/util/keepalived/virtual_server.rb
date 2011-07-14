require 'augeas'
require 'puppet/util/keepalived'

module Puppet::Util::Keepalived

  class VirtualServer < Common

    def initialize(lenses = "/var/lib/puppet/modules/lvs/augeas_lenses", 
      root = "/")
      @aug = augload(lenses,root)
    end

    def create(vs, options)
      augsave do |aug|
        # Grab elements from title
        ip, port, protocol = vs.split("|")
        options["ip"] = ip
        options["port"] = port
        options["protocol"] = protocol

        aug.defnode("vspath", "$root/virtual_server[last()+1]", nil)

        allowed_params = ["ip","port","protocol","delay_loop","lb_algo",
          "lb_kind","persistence_timeout"]
        allowed_params.each do |k|
          aug.set("$vspath/#{k}", options[k].to_s) if options[k]
        end
      end
    end

    def set(inst, key, value)
      augsave do |aug|
        path = self[inst][:path]
        aug.set(path + "/" + key, value)
      end
    end

    def delete(inst)
      augsave do |aug|
        path = self[inst][:path]
        aug.rm(path)
      end
    end
  
    def get_all
      paths = @aug.match("$root/virtual_server")
  
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
