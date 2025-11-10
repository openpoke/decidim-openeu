class AddFollowersCountToComponents < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_components, :follows_count, :integer, null: false, default: 0, index: true
  end
end
