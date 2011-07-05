require 'shellwords'

module Puppet::Util::Keepalived

  def self.config_to_hash(config)
    result = {}
    path = []
    rel_depth = {}
    config.each { |l|

      # Cleanup
      l.chomp
      next if l =~ /^\s*$/
      next if l =~ /^#/
      next if l =~ /^1/
      l.gsub!(/^\s*/, "")
      l.gsub!(/\s*$/, "")

      if l =~ /\{$/ then
        # inner block
        args = l.gsub(/\{$/, "").split(" ")

        # Add this block to the current path
        path << args.shift
        rel_depth[path.join(":")] = 1

        res = result
        path.each { |p|
          res[p] = {} if !res.has_key?(p)
          res = res[p]
        }

        # Deal with composite keys
        if args.size > 0 then
          comp_key = args.join(":")
          res[comp_key] = {}

          # Add this key to the current path
          path << comp_key
          rel_depth[path.join(":")] = 2
        end

        next
      elsif l =~ /^\}$/ then 
        # outer block
        rel_depth[path.join(":")].times { path.pop }

        next
      else
        # entry - use shellwords to split so quotes are supported
        args = Shellwords.shellwords(l)

        res = result
        path.each { |p|
          res = res[p]
        }
        key = args.shift
        res[key] = args.join(",")

        next
      end

    }
    return result
  end

  def self.hash_to_config(hash)
    return ""
  end

end
