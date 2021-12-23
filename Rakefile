require 'rake/testtask'

desc 'Say hello'
task :hello do
  puts "Hello there. This is the 'hello' task."
end

desc 'Default'
task :default do
  puts "this is the default task"
end

desc 'Reserialize word graph'
task :serialize do
  ruby "./lib/serialize_graph.rb"
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end
