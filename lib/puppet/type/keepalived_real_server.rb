require 'puppet/property/list'
require 'puppet/property/ordered_list'
require 'puppet/property/keyvalue'

Puppet::Type.newtype(:keepalived_real_server) do
  @doc = "Type for managing real_server entries for keepalived"

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto :present
  end

  newparam(:name) do
    desc "Name of real_server"

    isnamevar
  end

  newproperty(:weight) do
    desc "weight"
  end

  newproperty(:healthcheck) do
    desc "healthcheck: http_get|ssl_get|tcp_check|smtp_check|misc_check"

    newvalues(:http_get, :ssl_get, :tcp_check, :smtp_check, :misc_check)
  end

  # http_get & ssl_get related properties
  newproperty(:url, :array_matching => :all) do
  #newproperty(:url) do
  #newproperty(:url, :parent => Puppet::Property::List) do
    desc "url"

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end
 
  newproperty(:connect_port) do
    desc "connect_port"
  end

  newproperty(:bindto) do
    desc "bindto"
  end

  newproperty(:connect_timeout) do
    desc "connect_timeout"
  end

  newproperty(:nb_get_retry) do
    desc "nb_get_retry"
  end

  newproperty(:delay_before_retry) do
    desc "delay_before_retry"
  end

  # smtp_check related properties
  newproperty(:retry) do
    desc "retry"
  end

  newproperty(:helo_name) do
    desc "helo_name"
  end

  # misc_check related properties
  newproperty(:misc_path) do
    desc "misc_path"
  end

  newproperty(:misc_timeout) do
    desc "misc_timeout"
  end

  newproperty(:misc_dynamic, :boolean => true) do
    desc "misc_dynamic"
  end
  
end
