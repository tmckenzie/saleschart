class ProductFilter
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :current_ability, :status, :search_string, :asin, :description, :item_number

  def initialize(attrs = {})
    set_attrs(attrs)
  end

  def set_attrs(attrs, strict=true)
    (attrs || {}).each do |k, v|
      begin
        send "#{k}=", v
      rescue
        raise "#{k} is invalid filter param" if strict
      end
    end
  end


  def persisted?
  end


  def products
    @products ||= begin
      scope = Product.all

      if search_string.present?

        if search_string.split(":").count > 1
          json_hash = StringUtil.parse_search_string(search_string)
          set_attrs(json_hash, false)
        else
          @name = search_string
        end
      end

      if asin.present?
        scope = scope.where 'asin LIKE ?', "%#{asin.strip}%"
      end


      if description.present?
        scope = scope.where 'description LIKE ?', "%#{description.strip}%"
      end


      if item_number.present?
        scope = scope.where 'item_number LIKE ?', "%#{item_number.strip}%"
      end

      # scope = scope.where id: npo_id if npo_id.present?

    end

    scope
  end

end
