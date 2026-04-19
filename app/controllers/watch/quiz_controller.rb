module Watch
  class QuizController < ApplicationController
    before_action :authenticate_user!

    def show
      redirect_to streaming_watch_quiz_path
    end

    def streaming
      @step = :streaming
    end

    def length
      @step = :length
    end

    def adventurousness
      @step = :adventurousness
    end

    def category
      @step = :category
      base_filters = {
        streaming: params[:streaming],
        length: params[:length],
        adventurousness: params[:adventurousness]
      }
      seed = session.id.to_s
      @categories = CategorySuggester.new(user: current_user, base_filters: base_filters, seed: seed).call
    end

    def final
      @step = :final
      filters = build_filters
      picker = MoviePicker.new(user: current_user, filters: filters)
      scope = picker.call
      rich_cast_scope = scope.joins(:roles)
                             .group("movies.id")
                             .having("COUNT(roles.id) >= 3")

      pool = rich_cast_scope.order(Arel.sql("RANDOM()")).limit(2).to_a
      pool = scope.order(Arel.sql("RANDOM()")).limit(2).to_a if pool.empty?

      @movies = pool
      @no_matches = pool.empty?
    end

    def complete
      chosen = Movie.find(params[:chosen_movie_id])
      rejected = params[:rejected_movie_id].present? ? Movie.find(params[:rejected_movie_id]) : nil

      quiz_session = current_user.watch_quiz_sessions.create!(
        answers: {
          media_type: "movie",
          streaming: params[:streaming],
          length: params[:length],
          adventurousness: params[:adventurousness],
          category: params[:category_key].present? ? { key: params[:category_key], label: params[:category_label] } : nil
        },
        chosen_movie: chosen,
        rejected_movie: rejected,
        completed_at: Time.current
      )

      redirect_to completed_watch_quiz_path(session_id: quiz_session.id)
    end

    def completed
      @quiz_session = current_user.watch_quiz_sessions.find(params[:session_id])
      @movie = @quiz_session.chosen_movie
      @watch_providers = WatchAvailabilityService.new(@movie).call
      @starring = @movie.roles.joins(:actor).order(:id).limit(3).pluck("actors.name").uniq
    end

    private

    def build_filters
      filters = {
        streaming: params[:streaming],
        length: params[:length],
        adventurousness: params[:adventurousness]
      }

      if params[:category_key].present?
        template = CategorySuggester::TEMPLATES.find { |t| t[:key].to_s == params[:category_key] }
        filters.merge!(template[:filters]) if template
      end

      filters
    end
  end
end
