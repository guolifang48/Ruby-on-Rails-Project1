class Admin::SiteSettingsController < ApplicationController
  before_action :authorize_admin

  def manage_prices
    @common = SiteSetting.find_by(name:'price-by-rarity-c')
    @uncommon = SiteSetting.find_by(name:'price-by-rarity-uc')
    @rare = SiteSetting.find_by(name:'price-by-rarity-r')
    @mythic_rare = SiteSetting.find_by(name:'price-by-rarity-mr')
  end

  def edit
    @site_setting = SiteSetting.find(params[:id])
    respond_to do |format|
      format.js {}
    end
  end

  def update
    @site_setting = SiteSetting.find(params[:id])
    respond_to do |format|
      if @site_setting.update(site_setting_params)
        format.js {}
      end
    end
  end

  private
    def site_setting_params
      params.require(:site_setting).permit(:value, :price_in_dollars)
    end
end
