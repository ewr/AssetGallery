module AssetGallery
  class SetsController < ApplicationController
    
    before_filter :load_set, :except => [:new,:create,:index]
    before_filter :require_admin, :except => [:index,:show]
    skip_before_filter :verify_authenticity_token, :only => [:assets]

    #----------
    
    def show
      
    end
    
    def show_asset
      # Load asset
      @asset = @set.set_assets.where(:asset_id => params[:asset]).first
      
      if !@asset
        flash[:notice] = "Unable to find that asset in the set."
        redirect_to set_path(@set)
      end
    end
    
    #----------
    
    def new
      
    end
    
    #----------
    
    def create
      
    end
    
    #----------
    
    def assets
      assets = JSON.parse(params[:assets])

      assets.each_with_index do |a,idx|
        puts "a is #{a}"
        if sa = @set.set_assets[idx]
          sa.update_attributes(
            :asset_id => a['id'],
            :position => idx,
            :caption  => a['caption']        
          )
        else
          @set.set_assets.create(
            :asset_id => a['id'],
            :position => idx,
            :caption  => a['caption']
          )
        end
      end

      # delete leftover assets
      if @set.set_assets.length > assets.length
        @set.set_assets[assets.length..-1].each {|sa| sa.destroy }
      end

      render :text => "Assets is #{@set.set_assets}"
    end
    
    #----------
    
    protected
    def load_set
      @set = AssetGallery::Set.find(params[:set] || params[:id])
    #rescue
    #  Rails.logger.debug("Failed to find set with ID #{params[:set] || params[:id]}")
    #  flash[:notice] = "Invalid set given."
    #  redirect_to home_path
    end
  end
end
