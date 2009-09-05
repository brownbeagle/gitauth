module GitAuth
  class Settings < Perennial::Settings
   
    def self.setup!(options = {})
      @@configuration = {}
      settings_file = self.default_settings_path
      if File.exist?(settings_file)
        loaded_yaml = YAML.load(File.read(settings_file))
        # We don't use the default namespace etc.
        @@configuration.merge!(loaded_yaml || {})
      end
      @@configuration.merge! options
      @@configuration.symbolize_keys!
      # Generate a module 
      mod = generate_settings_accessor_mixin
      extend  mod
      include mod
      @@setup = true
    end
    
  end
end