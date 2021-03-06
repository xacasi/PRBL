class Part < ApplicationRecord
  belongs_to :bus_model, optional: true
  has_many :job_parts
  has_one :parts_tire, inverse_of: :part
  accepts_nested_attributes_for :parts_tire, reject_if: :all_blank, allow_destroy: true

  require 'csv'
  scope :tire, lambda { where(group: 1) }
  validates :partname, :presence => true
  validates :part_number, uniqueness: { case_sensitive: false, allow_nil: true}

  def to_name
    "#{partname}: #{part_number}"   
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true, :header_converters=> lambda {|f| f.strip}, :converters=> lambda {|f| f ? f.strip : nil}) do |row|
      part_hash = row.to_hash
      part = Part.where(partname: part_hash["part name"], part_number: part_hash['part number'])
      br_id = nil

      if row['brand'] != nil 
         br = BusModel.where(:brand => part_hash["brand"]).first
         if br == nil
          br = BusModel.create(brand: part_hash["brand"])
         end

         br_id = br.id
     
      end 


      if part.count == 1
       part.first.update_attributes(
        partname: (part_hash['part name']).split(/([ _(-])/).map(&:capitalize).join, 
        part_number: part_hash['part number'], 
        unit: part_hash['unit'], 
        index_number: part_hash['index number'], 
        price: part_hash['price'], 
        lifespan: part_hash['lifespan'], 
        bus_model_id: br_id, 
        last_used: if !part_hash['last updated'].nil?
                   Time.zone.strptime(part_hash['last updated'],'%m/%d/%Y')  
                   end  
                   )
      else
        Part.create(partname: (part_hash['part name']).split(/([ _(-])/).map(&:capitalize).join, 
          part_number: part_hash['part number'], 
          unit: part_hash['unit'], 
          index_number: part_hash['index number'], 
          price: part_hash['price'], 
          lifespan: part_hash['lifespan'], 
          bus_model_id: br_id, 
          last_used: if !part_hash['last updated'].nil?
          Time.zone.strptime(part_hash['last updated'],'%m/%d/%Y')
          end
          )
      end

    end # end CSV.foreach
  end # end self.import(file)

    def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end

end
