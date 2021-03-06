class PackagePusherController < ApplicationController
  
  def index
    @package_manufacturer != ""
    @package_name != ""
    @package_version != ""
  end
  def push
    smsServerRecord = ContentServer.find(:first)
    smsServer = smsServerRecord.contentServerObject()
    flash[:error] = nil
    flash[:notice] = nil
    
    if (params[:computer_id] && (params[:computer_id] != "other"))
      computer = SmsComputer.findOrCreate(params[:computer_id], smsServer)
      computer_entry = Array.new(2)
      computer_entry[0] = computer
      computer_entry[1] = 999
      computersList = Array.new(1)
      computersList[0] = computer_entry
    else
      computerList = searchForComputersByKeyword(params[:computer_query])
      unless(computerList.length != 1)
        computer = computerList[0]
        @computer_id = computer.remote_id
        computersList = Array.new(1)
        computersList[0] = computer
      else
        if (computerList.size == 0)
          flash[:error] = "No computer matches the query"
        else
          flash[:error] = "Not specific enough - too many results of computers"
          computersList = computerList
        end
      end
    end
    
    if (params[:package_id] && (params[:package_id] != "other"))
      puts "Package ID is set?!"
      package = SmsPackage.findOrCreate(params[:package_id], smsServer)
      @package_id = params[:package_id]
      packagesList = Array.new(1)
      packagesList[0] = package
    else
      packagesList = searchForPackagesByKeyword(params[:package_query])
      unless(packagesList.length != 1)
        package = packagesList[0][0]
        @package_id = package.remote_id
        packagesList = Array.new(1)
        packagesList[0] = package
      else
        if (packagesList.size == 0)
          flash[:error] = "No package matches the query"
        else
          flash[:error] = "Not specific enough - too many packages match"
          
        end
      end
    end
    
    unless(flash[:error])
      collection_name = "109_" + Time.now.gmtime.strftime("%m%d%Y%H%M%S") + "_" + smsServer.username
      parentCollectionList = smsServer.findComputerGroupsByName("Distribution")
      parentCollection = parentCollectionList[0]
      collection = smsServer.createComputerGroup(collection_name, parentCollection, smsServer.username)
      collection.addComputer(computer)
      @collection_id = collection.remote_id
    
      taskList = package.tasks
      task = taskList[0]
    
      advertisement_name = "109_" + Time.now.gmtime.strftime("%m%d%Y%H%M%S") + "_PKG" + @package_id
      advertisement = collection.executeTask(task, advertisement_name)
      @advertisement_id = advertisement.remote_id
      flash[:notice] = "Created Adveristement " + @advertisement_id
    else
      @computersList = computersList
      @packagesList = packagesList
    end
    
    render :action => 'index'
  end
end
