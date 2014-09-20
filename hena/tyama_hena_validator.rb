#!/usr/bin/env ruby
require 'rubygems'
require 'multisax'
require 'net/http'
require 'uri'

def hena5(s)
	s.split(',').map{|e|e.scan(/../).sort}.sort
end

URLS={
	#'codeiq1'=>'codeiq/cardgame',
	'codeiq2'=>'codeiq/tetromino_bingo',
	#'codeiq3'=>'codeiq/octahedron', # IO is provided via text
	#'codeiq4'=>'codeiq/incseq',

	'1'=>'hena/1',
	'2'=>'hena/ord2',
	'3'=>'hena/ord3ynode',
	'4'=>'hena/ord4tetroid',
	'5pre'=>'hena/ord5railsontiles',
	'5'=>'hena/ord5dahimi',
	'6pre'=>'hena/ord6lintersection',
	'6'=>'hena/ord6kinship',
	'7pre'=>'hena/ord7xysort',
	'7'=>'hena/ord7selectchair',
	'8pre'=>'hena/ord8entco',
	'8'=>'hena/ord8biboma',
	'9pre'=>'hena/ord9nummake',
	'9'=>'hena/ord9busfare',
	'10pre'=>'hena/ord10pokarest',
	'10'=>'hena/ord10haniwa',
	'11pre'=>'hena/ord11arithseq',
	'11'=>'hena/ord11bitamida',
	'12pre'=>'hena/ord12aloroturtle',
	'12'=>'hena/ord12rotdice',
	'13pre'=>'hena/ord13updowndouble',
	'13'=>'hena/ord13blocktup',
	'14pre'=>'hena/ord14crosscircle',
	'14'=>'hena/ord14linedung',
	'15pre'=>'hena/ord15subpalin',
	'15'=>'hena/ord15elebubo',
	'16pre'=>'hena/ord16lcove',
	'16'=>'hena/ord16boseg',
	'17pre'=>'hena/ord17scheherazade',
	'17'=>'hena/ord17foldcut',
	'18pre'=>'hena/ord18mafovafo',
	'18'=>'hena/ord18notfork',
	'19pre'=>'hena/ord19sanwa',
	'19'=>'hena/ord19nebasec',
	'20'=>'hena/ord20meetime',
	#'21'=>'http://d.hatena.ne.jp/torazuka/20140509/yhpg', #HTML on Blogs not supported.
	'22'=>'hena/ord22irrpas',
	'23'=>'hena/ord23snakemoinc',
	'24'=>'hena/ord24eliseq',
	'25'=>'hena/ord25rotcell',
}
if ARGV.size<1
	puts 'validator program [identifier]'
	puts 'If identifier is not present, I will use stdin.'
end
if ARGV.size<2
	body=STDIN.read
else
	if !URLS.has_key?(ARGV[1])
		puts 'URL wrong: '+ARGV[1]
		exit
	end
	flag5=true if ARGV[1]=='5'
	uri=URI.parse('http://nabetani.sakura.ne.jp/'+URLS[ARGV[1]]+'/')
	body=''
	Net::HTTP.start(uri.host){|http|
		body=http.get(uri.path).body
	}
end
#table section contains only tags which are also valid as XML.
body.gsub!(/\<table class='bibo_s'\>.*?\<\/table\>/m,'table')
body.gsub!(/\<img[^\>]*\>/,'img')
body.gsub!(/\<small.*?\<\/small\>/m,'')
xml='<table'+body.split('<table').last.split('</table>').first+'</table>'
listener=MultiSAX::Sax.parse(xml,Class.new{
	include MultiSAX::Callbacks
	def initialize
		@content=[]
		@current_tag=[]
		@first=true
		@fold=0
	end
	attr_reader :content, :fold

	def sax_tag_start(tag,attrs)
		@current_tag.push(tag)
	end
	def sax_tag_end(tag)
		if (t=@current_tag.pop)!=tag then raise "xml is malformed /#{t}" end
		@first=false if t=='tr'
	end
	def sax_cdata(text)
	end
	def sax_text(text)
		text.strip!
		@content << text if text.size>0
		@fold+=1 if @first
	end
	def sax_comment(text)
	end
}.new)
data=listener.content.each_slice(listener.fold).to_a
data=data.map{|e|e[(data[0][0]=='#')?1:0,2]}[1..-1]
IO.popen(ARGV[0],'r+b'){|io|
	data.each{|e|io.puts e[0]}
	io.close_write
	data.each_with_index{|e,i|
		print 'Case '+(i).to_s+': '
		puts (flag5 ? hena5(io.gets.chomp)==hena5(e[1]) : io.gets.chomp==e[1])?'OK':'NG'
	}
}