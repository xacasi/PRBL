class BusLine < ApplicationRecord
	has_many :buses
  validates :linename, presence: true
  validates :linename, uniqueness: { case_sensitive: false }

  before_validation :uppercase_linename

	require 'csv'

  def uppercase_linename
    linename.upcase!
  end

	def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
     busline_hash = row.to_hash
      busline = BusLine.where(linename: busline_hash["linename"])

      if busline.count == 1
        busline.first.update_attributes(busline_hash)
      else
        BusLine.create! row.to_hash
      end # end if !busline.nil?
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
