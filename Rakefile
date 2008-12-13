# Rakefile
desc "Run all specs"
task :spec do
  spec_files = FileList['spec/*_spec.rb']
  spec_files.each do |file|
    ruby file
  end
end