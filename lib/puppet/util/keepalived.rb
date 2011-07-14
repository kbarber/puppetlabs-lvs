module Puppet::Util::Keepalived
  class Common
    # Method to wrap augeas save operations
    def augsave
      Augeas::open(@rootaug,@lenses,Augeas::NO_MODL_AUTOLOAD) do |aug|
        aug.transform(
          :lens => "keepalived.lns",
          :incl => "/etc/keepalived/keepalived.conf"
        )
        aug.load
        aug.defvar("root", "/files/etc/keepalived/keepalived.conf")

        yield aug

        begin
          aug.save!
        rescue Augeas::Error => ex
          raise "Failed to save: #{ex.message}"
        end
      end
    end

    def augload(lenses, root)
      @lenses = lenses
      @rootaug = root

      @aug = Augeas::open(root,lenses,Augeas::NO_MODL_AUTOLOAD)
      @aug.transform(
        :lens => "keepalived.lns",
        :incl => "/etc/keepalived/keepalived.conf"
      )
      @aug.load
      @aug.defvar("root", "/files/etc/keepalived/keepalived.conf")
      @aug
    end

    def [](index)
      all = get_all()
      all[index]
    end

    def each
      all = self.get_all
      all.each { |a| yield a }
    end
  end
end

require 'puppet/util/keepalived/global_defs'
require 'puppet/util/keepalived/static_routes'
require 'puppet/util/keepalived/vrrp_instance'
require 'puppet/util/keepalived/vrrp_sync_group'
require 'puppet/util/keepalived/virtual_server'
require 'puppet/util/keepalived/real_server'
