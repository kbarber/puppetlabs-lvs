require 'augeas'

module Puppet::Util::Keepalived

  def self.get_global_defs(
    lenses = "/var/lib/puppet/modules/lvs/augeas_lenses", 
    root = "/")

    Augeas::open(root,lenses,Augeas::NO_MODL_AUTOLOAD) { |aug|

      aug.transform(
        :lens => "keepalived.lns",
        :incl => "/etc/keepalived/keepalived.conf"
      )
      aug.load

      paths = aug.match("/files/etc/keepalived/keepalived.conf/global_defs/*")
      
      defs = {}   
      paths.each { |path| 
        name = path.gsub(/.+global_defs\//, "")
        value = aug.get(path)
        defs[name] = value
      }

      # return definitions
      defs
    }
  end

  def self.set_global_defs(
    definition, value,
    lenses = "/var/lib/puppet/modules/lvs/augeas_lenses", 
    root = "/")

    Augeas::open(root,lenses,Augeas::NO_MODL_AUTOLOAD) { |aug|

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

  def self.rm_global_def(
    definition,
    lenses = "/var/lib/puppet/modules/lvs/augeas_lenses", 
    root = "/")

    Augeas::open(root,lenses,Augeas::NO_MODL_AUTOLOAD) { |aug|

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

end
