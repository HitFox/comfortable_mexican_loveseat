module ComfortableMexicanLoveseat
  class Engine < ::Rails::Engine
    initializer "redirect trailing slash urls" do |app|
      app.middleware.insert_before(Rack::Lock, Rack::Rewrite) do
        r301 %r{^/(.*)/$}, '/$1'
      end
    end
  end
end
