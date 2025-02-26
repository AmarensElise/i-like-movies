# app/services/actor_age_calculator.rb
class ActorAgeCalculator
  def self.calculate(actor_birthday, movie_release_date)
    return nil if actor_birthday.nil? || movie_release_date.nil?

    # Assuming filming was approximately 1 year before release
    filming_year = movie_release_date.year - 1
    filming_date = Date.new(filming_year, movie_release_date.month, movie_release_date.day)

    # Calculate age during filming
    age = filming_date.year - actor_birthday.year
    age -= 1 if filming_date < actor_birthday + age.years

    age
  end
end
