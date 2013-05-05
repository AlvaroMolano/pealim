class VerbSearchesController < ApplicationController
  before_filter :set_search_instance
  before_filter :get_values_for_new_verb
  before_filter :remove_ugc_verb_if_not_confirmed, only: :create

  def show
  end

  def new
  end

  def create
    @search = VerbSearch.create! params[:verb_search]
    redirect_to verb_path(params[:verb_search][:verb_id])
  end

end
