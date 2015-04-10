class DataController < ApplicationController
  def get_data
    data = [1,1,2,3,5,8,13,21,34,55]
    respond_to do |format|
      format.json {}
    end
  end
end