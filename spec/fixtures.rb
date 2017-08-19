require 'active_record'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

class Person < ActiveRecord::Base
  serialize :custom_attributes

  connection.create_table table_name, force: true do |t|
    t.string :first_name
    t.string :last_name
    t.integer :age
    t.text :custom_attributes
  end

  def year_born
    Time.local(2014, 1, 1).year - age
  end
end

class Parent < ActiveRecord::Base
  has_many :children

  connection.create_table table_name, force: true do |t|
    t.string :name
    t.text :custom_attributes
  end
end

class Child < ActiveRecord::Base
  belongs_to :parent

  connection.create_table table_name, force: true do |t|
    t.integer :parent_id
    t.string :name
  end
end

class Supplier < ActiveRecord::Base
  has_one :account
  has_one :account_history, through: :account

  accepts_nested_attributes_for :account, :account_history

  serialize :custom_attributes

  connection.create_table table_name, force: true do |t|
    t.integer :account_id
    t.integer :account_history_id
    t.string :name
    t.text :custom_attributes
  end
end

class Account < ActiveRecord::Base
  belongs_to :supplier
  has_one :account_history

  accepts_nested_attributes_for :account_history

  connection.create_table table_name, force: true do |t|
    t.integer :supplier_id
    t.string :name
    t.integer :tax_identification_number
  end
end

class AccountHistory < ActiveRecord::Base
  belongs_to :account

  connection.create_table table_name, force: true do |t|
    t.integer :account_id
    t.integer :credit_rating
  end
end
