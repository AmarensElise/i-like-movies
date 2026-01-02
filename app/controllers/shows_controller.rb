class ShowsController < ApplicationController
  def index
    @shows = Show.order(created_at: :desc).limit(20)
  end

  def show
    begin
      @show = Show.friendly.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @show = Show.find_by(tmdb_id: params[:id])
    end

    if @show.nil?
      show_data = TmdbService.fetch_tv(params[:id])

      if show_data.present? && show_data['id'].present?
        @show = Show.create!(
          tmdb_id: show_data['id'],
          name: show_data['name'],
          first_air_date: show_data['first_air_date'],
          last_air_date: show_data['last_air_date'],
          poster_path: show_data['poster_path'],
          vote_average: show_data['vote_average'],
          genres: (show_data['genres']&.map { |g| g['name'] } || []).join(',')
        )
      else
        flash[:alert] = "Show not found in TMDB"
        redirect_to root_path
        return
      end
    end

    # Refresh details for view
    @show_details = TmdbService.fetch_tv(@show.tmdb_id)
    @watch_providers = WatchAvailabilityService.new(@show).call
  end

  def cast
    @show = Show.friendly.find(params[:id])

    if @show.show_roles.count <= 1
      fetch_and_save_cast(@show)
    end

    @cast = @show.show_roles.includes(:actor).order(:id)
    @show_details = TmdbService.fetch_tv(@show.tmdb_id)
    @watch_providers = WatchAvailabilityService.new(@show).call
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def fetch_cast
    @show = Show.friendly.find(params[:id])
    fetch_and_save_cast(@show)

    @cast = @show.show_roles.includes(:actor).order(:id)
    render partial: 'shows/cast', locals: { cast: @cast, show: @show }
  rescue ActiveRecord::RecordNotFound
    head :not_found
  rescue => e
    Rails.logger.error("Error in fetch_cast: #{e.message}")
    head :internal_server_error
  end

  private

  def fetch_and_save_cast(show)
    cast_data = TmdbService.fetch_tv_credits(show.tmdb_id)
    return unless cast_data && cast_data['cast'].is_a?(Array)

    cast_data['cast'].each do |cast_member|
      next unless cast_member['id'].present? && cast_member['name'].present?

      actor = Actor.find_by(tmdb_id: cast_member['id'])

      if actor.nil?
        actor_details = TmdbService.fetch_person(cast_member['id'])
        actor = Actor.create!(
          tmdb_id: cast_member['id'],
          name: cast_member['name'],
          birthday: actor_details['birthday']
        )
      end

      ShowRole.find_or_create_by!(show: show, actor: actor) do |role|
        role.character = cast_member['character']
      end
    end
  end
end
