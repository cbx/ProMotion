describe "screen properties" do

  before do

    # Simulate AppDelegate setup of main screen
    @screen = HomeScreen.new modal: true, nav_bar: true
    @screen.on_load

  end

  it "should store title" do
    HomeScreen.get_title.should == 'Home'
  end

  it "should set default title on new instances" do
    @screen.title.should == "Home"
  end

  it "should let the instance set its title" do
    @screen.title = "instance method"
    @screen.title.should == 'instance method'
  end

  it "should not let the instance reset the default title" do
    @screen.title = "instance method"
    HomeScreen.get_title.should != 'instance method'
  end

  it "should set the tab bar item with a system icon" do
    @screen.set_tab_bar_item system_icon: :contacts
    comparison = UITabBarItem.alloc.initWithTabBarSystemItem(UITabBarSystemItemContacts, tag: 0)
    @screen.tabBarItem.systemItem.should == comparison.systemItem
    @screen.tabBarItem.tag.should == comparison.tag
    @screen.tabBarItem.image.should == comparison.image
  end

  it "should set the tab bar item with a custom icon and title" do
    @screen.set_tab_bar_item title: "My Screen", icon: "list"

    icon_image = UIImage.imageNamed("list")
    comparison = UITabBarItem.alloc.initWithTitle("My Screen", image: icon_image, tag: 0)

    @screen.tabBarItem.systemItem.should == comparison.systemItem
    @screen.tabBarItem.tag.should == comparison.tag
    @screen.tabBarItem.image.should == comparison.image
  end

  it "should store debug mode" do
    HomeScreen.debug_mode = true
    HomeScreen.debug_mode.should == true
  end

  it "#modal? should be true" do
    @screen.modal?.should == true
  end

  it "should know it is the first screen" do
    @screen.first_screen?.should == true
  end

  it "#should_autorotate should default to 'true'" do
    @screen.should_autorotate.should == true
  end

  # Issue https://github.com/clearsightstudio/ProMotion/issues/109
  it "#should_autorotate should fire when shouldAutorotate fires when in a navigation bar" do
    parent_screen = BasicScreen.new(nav_bar: true)
    parent_screen.open @screen
    @screen.mock!(:should_autorotate) { true.should == true }
    parent_screen.navigationController.shouldAutorotate
  end

  # <= iOS 5 only
  it "#should_rotate(orientation) should fire when shouldAutorotateToInterfaceOrientation(orientation) fires" do
    @screen.mock!(:should_rotate) { |orientation| orientation.should == UIInterfaceOrientationMaskPortrait }
    @screen.shouldAutorotateToInterfaceOrientation(UIInterfaceOrientationMaskPortrait)
  end

  describe "iOS lifecycle methods" do

    it "-viewDidLoad" do
      @screen.mock!(:view_did_load) { true }
      @screen.viewDidLoad.should == true
    end

    it "-viewWillAppear" do
      @screen.mock!(:view_will_appear) { |animated| animated.should == true }
      @screen.viewWillAppear(true)
    end

    it "-viewDidAppear" do
      @screen.mock!(:view_did_appear) { |animated| animated.should == true }
      @screen.viewDidAppear(true)
    end

    it "-viewWillDisappear" do
      @screen.mock!(:view_will_disappear) { |animated| animated.should == true }
      @screen.viewWillDisappear(true)
    end

    it "-viewDidDisappear" do
      @screen.mock!(:view_did_disappear) { |animated| animated.should == true }
      @screen.viewDidDisappear(true)
    end

    it "-shouldAutorotateToInterfaceOrientation" do
      @screen.mock!(:should_rotate) { |o| o.should == UIInterfaceOrientationPortrait }
      @screen.shouldAutorotateToInterfaceOrientation(UIInterfaceOrientationPortrait)
    end

    it "-shouldAutorotate" do
      @screen.mock!(:should_autorotate) { true }
      @screen.shouldAutorotate.should == true
    end

    it "-willRotateToInterfaceOrientation" do
      @screen.mock! :will_rotate do |orientation, duration|
        orientation.should == UIInterfaceOrientationPortrait
        duration.should == 0.5
      end
      @screen.willRotateToInterfaceOrientation(UIInterfaceOrientationPortrait, duration: 0.5)
    end

    it "-didRotateFromInterfaceOrientation" do
      @screen.mock!(:on_rotate) { true }
      @screen.didRotateFromInterfaceOrientation(UIInterfaceOrientationPortrait).should == true
    end

  end

  describe "navigation controller behavior" do

    it "should have a nav bar" do
      @screen.nav_bar?.should == true
    end

    it "#navigationController should return a navigation controller" do
      @screen.navigationController.should.be.instance_of ProMotion::NavigationController
    end

    it "have a right bar button item" do
      @screen.navigationItem.rightBarButtonItem.should.not == nil
    end

    it "should have a left bar button item" do
      @screen.navigationItem.leftBarButtonItem.should.not == nil
    end

  end

  describe "bar button behavior" do
    describe "system bar buttons" do
      before do
        @screen.set_nav_bar_right_button nil, action: :add_something, system_icon: UIBarButtonSystemItemAdd
      end

      it "has a right bar button item of the correct type" do
        @screen.navigationItem.rightBarButtonItem.should.be.instance_of UIBarButtonItem
      end

      it "is an add button" do
        @screen.navigationItem.rightBarButtonItem.action.should == :add_something
      end
    end

    describe 'titled bar buttons' do
      before do
        @screen.set_nav_bar_right_button "Save", action: :save_something, style: UIBarButtonItemStyleDone
      end

      it "has a right bar button item of the correct type" do
        @screen.navigationItem.rightBarButtonItem.should.be.instance_of UIBarButtonItem
      end

      it "has a right bar button item of the correct style" do
        @screen.navigationItem.rightBarButtonItem.style.should == UIBarButtonItemStyleDone
      end

      it "is titled correctly" do
        @screen.navigationItem.rightBarButtonItem.title.should == 'Save'
      end
    end

    describe 'image bar buttons' do
      before do
        @image = UIImage.alloc.init
        @screen.set_nav_bar_right_button @image, action: :save_something, style: UIBarButtonItemStyleDone
      end

      it "has a right bar button item of the correct type" do
        @screen.navigationItem.rightBarButtonItem.should.be.instance_of UIBarButtonItem
      end

      it "is has the right image" do
        @screen.navigationItem.rightBarButtonItem.title.should == nil
      end
    end

    describe 'custom view bar buttons' do
      before do
        @activity = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleWhite)
        @screen.set_nav_bar_button :right, {custom_view: @activity}
      end

      it "has a right bar button item of the correct type" do
        @screen.navigationItem.rightBarButtonItem.should.be.instance_of UIBarButtonItem
        @screen.navigationItem.rightBarButtonItem.customView.should.be.instance_of UIActivityIndicatorView
      end
    end

  end

