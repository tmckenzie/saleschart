class SqlQueryManager

  def self.new_instance
    if Rails.env.development?
      MockQueryManager.new
    else
      SqlQueryManager.new
    end
  end

  def sales_by_year_month
    find_by_sql(<<-SQL
      SELECT
        date_trunc('month', created_at) AS year_month,
        sum(amount) as amount
      FROM orders
      GROUP BY year_month
      ORDER BY year_month, amount
    SQL
    ).map do |row|
      [
          row['year_month'].strftime("%B %Y"),
          row.amount.to_f,
      ]
    end
  end

  private


end