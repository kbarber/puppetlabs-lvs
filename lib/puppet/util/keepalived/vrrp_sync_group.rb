require 'augeas'
require 'puppet/util/keepalived'

module Puppet::Util::Keepalived

  class VrrpSyncGroup < Common

    def initialize(lenses = "/var/lib/puppet/modules/lvs/augeas_lenses", 
      root = "/")
      @aug = augload(lenses, root)
    end

    def create(vrrp_inst, options)
      augsave do |aug|
        aug.defnode("vsgpath", "$root/vrrp_sync_group[last()+1]", vrrp_inst)
        options.each do |key,value|
          path = "$root/vrrp_sync_group[last()]"
          if key == "group" then
            value.each { |group| aug.set("$vsgpath/group/#{group}", nil) }
          else
            aug.set("$vsgpath/#{key}", value)
          end
        end
      end
    end

    def set(vrrp_inst, key, value)
      augsave do |aug|
        path = self[vrrp_inst][:path]
        if key == "group" then
          # first remove - easier this way
          aug.rm(path + "/group")
          value.each { |k| aug.set(path + "/group/" + k, nil) }
        else
          aug.set(path + "/" + key, value)
        end
      end
    end

    def delete(vrrp_inst)
      augsave do |aug|
        path = self[vrrp_inst][:path]
        aug.rm(path)
      end
    end
  
    def get_all
      paths = @aug.match("$root/vrrp_sync_group")
  
      defs = {}   
      paths.each { |path| 
        name = @aug.get(path)

        # collect groups
        groups_paths = @aug.match(path + "/group/*")
        groups = groups_paths.collect { |group| group.gsub(/.+\/group\//, "") }

        # prepare hash to be returned
        defs[name] = {
          :group => groups,
          :path => path,
        }
      }
  
      # return definitions
      defs
    end
  end
end
