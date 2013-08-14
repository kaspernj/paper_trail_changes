class PaperTrailChanges
  def last_version(model)
    version = Version.where(:item_type => model.class.name, :item_id => model.id, :event => :update).order(:id).reverse_order.first
    return version
  end
end
