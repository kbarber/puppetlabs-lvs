Puppet::Type.newtype(:keepalived_global_defs) do
  @doc = "Type for managing global_defs entries for keepalived"

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
    desc "Name of global_defs option"

    isnamevar

    newvalues("notification_email", "notification_email_from", "smtp_server",
      "smtp_connect_timeout", "router_id")
  end

  newproperty(:value) do
    desc "The value of global_defs option"
  end

end
