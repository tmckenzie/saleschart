class ActiveHash::Base
  def self.make_statusable
    self.data.each do |member|
      define_singleton_method(member[:name].downcase) do
        find_by_name(member[:name])
      end
    end

    self.data.each do |member|
      define_method("#{member[:name].downcase}?") do
        member[:id] == self.id
      end
    end
  end
end