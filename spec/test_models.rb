class User < ActiveRecord::Base
end

class Address < ActiveRecord::Base
end

class PurchasedOrder < ActiveRecord::Base
end

module Statistics
  def self.table_name_prefix
    "statistics_"
  end
end

class Statistics::Request < ActiveRecord::Base
end

class Statistics::Session < ActiveRecord::Base
end
