# frozen_string_literal: true

module Spree
  Product.class_eval do
    scope :google_base_scope, -> { preload(:taxons, {:master => :images}) }

    def google_base_id
      Spree::Variant.exists?(id) ? "Product#{id}" : id
    end

    def google_base_description
      description
    end

    def google_base_condition
      'new'
    end

    def google_base_availability
      'in stock'
    end

    def google_base_price
      "#{price} #{cost_currency}"
    end

    def google_base_image_size
      :large
    end

    def google_base_brand
      Spree::ProductProperty.joins(:property)
        .where(:product_id => self.id)
        .where(:spree_properties => {:name => 'brand'})
        .first&.value
    end

    def google_base_product_type
      return google_base_taxon_type unless Spree::GoogleBase::Config[:enable_taxon_mapping]

      product_type = ''
      priority = -1000
      self.taxons.each do |taxon|
        if taxon.taxon_map && taxon.taxon_map.priority > priority
          priority = taxon.taxon_map.priority
          product_type = taxon.taxon_map.product_type
        end
      end
      product_type
    end

    def google_base_taxon_type
      return unless taxons.any?

      taxons[0].self_and_ancestors.map(&:name).join(" > ")
    end

    def total_count_on_hand
      stock_items.sum(:count_on_hand)
    end
  end
end
