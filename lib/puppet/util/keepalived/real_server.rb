require 'augeas'

module Puppet::Util::Keepalived

  class RealServer

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

        # Do sets here

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
        if ["weight"].include?(key) then
          # Configuration elements in root
          aug.set(path + "/" + key, value)
        elsif ["nb_get_retry", "connect_port", "connect_timeout", 
          "delay_before_retry", "bindto", "helo_name", "misc_path", 
          "misc_timeout", "misc_dynamic"].include?(key) then

          # Configuration elements in healthcheck
          aug.set(path + "/" + self[inst][:healthcheck].to_s.upcase + "/" + key, value)
        elsif key == "url" then
          # URL handling is special since its an array of hashes
          # first remove
          urlpath = path + "/" + self[inst][:healthcheck].to_s.upcase + "/url"
          aug.rm(urlpath)

          # now set
          value.each { |url|
            aug.set(urlpath + "[last()+1]", nil)
            aug.set(urlpath + "[last()]/path", url["path"]) if url["path"]
            aug.set(urlpath + "[last()]/digest", url["digest"]) if url["digest"]
            aug.set(urlpath + "[last()]/status_code", url["status_code"]) if url["status_code"]
          }
        end

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
      vpaths = @aug.match("/files/etc/keepalived/keepalived.conf/virtual_server")
  
      defs = {}   
      vpaths.each { |vpath| 
        vip = @aug.get(vpath + "/ip")
        vport = @aug.get(vpath + "/port")
        vprotocol = @aug.get(vpath + "/protocol")
        vname = vip + "|" + vport + "|" + vprotocol

	rpaths = @aug.match(vpath + "/real_server")
        rpaths.each { |rpath|
          rip = @aug.get(rpath + "/ip")
          rport = @aug.get(rpath + "/port")
          rname = rip + "|" + rport

          name = vname + "/" + rname
     
          # prepare hash to be returned
          healthcheck = nil
          if @aug.exists(rpath + "/HTTP_GET") then
            healthcheck = :http_get
          elsif @aug.exists(rpath + "/SSL_GET") then
            healthcheck = :ssl_get
          elsif @aug.exists(rpath + "/TCP_CHECK") then
            healthcheck = :tcp_check
          elsif @aug.exists(rpath + "/SMTP_CHECK") then
            healthcheck = :smtp_check
          elsif @aug.exists(rpath + "/MISC_CHECK") then
            healthcheck = :misc_check
          end
          defs[name] = {
            :weight => @aug.get(rpath + "/weight"),
            :healthcheck => healthcheck,
            :path => rpath,
          }

          case healthcheck
          when :http_get, :ssl_get
            defs[name][:connect_port] = @aug.get(rpath + "/HTTP_GET/connect_port")
            defs[name][:bindto] = @aug.get(rpath + "/HTTP_GET/bindto")
            defs[name][:connect_timeout] = @aug.get(rpath + "/HTTP_GET/connect_timeout")
            defs[name][:nb_get_retry] = @aug.get(rpath + "/HTTP_GET/nb_get_retry")
            defs[name][:delay_before_retry] = @aug.get(rpath + "/HTTP_GET/delay_before_retry")

            urls = []
            upaths = @aug.match(rpath + "/HTTP_GET/url")
            upaths.each { |upath|
              url = {}
              url["path"] = @aug.get(upath + "/path") if @aug.get(upath + "/path")
              url["status_code"] = @aug.get(upath + "/status_code") if @aug.get(upath + "/status_code")
              url["digest"] = @aug.get(upath + "/digest") if @aug.get(upath + "/digest")
              urls << url
            }
            defs[name][:url] = urls
          when :tcp_check
          when :smtp_check
          when :misc_check
          end
        }
      }
  
      # return definitions
      defs
    end
  end
end
