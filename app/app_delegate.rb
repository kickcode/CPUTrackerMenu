class AppDelegate
  attr_accessor :status_menu

  def applicationDidFinishLaunching(notification)
    @app_name = NSBundle.mainBundle.infoDictionary['CFBundleDisplayName']

    @status_menu = NSMenu.new

    @status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength).init
    @status_item.setMenu(@status_menu)
    @status_item.setHighlightMode(true)

    @total_item = createMenuItem("Total", 'clickTotal')
    @total_item.checked = true
    @status_menu.addItem(@total_item)

    @user_item = createMenuItem("User", 'clickUser')
    @user_item.checked = false
    @status_menu.addItem(@user_item)

    @system_item = createMenuItem("System", 'clickSystem')
    @system_item.checked = false
    @status_menu.addItem(@system_item)

    @status_menu.addItem createMenuItem("About #{@app_name}", 'orderFrontStandardAboutPanel:')
    @status_menu.addItem createMenuItem("Quit", 'terminate:')

    @user = 0
    @sys = 0
    self.updateStatus

    self.performSelectorInBackground('startTop', withObject: nil)
  end

  def createMenuItem(name, action)
    NSMenuItem.alloc.initWithTitle(name, action: action, keyEquivalent: '')
  end

  def clickTotal
    @user_item.checked = false
    @system_item.checked = false
    @total_item.checked = true
    self.updateStatus
  end

  def clickUser
    @total_item.checked = false
    @user_item.checked = !@user_item.checked
    self.mustSelectSomething
    self.updateStatus
  end

  def clickSystem
    @total_item.checked = false
    @system_item.checked = !@system_item.checked
    self.mustSelectSomething
    self.updateStatus
  end

  def mustSelectSomething
    @total_item.checked = true if !@user_item.checked && !@system_item.checked
  end

  def updateStatus
    if @total_item.checked
      @status_item.setTitle("CPU: #{sprintf("%.2f", @user + @sys)}%")
    else
      text = []
      text << "User: #{sprintf("%.2f", @user)}%" if @user_item.checked
      text << "Sys: #{sprintf("%.2f", @sys)}%" if @system_item.checked
      @status_item.setTitle(text.join(", "))
    end
  end

  def startTop
    IO.popen("top -l 0") do |f|
      while true
        unless((line = f.gets).nil?)
          if line[0...10] == 'CPU usage:'
            line.gsub!("CPU usage: ", "")
            line.split(", ")
            @user, @sys = line.split(", ").map { |p| p.split("%").first.to_f }
            self.updateStatus
          end
        end
      end
    end
  end
end