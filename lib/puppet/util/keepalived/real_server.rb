require 'augeas'
require 'puppet/util/keepalived'

module Puppet::Util::Keepalived

  class RealServer < Common

    def initialize(lenses = "/var/lib/puppet/modules/lvs/augeas_lenses", 
      root = "/")
      @aug = augload(lenses,root)
    end

    def create(inst, options)

      vs, rs = inst.split("/")
      ip, port = rs.split("|")

      vs_obj = VirtualServer.new
      vspath = vs_obj[vs][:path]

      augsave do |aug|
        aug.defnode("rspath", vspath + "/real_server[last()+1]", nil)
        aug.set("$rspath/ip", ip)
        aug.set("$rspath/port", port)
        aug.set("$rspath/weight", options["weight"])
      end

      # reload so we can write some more
      @aug.load

      options.each do |k,v|
        set(inst, k, v, vspath + "/real_server[last()]")
      end

    end

    def set(inst, key, value, pathhelp = nil)
      augsave do |aug|
        path = pathhelp || self[inst][:path]
        if ["weight","inhibit_on_failure","notify_up",
          "notify_down"].include?(key) then

          # Configuration elements in root
          aug.set(path + "/" + key, value)

        elsif ["healthcheck"].include?(key) then

          hc = value["type"].upcase

          # TODO: remove any existing healthchecks
          aug.rm(path + "/HTTP_GET")

          aug.defnode("hcpath", path + "/" + hc, nil)

          value.each do |k,v|
            next if ["type"].include?(k)
            if k == "url" then
              # URL handling is special since its an array of hashes
              aug.defnode("urlpath", "$hcpath/url[last()+1]", nil)

              # now set
              v.each do |url|
                aug.set("$urlpath/path", url["path"]) if url["path"]
                aug.set("$urlpath/digest", url["digest"]) if url["digest"]
                aug.set("$urlpath/status_code", url["status_code"]) if url["status_code"]
              end
            else
              aug.set("$hcpath/#{k}", v)
            end
          end
        end
      end
    end

    def delete(inst)
      augsave do |aug|
        path = self[inst][:path]
        aug.rm(path)
      end
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
          defs[name] = {
            :path => rpath,
          }

          defs[name][:weight] = @aug.get(rpath + "/weight") if @aug.get(rpath + "/weight")
    
          healthcheck = nil
          if @aug.exists(rpath + "/HTTP_GET") then
            healthcheck = "HTTP_GET"
          elsif @aug.exists(rpath + "/SSL_GET") then
            healthcheck = "SSL_GET"
          elsif @aug.exists(rpath + "/TCP_CHECK") then
            healthcheck = "TCP_CHECK"
          elsif @aug.exists(rpath + "/SMTP_CHECK") then
            healthcheck = "SMTP_CHECK"
          elsif @aug.exists(rpath + "/MISC_CHECK") then
            healthcheck = "MISC_CHECK"
          end

          if healthcheck then
            defs[name][:healthcheck] = {
              "type" => healthcheck
            }

            case healthcheck
            when "HTTP_GET", "SSL_GET"
              hcpath = rpath + "/" + healthcheck
              ["connect_port", "bindto", "connect_timeout", "nb_get_retry",
               "delay_before_retry"].each do |prop|
                defs[name][:healthcheck][prop] = @aug.get(hcpath + "/" + prop) if @aug.get(hcpath + "/" + prop)
              end
  
              urls = []
              upaths = @aug.match(hcpath + "/url")
              upaths.each { |upath|
                url = {}
                url["path"] = @aug.get(upath + "/path") if @aug.get(upath + "/path")
                url["status_code"] = @aug.get(upath + "/status_code") if @aug.get(upath + "/status_code")
                url["digest"] = @aug.get(upath + "/digest") if @aug.get(upath + "/digest")
                urls << url
              }
              defs[name][:healthcheck]["url"] = urls
            when "TCP_CHECK"
            when "SMTP_CHECK"
            when "MISC_CHECK"
            end
          end
        }
      }
  
      # return definitions
      defs
    end

  end
end
