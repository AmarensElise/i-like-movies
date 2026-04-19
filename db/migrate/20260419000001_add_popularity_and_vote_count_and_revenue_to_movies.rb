class AddPopularityAndVoteCountAndRevenueToMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :popularity, :decimal, precision: 10, scale: 4 unless column_exists?(:movies, :popularity)
    add_column :movies, :vote_count, :integer unless column_exists?(:movies, :vote_count)
    add_column :movies, :revenue, :bigint unless column_exists?(:movies, :revenue)
    add_index :movies, [:vote_count, :popularity] unless index_exists?(:movies, [:vote_count, :popularity])
  end
end
