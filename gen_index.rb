require 'fileutils'
require 'cgi'
require 'find'
require 'erubis'
# USAGE: ruby script.rb input-dir domain-name
# 脚本进入dir，生成文件列表index.html


inputdir = File.expand_path ARGV[0] || '/tmp'
DOMAIN = ARGV[1] || 'http://example.com/'

def remove_index inputdir
  Find.find(inputdir) do |path|
    next unless File.basename(path) == 'index.html'
    p "remove #{path}"
    File.unlink path
  end
end

def gen_index dir
  Find.find(dir) do |f|
    next unless File.directory?(f)

    filelist = Dir.entries(f).reject! {|i| i == '.' or i == '..'}
    links = filelist.sort.map { |filename| [filename, CGI::escape(filename)] }
    #p links

    *_, title = f.to_s.split('/')

    # here comes erubis
    input = File.read('index.eruby')
    eruby = Erubis::Eruby.new(input)    # create Eruby object
    index_html =  eruby.result(binding())        # get result  

    # same old file writing
    p "generating #{f}/index.html"
    File.write("#{f}/index.html", index_html)
  end
end

p "DOMAIN is: #{DOMAIN}" 
remove_index inputdir # remove previously generated html
gen_index inputdir


