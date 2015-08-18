module Sortify
  
  def apply_sorting(chain, order_class = resource_class)
    params[:order] ||= 'id_desc'
    if params[:order] && params[:order] =~ /^([\w\_\.]+)_(desc|asc)$/
      column = $1
      order  = $2
      table  = order_class.column_names.include?(column) ? order_class.table_name : nil
      table_column = (column =~ /\./) ? column : [table, order_class.connection.quote_column_name(column)].compact.join(".")
      chain.reorder("#{table_column} #{order}")
    else
      chain
    end
  end
end
