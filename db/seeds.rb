# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Preset Stickers
puts "Seeding preset stickers..."
Sticker.find_or_create_by!(label: "Horror",       preset: true, color: "#D94F3D")
Sticker.find_or_create_by!(label: "Action",       preset: true, color: "#E8753A")
Sticker.find_or_create_by!(label: "Comedy",       preset: true, color: "#F2C94C")
Sticker.find_or_create_by!(label: "Drama",        preset: true, color: "#5B8C5A")
Sticker.find_or_create_by!(label: "Sci-Fi",       preset: true, color: "#3A6FA8")
Sticker.find_or_create_by!(label: "Romance",      preset: true, color: "#C75B9B")
Sticker.find_or_create_by!(label: "Cult Classic", preset: true, color: "#2D2D2D")
Sticker.find_or_create_by!(label: "Mind Bender",  preset: true, color: "#7B4FC9")
Sticker.find_or_create_by!(label: "Essential",    preset: true, color: "#8B6914")
Sticker.find_or_create_by!(label: "Hidden Gem",   preset: true, color: "#4DBFB8")
Sticker.find_or_create_by!(label: "Rewatch",      preset: true, color: "#6B8E6B")
puts "Done! #{Sticker.presets.count} preset stickers."
