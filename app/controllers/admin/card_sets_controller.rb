class Admin::CardSetsController < ApplicationController
  before_action :authorize_admin
  before_action :load_card_set, only: [:show, :edit, :update]

  def index
    @card_sets = CardSet.order(release_date: :desc).paginate(:page => params[:page], :per_page => 500)
    @standard_card_sets = CardSet.where(current_standard: true)
  end

  def show
    @cards = @card_set.cards.order(name: :asc).paginate(:page => params[:page], :per_page => 500)
  end

  def new
    @card_set = CardSet.new

    respond_to do |format|
      format.js { render 'admin/card_sets/launch_form' }
    end
  end

  def edit
    respond_to do |format|
      format.js { render 'admin/card_sets/launch_form' }
    end
  end

  def create
    @card_set = CardSet.new(card_set_params)
    @card_set.save

    respond_to do |format|
      format.html { redirect_to admin_card_sets_path, notice: 'Card set was successfully created.' }
    end
  end

  def update
    @card_set.update(card_set_params)
    respond_to do |format|
      format.html { redirect_to admin_card_sets_path, notice: 'Card set was successfully updated.' }
    end
  end

  private

  def load_card_set
    @card_set ||= CardSet.find(params[:id])
  end

  def card_set_params
    params.require(:card_set).permit(:name, :code, :release_date, :set_type, :block, :online_only,
                                     :current_standard, :category, :position)
  end
end
