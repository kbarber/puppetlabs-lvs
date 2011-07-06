require 'augeas'

module Puppet::Util::Keepalived 

  class GlobalDefs

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

    def set(definition, value)
      Augeas::open(@rootaug,@lenses,Augeas::NO_MODL_AUTOLOAD) { |aug|
        aug.transform(
          :lens => "keepalived.lns",
          :incl => "/etc/keepalived/keepalived.conf"
        )
        aug.load

        aug.set("/files/etc/keepalived/keepalived.conf/global_defs/#{definition}", value)
        unless aug.save
          raise IOError, "Failed to save changes"
        end
      }
    end

    def delete(definition)
      Augeas::open(@rootaug,@lenses,Augeas::NO_MODL_AUTOLOAD) { |aug|
        aug.transform(
          :lens => "keepalived.lns",
          :incl => "/etc/keepalived/keepalived.conf"
        )
        aug.load

        aug.rm("/files/etc/keepalived/keepalived.conf/global_defs/#{definition}")
        unless aug.save
          raise IOError, "Failed to save changes"
        end
      }
    end
  
    def get_all
      paths = @aug.match("/files/etc/keepalived/keepalived.conf/global_defs/*")
  
      defs = {}   
      paths.each { |path| 
        name = path.gsub(/.+global_defs\//, "")
        value = @aug.get(path)
        defs[name] = value
      }
  
      @aug.close
  
      # return definitions
      defs
    end
  end
end
