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
    
    def self.update!(hash)
      settings_file = self.default_settings_path
      settings = File.file?(settings_file) ? YAML.load(File.read(settings_file)) : {}
      hash.each_pair { |k,v| settings[k.to_s] = v }
      File.open(settings_file, "w+") { |f| f.write(settings.to_yaml) }
      setup!
    end
    
  end
end