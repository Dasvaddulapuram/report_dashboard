class CreateRptvAvaiTables < ActiveRecord::Migration
  def change
    create_table :rptv_avai_tables do |t|
      t.string :system_group
      t.string :role
      t.string :region
      t.date :metric_date
      t.timestamps null: false
    end
  end
end
