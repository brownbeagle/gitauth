module GitAuth
  def self.SaveableClass(kind)
    klass = Class.new
    path_name = "#{kind.to_s.upcase}_PATH"
    yaml_file_name = "#{kind}.yml"
    
    saveable_class_def = <<-END
    
      #{path_name} = File.join(GitAuth::GITAUTH_DIR, #{yaml_file_name.inspect})
    
      def self.all
        @@all_#{kind} ||= nil
      end
      
      def self.all=(value)
        @@all_#{kind} = value
      end
      
      def self.load!
        self.all = YAML.load_file(#{path_name}) rescue nil if File.exist?(#{path_name})
        self.all = [] unless self.all.is_a?(Array)
      end

      def self.save!
        load! if self.all.nil?
        File.open(#{path_name}, "w+") do |f|
          f.write self.all.to_yaml
        end
      end
    
    END
    klass.class_eval(saveable_class_def)
    return klass
  end
end