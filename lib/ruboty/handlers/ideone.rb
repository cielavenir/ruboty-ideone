#coding:utf-8
require 'rubygems'
require 'savon'

LANGUAGES=[
	{:key=>"7", :value=>"Ada (gnat-4.6)"},
	{:key=>"13", :value=>"Assembler (nasm-2.10.01)"},
	{:key=>"45", :value=>"Assembler (gcc-4.8.1)"},
	{:key=>"104", :value=>"AWK (gawk) (gawk-3.1.6)"},
	{:key=>"105", :value=>"AWK (mawk) (mawk-1.3.3)"},
	{:key=>"28", :value=>"Bash (bash 4.0.35)"},
	{:key=>"110", :value=>"bc (bc-1.06.95)"},
	{:key=>"12", :value=>"Brainf**k (bff-1.0.3.1)"},
	{:key=>"11", :value=>"C (gcc-4.8.1)"},
	{:key=>"27", :value=>"C# (mono-2.8)"},
	{:key=>"41", :value=>"C++ 4.3.2 (gcc-4.3.2)"},
	{:key=>"1", :value=>"C++ 4.8.1 (gcc-4.8.1)"},
	{:key=>"44", :value=>"C++11 (gcc-4.8.1)"},
	{:key=>"34", :value=>"C99 strict (gcc-4.8.1)"},
	{:key=>"14", :value=>"CLIPS (clips 6.24)"},
	{:key=>"111", :value=>"Clojure (clojure 1.5.0-RC2)"},
	{:key=>"118", :value=>"COBOL (open-cobol-1.0)"},
	{:key=>"106", :value=>"COBOL 85 (tinycobol-0.65.9)"},
	{:key=>"32", :value=>"Common Lisp (clisp) (clisp 2.47)"},
	{:key=>"102", :value=>"D (dmd) (dmd-2.042)"},
	{:key=>"36", :value=>"Erlang (erl-5.7.3)"},
	{:key=>"124", :value=>"F# (fsharp-2.0.0)"},
	{:key=>"123", :value=>"Factor (factor-0.93)"},
	{:key=>"125", :value=>"Falcon (falcon-0.9.6.6)"},
	{:key=>"107", :value=>"Forth (gforth-0.7.0)"},
	{:key=>"5", :value=>"Fortran (gfortran-4.8)"},
	{:key=>"114", :value=>"Go (1.0.3)"},
	{:key=>"121", :value=>"Groovy (groovy-2.1.6)"},
	{:key=>"21", :value=>"Haskell (ghc-7.6.3)"},
	{:key=>"16", :value=>"Icon (iconc 9.4.3)"},
	{:key=>"9", :value=>"Intercal (c-intercal 28.0-r1)"},
	{:key=>"10", :value=>"Java (sun-jdk-1.7.0_25)"},
	{:key=>"55", :value=>"Java7 (sun-jdk-1.7.0_10)"},
	{:key=>"35", :value=>"JavaScript (rhino) (rhino-1.7R4)"},
	{:key=>"112", :value=>"JavaScript (spidermonkey) (spidermonkey-1.7)"},
	{:key=>"26", :value=>"Lua (luac 5.1.4)"},
	{:key=>"30", :value=>"Nemerle (ncc 0.9.3)"},
	{:key=>"25", :value=>"Nice (nicec 0.9.6)"},
	{:key=>"122", :value=>"Nimrod (nimrod-0.8.8)"},
	{:key=>"56", :value=>"Node.js (0.8.11)"},
	{:key=>"43", :value=>"Objective-C (gcc-4.5.1)"},
	{:key=>"8", :value=>"Ocaml (ocamlopt 3.10.2)"},
	{:key=>"127", :value=>"Octave (3.6.2)"},
	{:key=>"119", :value=>"Oz (mozart-1.4.0)"},
	{:key=>"57", :value=>"PARI/GP (2.5.1)"},
	{:key=>"22", :value=>"Pascal (fpc) (fpc 2.6.2)"},
	{:key=>"2", :value=>"Pascal (gpc) (gpc 20070904)"},
	{:key=>"3", :value=>"Perl (perl 5.16.2)"},
	{:key=>"54", :value=>"Perl 6 (rakudo-2010.08)"},
	{:key=>"29", :value=>"PHP (php 5.4.4)"},
	{:key=>"19", :value=>"Pike (pike 7.6.86)"},
	{:key=>"108", :value=>"Prolog (gnu) (gprolog-1.3.1)"},
	{:key=>"15", :value=>"Prolog (swi) (swipl 5.6.64)"},
	{:key=>"4", :value=>"Python (python 2.7.3)"},
	{:key=>"116", :value=>"Python 3 (python-3.2.3)"},
	{:key=>"117", :value=>"R (R-2.11.1)"},
	{:key=>"17", :value=>"Ruby (ruby-1.9.3)"},
	{:key=>"39", :value=>"Scala (scala-2.10.2)"},
	{:key=>"33", :value=>"Scheme (guile) (guile 1.8.5)"},
	{:key=>"23", :value=>"Smalltalk (gst 3.1)"},
	{:key=>"40", :value=>"SQL (sqlite3-3.7.3)"},
	{:key=>"38", :value=>"Tcl (tclsh 8.5.7)"},
	{:key=>"62", :value=>"Text (text 6.10)"},
	{:key=>"115", :value=>"Unlambda (unlambda-2.0.0)"},
	{:key=>"101", :value=>"VB.NET (mono-2.4.2.3)"},
	{:key=>"6", :value=>"Whitespace (wspace 0.3)"}
]

