require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Submodel
  def columns_hash
    
  end
end

describe "PaperTrailChanges" do
  it "should handle booleans" do
    changes = PaperTrailChanges.changes_hash(
      :attributes => {"works" => "1", "fails" => 0, "doesnt_fail" => "1"},
      :version_hash => {"works" => true, "fails" => false, "doesnt_fail" => false},
      :column_types => {"works" => :boolean, "fails" => :boolean, "doesnt_fail" => :boolean}
    )
    
    changes.length.should eql(1)
    changes.keys.first.should eql("doesnt_fail")
    changes.values.first.should eql("1")
  end
  
  it "should handle integers" do
    changes = PaperTrailChanges.changes_hash(
      :attributes => {"number1" => "1", "number2" => "2", "number3" => "3"},
      :version_hash => {"number1" => 1, "number2" => 2, "number3" => 33},
      :column_types => {"number1" => :integer, "number2" => :integer, "number3" => :integer} 
    )
    
    changes.length.should eql(1)
    changes.keys.first.should eql("number3")
    changes.values.first.should eql("3")
  end
  
  it "should handle strings" do
    changes = PaperTrailChanges.changes_hash(
      :attributes => {"str1" => "123", "str2" => "234", "str3" => 3},
      :version_hash => {"str1" => "1234", "str2" => "234", "str3" => 3},
      :column_types => {"str1" => :string, "str2" => :text, "str3" => :string}
    )
    
    changes.length.should eql(1)
    changes.keys.first.should eql("str1")
    changes.values.first.should eql("123")
  end
  
  it "should handle nested attributes" do
    changes = PaperTrailChanges.changes_hash(
      :attributes => {"submodel_attributes" => {"test1" => "test1", "test2" => 2, "test3" => "changed"}},
      :version_hash => {"submodel" => {"test1" => "test1", "test2" => 2, "test3" => "test3"}},
      :column_types => {}
    )
  end
end
