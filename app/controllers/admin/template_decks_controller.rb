class Admin::TemplateDecksController < ApplicationController
  include CardsHelper

  before_action :authorize_admin
  before_action :set_template_deck, only: [:show, :edit, :update, :destroy]

  def index
    @template_decks = TemplateDeck.all.paginate(page:params[:page], per_page:50)
  end

  def show
    @template_deck_card_hash = parse_reference_deck_by_type(@template_deck.template_deck_cards.deck)
  end

  def new
    @template_deck = TemplateDeck.new

    respond_to do |format|
      format.js { render 'admin/template_decks/launch_form' }
    end
  end

  def edit

    respond_to do |format|
      format.js { render 'admin/template_decks/launch_form' }
    end
  end

  def create
    @template_deck = TemplateDeck.new(template_deck_params)
    @template_deck.save

    respond_to do |format|
      format.html { redirect_to admin_template_deck_path(@template_deck), notice: 'Template deck was successfully created.' }
    end
  end

  def update
    @template_deck.update(template_deck_params)
    respond_to do |format|
      format.html { redirect_to admin_template_deck_path(@template_deck), notice: 'Template deck was successfully updated.' }
    end
  end

  def destroy
    @template_deck.destroy
    respond_to do |format|
      format.html { redirect_to admin_template_decks_url }
    end
  end

  private
    def set_template_deck
      @template_deck = TemplateDeck.find(params[:id])
    end

    def template_deck_params
      params.require(:template_deck).permit(:name, :description)
    end
end
