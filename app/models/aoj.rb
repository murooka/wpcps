require 'net/http'
require 'rexml/document'

module AOJ

  API_DOMAIN = 'judge.u-aizu.ac.jp'
  API_ROOT_PATH = '/onlinejudge/webservice'

  class BaseAPI

    attr_accessor :fields, :xml

    def initialize(api_path, params)
      @api_path = api_path
      @xml = get_result(params)
      @fields = nil
    end

    def get_result(param_hash)
      params = param_hash.map {|k,v| k.to_s+'='+v.to_s }.join('&')
      res = Net::HTTP.get(API_DOMAIN, API_ROOT_PATH+@api_path+'?'+params)
      REXML::Document.new(res)
    end

    def xml_to_hash(xml)
      hash = {}
      xml.elements.group_by(&:name).each do |k,v|
        hash[k.intern] = if v.size==1
                             if v[0].elements.size==0
                               v[0].text.strip
                             else
                               xml_to_hash(v[0])
                             end
                           else
                             v.map {|e| xml_to_hash(e) }
                           end
      end
      hash
    end

    def hash_to_struct(hash)
      Struct.new(*hash.keys.map(&:intern)).new(*hash.values.map {|s| Hash===s ? hash_to_struct(s) : Array===s ? s.map {|e| hash_to_struct(e) } : s })
    end

    def define_fields
      hash = xml_to_hash(@xml.elements['user'])
      @fields = if hash.empty? then nil else hash_to_struct(hash) end
    end

    def valid?
      not @fields.nil?
    end

    def method_missing(method, *args)
      if @fields && @fields.members.include?(method)
        @fields[method]
      else
        super
      end
    end

  end

  class User < BaseAPI

    def initialize(name)
      super('/user', {id: name})
      define_fields
    end

  end

  class Problem < BaseAPI

    def initialize(id)
      super('/problem', {id: id})
      define_fields
    end

  end

  class Record < BaseAPI

    def initialize(user_id, problem_id)
      super('/solved_record', {user_id: user_id, problem_id: problem_id})
      define_fields
    end

  end

end
