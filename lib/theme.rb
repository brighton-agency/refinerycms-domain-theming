module Theme
  class << self
    def root
      Pathname.new( File.expand_path('../../', __FILE__) )
    end
    
    def for_domain(domain)
      NppNaturaSites::Application.config.theme_mapping[domain]
    end

    def dir_for(domain)
      theme = for_domain(domain)
      theme_dir = Rails.root.join("themes",theme)
      theme_dir = self.root.join('themes', theme) unless theme_dir.directory?
      theme_dir
    end
  end
end
