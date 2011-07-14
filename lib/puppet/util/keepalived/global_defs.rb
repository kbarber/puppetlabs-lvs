require 'augeas'
require 'puppet/util/keepalived'

module Puppet::Util::Keepalived 

  class GlobalDefs < Common

    def initialize(lenses = "/var/lib/puppet/modules/lvs/augeas_lenses", 
      root = "/")
      @aug = augload(lenses,root)
    end

    def set(definition, value)
      augsave do |aug|
        aug.set("$root/global_defs/#{definition}", value)
      end
    end

    def delete(definition)
      augsave do |aug|
        aug.rm("$root/global_defs/#{definition}")
      end
    end
  
    def get_all
      paths = @aug.match("$root/global_defs/*")
  
      defs = {}   
      paths.each { |path| 
        name = path.gsub(/.+global_defs\//, "")
        value = @aug.get(path)
        defs[name] = value
      }
  
      # return definitions
      defs
    end
  end
end
