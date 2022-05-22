desc 'compile into js'
task :default do
  sh 'bundle exec opal -c -g ovto app.rb > app.js'
end

desc 'start auto-compiling'
task :watch do
  sh 'ifchanged app.rb -d "bundle exec rake"'
end

desc 'make combined.html'
task :combine do
  sh 'bundle exec opal -c --no-source-map -g ovto app.rb > combine/js'
  sh 'terser combine/js > combine/body'
  sh 'cat combine/header combine/body combine/footer > combined.html'
end
