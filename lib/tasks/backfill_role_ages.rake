desc "Backfill age_during_filming for roles where actor birthday and movie release date are present"
namespace :roles do
  task backfill_ages: :environment do
    scope = Role.where(age_during_filming: nil)
                .joins(:actor, :movie)
                .where.not(actors: { birthday: nil })
                .where.not(movies: { release_date: nil })

    total = scope.count
    puts "Backfilling age_during_filming for #{total} roles..."
    updated = 0

    scope.find_each do |role|
      age = ActorAgeCalculator.calculate(role.actor.birthday, role.movie.release_date)
      role.update_columns(age_during_filming: age) if age
      updated += 1
      print "."
    end

    puts "\nDone. Updated: #{updated}"
  end
end
