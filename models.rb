require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection

class Band < ActiveRecord::Base
    has_many :musics
end

class Music < ActiveRecord::Base
    belongs_to :band
    belongs_to :setlist
end

class Setlist < ActiveRecord::Base
    # has_many :musics
end