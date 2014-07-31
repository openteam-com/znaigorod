class QuestionsController < ApplicationController
  def index
    respond_to do |format|
      format.html {
        @presenter = QuestionsPresenter.new(params)
      }

      format.promotion {
        presenter = QuestionsPresenter.new(params.merge(:per_page => 5))

        render :partial => 'promotions/questions', :locals => { :presenter => presenter }
      }
    end

  end

  def show
    @question = ReviewDecorator.new(Question.find(params[:id]))

    respond_to do |format|
      format.html { @presenter = QuestionsPresenter.new(params) }

      format.promotion {
        render :partial => 'promotions/question', :locals => { :decorated_question => @question }
      }
    end
  end
end
