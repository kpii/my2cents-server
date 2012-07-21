class ScansController < ApplicationController
  
  def show
    @scan = Scan.find(params[:id])
    
    respond_to do |format|
      format.html
      format.json { render :json => @scan }
    end      
  end

  def new
    @scan = Scan.new
  end

  def create
    @scan = Scan.new(params[:scan])
    ensure_current_user_is_saved
    @scan.user = current_user
    @scan.save!
    
    respond_to do |format|
      format.html do
        redirect_to scan_path(@scan), :notice => "Scan created"
      end
      format.json do
        headers['Location'] = scan_path(@scan)
        render :json => @scan, :status => :created
      end
    end
  end
  
  def update
    @scan = Scan.find(params[:id])
    
    raise Forbidden unless current_user.owns?(@scan)
    
    @scan.update_attributes(params[:scan])

    render :nothing => true, :status => :ok
  end

  def options
    @scan = Scan.find(params[:id])

    render :json => @scan.options
  end
end