end

describe "screen with toolbar" do

  it "showing" do
    # Simulate AppDelegate setup of main screen
    screen = HomeScreen.new modal: true, nav_bar: true, toolbar: true
    screen.on_load
    screen.navigationController.toolbarHidden?.should == false
  end

  it "hidden" do
    screen = HomeScreen.new modal: true, nav_bar: true, toolbar: false
    screen.on_load
    screen.navigationController.toolbarHidden?.should == true
  end

  it "adds a single item" do
    screen = HomeScreen.new modal: true, nav_bar: true, toolbar: true
    screen.on_load
    screen.set_toolbar_button([{title: "Testing Toolbar"}])

    screen.navigationController.toolbar.items.should.be.instance_of Array
    screen.navigationController.toolbar.items.count.should == 1
    screen.navigationController.toolbar.items.first.should.be.instance_of UIBarButtonItem
    screen.navigationController.toolbar.items.first.title.should == "Testing Toolbar"
  end

  it "adds multiple items" do
    screen = HomeScreen.new modal: true, nav_bar: true, toolbar: true
    screen.set_toolbar_buttons [{title: "Testing Toolbar"}, {title: "Another Test"}]

    screen.navigationController.toolbar.items.should.be.instance_of Array
    screen.navigationController.toolbar.items.count.should == 2
    screen.navigationController.toolbar.items.first.title.should == "Testing Toolbar"
    screen.navigationController.toolbar.items.last.title.should == "Another Test"
  end

  it "shows the toolbar when setting items" do
    screen = HomeScreen.new modal: true, nav_bar: true, toolbar: false
    screen.on_load
    screen.navigationController.toolbarHidden?.should == true
    screen.set_toolbar_button([{title: "Testing Toolbar"}], false)
    screen.navigationController.toolbarHidden?.should == false
  end
end

