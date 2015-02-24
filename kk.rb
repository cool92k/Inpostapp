require 'sinatra'
require 'data_mapper'
require 'dm-migrations'

if Sinatra::Base.production?
	DataMapper::setup(:default, "postgres://wakhurrrlmkewu:TyNE-TE1RyqIMTYfzqgXB2Hf-P@ec2-50-17-202-29.compute-1.amazonaws.com:5432/d40tjkvuuga6lu")
else
	DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/package_schedule.db")
end

class Package
	include DataMapper::Resource
	
	property :id, Serial
	property :first_name, String, :required => true
	property :last_name, String, :required => true
	property :email, String, :required => true
	property :address_type, String, :required => true
	property :address, Text, :required => true
	property :number_type, String, :required => true
	property :number, Integer, :required => true, :min => 0, :max => 281474976710656
	property :created, DateTime, :required => true

	has 1, :schedule
end

class Schedule
	include DataMapper::Resource
	
	property :id, Serial
	property :date, String, :required => true
	property :time, String, :required => true
	property :weight, Integer, :required => true
	property :created, DateTime, :required => true
	
	belongs_to :package, :required => true
end

DataMapper.finalize.auto_upgrade!

get "/" do
	redirect "/step1"
end

get "/step1" do
	erb :exp1
end

get "/step2/:package_id" do
	@psid = params[:package_id]
	erb :exp2
end

get "/step3/:package_id" do
	psid = params[:package_id]
	@package = Package.get(psid)
	erb :exp3
end

post "/step1" do
	new_package = {:first_name=>params["first_name"], :last_name=>params["last_name"], :email=>params["email"], 
				:address_type=>params["address_type"], :address=>params["address"], :number_type=>params["number_type"], 
				:number=>params["number"], :created=>Time.now}
	package_resp = Package.new(new_package)
	package_resp.save
	puts package_resp.inspect
	redirect "/step2/#{package_resp.id}"
end

post "/step2/:package_id" do
	puts params
	new_schedule = {:package_id=>params["package_id"], :date=>params["date"], :time=>params["time"], :weight=>params["weight"], :created=>Time.now}
	schedule = Schedule.new(new_schedule)
	resp = schedule.save
	puts resp
	redirect "/step3/#{params["package_id"]}"
end
