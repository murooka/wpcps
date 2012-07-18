class User

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :email, type: String
  field :encrypted_password, type: String
  field :salt, type: String
end
