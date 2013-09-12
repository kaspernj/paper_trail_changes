require "string-cases"

class PaperTrailChanges
  def self.last_version(model)
    version = Version.where(:item_type => model.class.name, :item_id => model.id, :event => :update).order(:id).reverse_order.first
    return version
  end
  
  CHANGES_SINCE_VERSION_VALID_ARGS = [:version_id, :version_at, :model, :attributes]
  def self.changes_since_version(args)
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." unless CHANGES_SINCE_VERSION_VALID_ARGS.include?(key)
    end
    
    attributes, model = args[:attributes], args[:model]
    
    column_types = PaperTrailChanges.column_types_from_class(model.class)
    
    if args[:version_id]
      version_obj = Version.find(args[:version_id]) rescue nil
    elsif args[:version_at]
      version_model = model.version_at(args[:version_at])
    end
    
    version_model = model if version_obj.nil? && version_model.nil?
    
    if version_obj
      version_hash = Psych.load(version_obj.object).stringify_keys
    elsif version_model
      version_hash = {}
      version_model.attributes.each do |key, val|
        version_hash[key.to_s] = version_model.__send__("#{key}_before_type_cast")
      end
    else
      raise "Dont know what to do?"
    end
    
    changes_since = PaperTrailChanges.changes_hash(
      :attributes => attributes,
      :version_hash => version_hash,
      :model => model,
      :column_types => column_types
    )
    
    return changes_since
  end
  
  def self.column_types_from_class(class_obj)
    column_types = {}
    class_obj.columns_hash.each do |name, col|
      column_types[name] = col.type
    end
    
    return column_types
  end
  
  CHANGES_HASH_VALID_ARGS = [:attributes, :version_hash, :model, :column_types]
  def self.changes_hash(args)
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." unless CHANGES_HASH_VALID_ARGS.include?(key)
    end
    
    attributes, version_hash, model, column_types = args[:attributes], args[:version_hash], args[:model], args[:column_types]
    changes_since = {}
    
    attributes.each do |key, val|
      key_s = key.to_s
      
      if match = key_s.match(/^(.+)_attributes$/)
        # Nested model. Since paper-trail doesn't keep track of this just pass it through.
        changes_since[key] = val
      elsif version_hash.key?(key_s)
        last_val = version_hash[key_s]
        changed = false
        type = column_types[key_s]
        
        if type == :string || type == :date || type == :text || type == :datetime
          changed = true if last_val.to_s != val.to_s
        elsif type == :integer
          changed = true if last_val.to_i != val.to_i
          changed = true if last_val == nil && val
        elsif type == :boolean
          if last_val == true
            bool_i = 1
          elsif last_val == false
            bool_i = 0
          elsif last_val.to_i == 1
            bool_i = 1
          elsif last_val.to_i == 0
            bool_i = 0
          end
          
          changed = true if bool_i != val.to_i
          changed = true if last_val == nil && val
        else
          raise "Unknown type: '#{type}'."
        end
        
        changes_since[key_s] = val if changed
      else
        changes_since[key_s] = val
      end
    end
    
    return changes_since
  end
end
