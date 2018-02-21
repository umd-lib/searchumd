# This migration comes from quick_search (originally 20140130202944)
class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :query

      t.timestamps
    end
  end
end
