require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'
require 'sinatra/activerecord'
require './models'
require 'dotenv'
require 'cloudinary'

Dotenv.load

Cloudinary.config do |config|
config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']
config.api_key = ENV['CLOUDINARY_API_KEY']
config.api_secret = ENV['CLOUDINARY_API_SECRET']
end

get '/' do
  erb :index
end

post '/create_band' do
    if params[:file]
    	uploaded_file = params[:file][:tempfile]
    	puts uploaded_file
    	result = Cloudinary::Uploader.upload(uploaded_file.path)
    	p result
    	band = Band.create!(name: params[:band_name], uid: params[:band_uid], img_url:result['secure_url'] )
      
        		if band.persisted?
        		  puts "success"
        		  redirect "/#{params[:band_uid]}/edit"
        		else
        		 puts  "データベースに保存できませんでした"
        		end
    	    else
    	        puts "ファイルが選択されていません"
    	redirect "/create_band"
	end
end

get '/create_band' do
    erb :create_band
end

get '/sign_in' do
    
    erb :sign_in
end

post '/sign_in' do
    band_name = params[:band_name]
    band_uid = params[:band_uid]
    @band = Band.find_by(uid: band_uid, name: band_name)
    if @band.nil?
        redirect "/create_band"
    else
        redirect "/#{params[:band_uid]}/edit"
    end
end

get '/:band_uid/edit' do
    @band = Band.find_by(uid: params[:band_uid])
    # @band.name = params[:band_name]
    @band_musics = @band.musics.all
    puts @band_musics
    @music = Music.all
    @setlists = Setlist.where(uid: @band.uid)
    erb :band_edit
end

post '/:band_uid/edit' do
    band = Band.find_by(uid: params[:band_uid])
    band.name = params[:band_name]
    band.save!
    redirect "/#{params[:band_uid]}/edit"
end

get '/:band_uid/create_music' do
#   @music = Music.find_by(id: params[:music_id]) 
    @band = Band.find_by(uid: params[:band_uid])

    erb :music_form
end

post '/:band_uid/music/new' do
   band = Band.find_by(uid: params[:band_uid])
   music = Music.create!(band_id: band.id, name: params[:music_name], artist: params[:artist], lyrics: params[:lyrics], norikata: params[:norikata], url: params[:music_url])
   setlist = Setlist.find_or_initialize_by(date: params[:date])

# music.id が nil でないことを確
    setlist.uid = band.uid
    if music.id
      setlist.musics ||= []  # nil の場合は初期化
      setlist.musics += [music.id] unless setlist.musics.include?(music.id)
      setlist.save!
    else
      puts "Error: music.id is nil!"
    end
    redirect "/#{params[:band_uid]}/edit"
end

get '/:band_uid/music/new' do
    @band = Band.find_by(uid: params[:band_uid])
   erb :music_form
end

get '/:band_uid/setlist/:setlist_id' do
    @band = Band.find_by(uid: params[:band_uid])
    @setlist_id = params[:setlist_id]
    setlist = Setlist.find_by(id: params[:setlist_id])
    @musics = setlist.musics
    erb :setlist
end

get '/:band_uid/audience' do
    @band = Band.find_by(uid: params[:band_uid])
    @setlists = Setlist.where(uid: @band.uid)
    erb :audience
end

get '/:band_uid/setlist/:setlist_id/audience' do
    @band = Band.find_by(uid: params[:band_uid])
    @setlist = Setlist.find_by(id: params[:setlist_id])
    @musics = @setlist.musics
    erb :audience2
end

# get '/delete/:id' do
#   music = Music.find_by(id: params[:id]) 
#   music.delete
# end

post '/:band_uid/setlist/:setlist_id/delete/:music_id' do
    music = Music.find_by(id: params[:music_id]) 
    music.delete
    redirect "/#{params[:band_uid]}/setlist/#{params[:setlist_id]}"
end

get '/:band_uid/setlist/:setlist_id/edit/:music_id' do
    @band = Band.find_by(uid: params[:band_uid])
    @music=Music.find_by(id: params[:music_id])
    @setlist = Setlist.find_by(id: params[:setlist_id])
    erb :music_edit
end


post '/:band_uid/setlist/:setlist_id/edit/:music_id/post' do
    music = Music.find_by(id: params[:music_id])
    music.update(name: params[:music_name], artist: params[:artist], lyrics: params[:lyrics], url: params[:url], norikata: params[:norikata])
    setlist = Setlist.find_by(id: params[:setlist_id])
    setlist.update(date: params[:date])
    redirect "/#{params[:band_uid]}/setlist/#{params[:setlist_id]}"
end
    
