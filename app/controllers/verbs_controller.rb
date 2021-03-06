class VerbsController < ApplicationController
  before_filter :session_language, only: [:show, :preview]
  before_filter :set_search_instance
  before_filter :set_root, only: :preview
  before_filter :get_values_for_new_verb, only: [:index, :show, :preview]
  before_filter :remove_ugc_verb_if_not_confirmed, except: :show

  def index
    @verbs = Verb.all_reviewed

    respond_to do |format|
        format.html
        format.json { render json: @verbs.to_json }
    end
  end

  def show
    if session[:ugc_verb] && session[:ugc_verb][:on]
      verb, _exists, msg = Verb.check_for_existing(params[:id], false)
      if _exists
        flash[:error] = msg
      else
        flash[:notice] = msg
      end

      @hebrew_verb = verb.hebrew_verb

      session.delete :ugc_verb
    else
      flash.delete(:error)
      @hebrew_verb = Verb.find(params[:id]).hebrew_verb
    end
  end

  def preview
    verb = Verb.new_preview_instance(params)

    if verb.valid?
      verb.save
    else
      flash[:errors] = verb.errors.full_messages
      render "index"
    end

    hebrew_verb = {verb_id: verb.id, building_id: params[:hebrew_verb][:building_id]}
    root = Letter.create_root_from_letters(params[:root_1], params[:root_2], params[:root_3])

    hebrew_verb.merge! Conjugations::Paal.conjugate_paal(root)
    @hebrew_verb = HebrewVerb.create(hebrew_verb)
    render :show


    # @hebrew_verb = HebrewVerb.new(hebrew_verb)

    # if @hebrew_verb.save
    #   flash[:notice] = 'Verb successfully created!.'
    #   redirect_to verb_path(@hebrew_verb)
    # else
    #   flash[:errors] = @hebrew_verb.errors.full_messages
    #   render 'new'
    # end

  end

  def report
    if session[:ugc_verb] && session[:ugc_verb][:on]
      Verb.check_for_existing(params[:id], true)
      session[:ugc_verb] = true
      render :index
    end
  end

  private

  def set_root
    if params[:hidden_root_4] == "delete"
      params[:hebrew_verb].delete(:root_4)
    end
  end

end
