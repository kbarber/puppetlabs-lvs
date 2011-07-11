require 'set'

shared_examples "a resource type" do |type, properties|
  # Create a provider stub
  before do
    @provider = stub 'provider', :class => Puppet::Type.type(type).defaultprovider, :clear => nil
    Puppet::Type.type(type).defaultprovider.stubs(:new).returns(@provider)
  end

  # Test name
  properties[:name][:valid].each do |value|
    it "should support #{value.inspect} as a value to :name" do
      Puppet::Type.type(type).new(:name => value, :ensure => :present)
    end
  end
  properties[:name][:invalid].each do |value|
    it "should fail if #{value.inspect} is a value of :name" do
      lambda { Puppet::Type.type(type).new(:name => value, :ensure => :present) }.should raise_error
    end
  end

  valid_name = properties[:name][:valid][0]

  # Test all the other properties
  properties.each do |name, settings|
    next if name == :name

    it "should have a #{name.inspect} property" do
      Puppet::Type.type(type).attrtype(name).should == :property 
    end

    settings[:valid].each do |value| 
      it "should support #{value.inspect} as a value to #{name.inspect}" do
        Puppet::Type.type(type).new(:name => valid_name, name => value)
      end
    end

    settings[:invalid].each do |value| 
      it "should fail if #{value.inspect} is a value of #{name.inspect}" do
        lambda { Puppet::Type.type(type).new(:name => valid_name, name => value) }.should raise_error
      end
    end
  end
end