#クラス変数を使いたいので、Actionを切り出すことは不可能
module Ruboty
	module Handlers
		class Ideone < Base
			def initialize(*__reserved__)
				super
				@client==Savon.client(log:false,wsdl:'http://ideone.com/api/1/service.wsdl')
				@user=ENV['IDEONE_USER']
				@pass=ENV['IDEONE_PASS']
				@current_submission=nil

				@languages=LANGUAGES
			end

			on /ideone languages/, name: 'languages', description: 'show languages'
			on /ideone submit (?<language>\w+) (?<uri>\w+)/, name: 'submit', description: 'send code via url'
			on /ideone view ?(?<id>\w*)/, name: 'view', description: 'view submission'
			def languages(message)
				resp=@client.call(:get_languages,message:{user:@user,pass:@pass})
				item=resp.body[:get_languages_response][:return][:item][1][:value]
				if item&&item[:item]
					message.reply item[:item].map{|e|"#{e[:key]}: #{e[:value]}\n"}.join
				end
			end
			def submit(message)
				#guess lang
				lang=message[:language]
				if lang.to_i>0
					lang=lang.to_i
				else
					lang=lang.downcase.gsub(/\W/,'')
					lang=@languages.max_by{|e|
						_e=e.downcase.gsub(/\W/,'')
						(lang.size-1).downto(0).find{|i|_e.begin_with?(lang[0,i])}
					}[:key].to_i
				end
				resp=@client.call(:create_submission,message:{user:@user,pass:@pass,source_code:source_str,input:input,run:true,private:true,language:lang})
				result=Hash[*resp.body[:create_submission_response][:return][:item].flat_map{|e|[e[:key],e[:value]]}]
				if result['error']!='OK'
					message.reply 'something wrong happened in submission'
				else
					@current_submission=result['link']
					message.reply 'http://ideone.com/'+result['link']
				end
			end
			def view(message)
				resp=client.call(:get_submission_details,message:{user:USER,pass:PASS,link:message[:id]||@current_submission,with_output:true})
				result=Hash[*resp.body[:get_submission_details_response][:return][:item].flat_map{|e|[e[:key],e[:value]]}]
				message.reply result.inspect
			end
		end
	end
end
