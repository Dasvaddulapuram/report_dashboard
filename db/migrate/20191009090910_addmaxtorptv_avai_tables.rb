class AddmaxtorptvAvaiTables < ActiveRecord::Migration
  def change
    add_column :rptv_avai_tables, :period_mins, :string
    add_column :rptv_avai_tables, :max_mins, :string
  end
end
