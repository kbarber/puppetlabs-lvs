require 'augeas'

module Puppet::Util::Keepalived

  class VrrpSyncGroup

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

    def create(vrrp_inst, options)
      Augeas::open(@rootaug,@lenses,Augeas::NO_MODL_AUTOLOAD) { |aug|
        aug.transform(
          :lens => "keepalived.lns",
          :incl => "/etc/keepalived/keepalived.conf"
        )
        aug.load

        aug.set("/files/etc/keepalived/keepalived.conf/vrrp_sync_group[last()+1]", vrrp_inst)
        options.each { |key,value|
          path = "/files/etc/keepalived/keepalived.conf/vrrp_sync_group[last()]"
          if key == "groups" then
            value.each { |group|
              aug.set(path + "/group/" + group, nil)
            }
          else
            aug.set(path + "/" + key, value)
          end
  
        }

        unless aug.save
          raise IOError, "Failed to save changes"
        end
      }
    end

    def set(vrrp_inst, key, value)
      Augeas::open(@rootaug,@lenses,Augeas::NO_MODL_AUTOLOAD) { |aug|
        aug.transform(
          :lens => "keepalived.lns",
          :incl => "/etc/keepalived/keepalived.conf"
        )
        aug.load

        path = self[vrrp_inst][:path]
        if key == "groups" then
          # first remove - easier this way
          aug.rm(path + "/group")
          value.each { |k|
            aug.set(path + "/group/" + k, nil)
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
      paths = @aug.match("/files/etc/keepalived/keepalived.conf/vrrp_sync_group")
  
      defs = {}   
      paths.each { |path| 
        name = @aug.get(path)

        # collect groups
        groups_paths = @aug.match(path + "/group/*")
        groups = groups_paths.collect { |group| group.gsub(/.+\/group\//, "") }

        # prepare hash to be returned
        defs[name] = {
          :groups => groups,
          :path => path,
        }
      }
  
      # return definitions
      defs
    end
  end
end
