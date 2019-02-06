class Master < ActiveRecord::Base
  has_one :account, :as => :accountable, :autosave => true
end