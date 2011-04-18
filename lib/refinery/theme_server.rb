# Serves theme files from the theme directory without touching Rails.
module Refinery
  class ThemeServer

    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new(env)
      domain = req.host
      
      if env["PATH_INFO"] =~ /^\/theme\/(stylesheets|javascripts|images)/ and (theme = Theme.for_domain(domain)).present?
        env["PATH_INFO"].gsub!(/^\/theme\//, '')
        if (file_path = (dir = Theme.dir_for(domain)).join(env["PATH_INFO"])).exist?
          etag = Digest::MD5.hexdigest("#{file_path.to_s}#{file_path.mtime}")
          unless (etag == env["HTTP_IF_NONE_MATCH"])
            status, headers, body = Rack::File.new(dir).call(env)
            [status, headers.update({"ETag" => etag}), body]
          else
            [304, {"ETag" => etag}, []]
          end
        else
          [404, {}, []]
        end
      else
        @app.call(env)
      end
    end

  end
end
