require 'sinatra'

class PuppyRun < Sinatra::Base
  %w[hitbox bandcamp].each { |job|
    require "./lib/jobs/#{job}.rb"
  }

  JOBS = Jobs.constants.map(&Jobs.method(:const_get))

  JOBS.each { |job|
    job.new.spawn_update_loop!
  }

  TITLES = {
    stream: 'Live Streams',
    code: 'Code',
    music: 'Music',
  }

  def streaming?
    Jobs::Hitbox.streaming?
  end

  def generate_kwargs(view, page=nil)
    bc = Jobs::Bandcamp

    {
      layout: :default,
      locals: {
        title: TITLES[view],
        page: page || view.to_s,
        is_streaming: streaming?,
        album_date: bc.album_date,
        album_id: bc.album_id,
        album_slug: bc.album_slug,
        album_name: bc.album_name,
      }
    }
  end

  set :public_folder, File.dirname(__FILE__) + '/static'

  get '/' do
    view = JOBS.sort_by(&:updated_at).last.view

    erb view,
      **generate_kwargs(view, 'home')
  end

  get '/stream' do
    erb :stream,
      layout: :default,
      locals: {
        title: 'Live Streams',
        page: 'stream',
        is_streaming: streaming?,
      }
  end

  get '/code' do
    erb :code,
      layout: :default,
      locals: {
        title: 'Code',
        page: 'code',
        is_streaming: streaming?,
      }
  end

  get '/music' do
    bc = Jobs::Bandcamp

    erb :music,
      layout: :default,
      locals: {
        title: 'Music',
        page: 'music',
        is_streaming: streaming?,
        album_date: bc.album_date,
        album_id: bc.album_id,
        album_slug: bc.album_slug,
        album_name: bc.album_name,
      }
  end
end

