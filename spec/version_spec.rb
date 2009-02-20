require File.dirname(__FILE__) + '/spec_helper'

class Example < ActiveRecord::Base
  acts_as_versioned
end

class OnlyExample < ActiveRecord::Base
  set_table_name "examples"
  acts_as_versioned :only => :name
end

class ExceptExample < ActiveRecord::Base
  set_table_name "examples"
  acts_as_versioned :except => :name
end

class ProcExample < ActiveRecord::Base
  set_table_name "examples"
  acts_as_versioned :value => Proc.new { |knew, old| (knew || 0) - (old || 0) }
end

describe Example do
  
  it "should start with no versions" do
    example = Example.new
    example.versions.count.should == 0
  end

  it "should store the initial change" do
    example = Example.create({:name => "Hello World!"})
    example.versions.count.should == 1
  end

  it "should store multiple changes" do
    example = Example.create({:name => "Hello World!", :value => 42})
    example.update_attribute(:name, "Pineapple is good")
    example.versions.count.should == 2
  end

  it "should store what changed" do
    example = Example.create({:name => "Peanuts"})
    example.versions.first[:name].should == [nil, "Peanuts"]
  end

  it "should store what changed many times" do
    example = Example.create({:name => "Walrus"})
    example.update_attribute(:name, "Seal")
    example.versions.last.values["name"].should == [nil, "Walrus"]
    example.versions.first.values["name"].should == ["Walrus", "Seal"]
  end

end

describe OnlyExample do

  it "should limit what fields are tracked" do
    example = OnlyExample.create({:name => "Mr. Crackers", :value => 28})
    example.versions.first.values.has_key?("value").should == false
  end

end

describe ExceptExample do

  it "should exclude fields tracked" do
    example = ExceptExample.create({:name => "Milosh", :value => 11})
    example.versions.first.values.has_key?("name").should == false
  end

end

describe ProcExample do

  it "should allow customizing the recorded value of the change" do
    example = ProcExample.create({:name => "Months of Supply", :value => 99})  
    example.versions.first.values["value"].should == (0-99)
    example.update_attribute(:value, 80)
    example.versions.first.values["value"].should == (99-80)
  end

end

