class ApidocController < ApplicationController
  before_filter :require_admin
  
  def index
    @files = Dir.glob(Rails.root.join("features", "api", "*")).map do |file|
      File.basename(file)
    end.sort
  end

  def show
    render(
      :text => File.read(Rails.root.join("features", "api", params[:file])),
      :content_type => 'text/plain')
  end
end
