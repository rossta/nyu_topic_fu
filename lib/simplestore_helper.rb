require File.dirname(__FILE__) + '/../../rspec/spec/spec_helper'
require 'spec/fixtures'

module SimplestoreHelper
  attr_accessor :exit_status, :stdout
  
  def simplestore(option = nil, opts = {})
    cmd = build_command(option, opts)
    @exit_status = run_command(cmd)
    @stdout = read_stdout
    read_stderr
  end
  
  def build_command(option = nil, opts = {})
    cmd = "#{SCRIPT}"
    cmd += " #{option}" if option
    cmd += " #{opts[:key]}" if opts[:key]
    cmd += " '#{opts[:value]}'" if opts[:value]
    
    cmd = "#{opts[:pipe]} | #{cmd}" if opts[:pipe]
    cmd = "#{cmd} < #{opts[:from_file]}" if opts[:from_file]
    cmd = "#{cmd} > #{opts[:to_file]}" if opts[:to_file]
    
    cmd 
  end
  
  def run_command(cmd)
    exit = `#{cmd} 1>#{OUT_LOG} 2> #{ERR_LOG} ; echo $?;`
    exit.chomp.to_i
  end
  
  def read_stdout
    `cat #{OUT_LOG}`
  end
  
  def read_stderr
    `cat #{ERR_LOG}`
  end
  
  def simplestore_write(key = nil, value = nil)
    simplestore("write", :key => key, :value => value)
  end
  
  def simplestore_write_stdin(key = nil, value = nil)
    simplestore("write", :key => key, :value => value)
  end
  
  def simplestore_lookup(key = nil, value = nil)
    simplestore("lookup", :key => key, :value => value)
  end

  def simplestore_delete(key = nil)
    simplestore("delete", :key => key)
  end

  def simplestore_inc(key = nil, value = nil)
    simplestore("increment", :key => key, :value => value)
  end
  
  def simplestore_import(*files)
    files = files.join(" ")
    simplestore("import", :from_file => files)
  end
  
  def simplestore_export(key = nil, file = nil)
    simplestore("export", :key => key, :to_file => file)
  end

  def smush(string)
    string.gsub(/ /, "")
  end
  
  def readline(file)
    File.open(file).readline.chomp
  end
  
  def hash_to_csv(hash)
    file = []
    hash.each { |key, value| file << "#{key},#{value}"}
    file.sort.join("\n") + "\n"
  end
  
  def symlink(file, link)
    `ln -s #{file} #{link}`
  end
  
  def remove_link(link)
    `rm #{link}`
  end
  
  def clear_test_dir
    `rm -rf #{TEST_DIR}/* -p w39lay`
  end
  
  def remove_home_dir
    `rm -rf #{TEST_DIR}`
  end
  
  def symlink_home_dir
    `ln -s #{HOME_DIR} #{STUDENT_ID}`
  end
end
