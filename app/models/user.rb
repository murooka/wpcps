class User

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  key :name
  field :email, type: String
  field :encrypted_password, type: String
  field :salt, type: String
  field :is_admin, type: Boolean, default: false

  validates_uniqueness_of :name, :message => 'was already taken.'
  validates_uniqueness_of :email, :message => 'was already used.'

  def self.encrypt_password(password, salt)
    key = '6bgEVBuWqD'
    Digest::SHA1.hexdigest(salt + password + key)
  end

  def self.authenticate(name, password)
    user = User.where(name: name).first or return nil
    return nil if encrypt_password(password, user.salt)!=user.encrypted_password
    user
  end


end
