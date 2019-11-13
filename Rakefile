$yellow_begin = "\033[01;33m"
$green_begin = "\033[01;32m"
$red_begin = "\033[01;31m"
$color_end = "\033[00m"
$succeeded = "#{$green_begin}SUCCEEDED#{$color_end}"
$failed = "#{$red_begin}FAILED#{$color_end}"

desc 'Start the bot'
task :default do
    sh 'bundle exec ruby src/SmarterChild.rb'
end

desc 'Install requirements'
task :install do
  sh 'gem install bundler --conservative'
  sh 'bundle update'
end

desc 'Update from Github repo'
task :update do
  sh 'git stash save -u'
  sh 'git pull'
end

namespace :db do
    desc "Creates default tables"
    task :create => :pg_conn do
        puts "Creating tables"

        FileList['db/*_table.sql'].each do |table|
            base_table_name = table.gsub(/\.*_table.sql$/, '').gsub(/^db\/\w{3}/, '')

            begin
                $db_conn.exec File.open(table).read
            rescue PG::Error
                puts "Creating #{base_table_name} table"
                puts $failed
                raise
            else
                puts "Creating #{base_table_name} table"
                puts $succeeded
            end
        end
    end

    desc "Drops all tables"
    task :drop => :pg_conn do 
        puts "Dropping all tables"
        begin
            $db_conn.exec File.open('db/drop_tables.sql').read
        rescue PG::Error
            puts $failed
            raise
        else
            puts $succeeded
        end
    end
end

task :pg_conn do
    require 'pg'
    require 'dotenv/load'

    puts "Connecting to #{ENV['DB_NAME']}"
    $db_conn = PG::Connection.open(:dbname => ENV['DB_NAME'], :user => ENV['DB_USER'])
end