module AdminHelper
  require 'google_chart'
  
  def users_chart_url
    make_chart(User.find(:all, :order => "created_at ASC"), "Users")
  end
  
  def users_hours_chart_url
    make_hours_chart(User.find(:all, :order => "created_at ASC"), "Users")
  end

  def make_chart(array,name)
    num_of_users = array.length
    user_array = []
    current_date = Date.civil(y=2009,m=10,d=11)
    current_user = 0
    while current_date <= Date.today+1.days
      while current_user < num_of_users && array[current_user].created_at <= current_date
        current_user += 1
      end
      user_array.push([current_date-1.days,current_user])
      current_date += 1.days
    end    

    day_array = []
    users_array = []
    new_users_array = []
    for user in user_array
      day_array.push(user[0])
      users_array.push(user[1])
      new_users_array.push(user[1])
    end

    max = 0 
    for i in 0..new_users_array.length-1
      if i > 0
        new_users_array[i] -= users_array[i-1]
        if new_users_array[i] > max
          max = new_users_array[i]
        end
      end
#      new_users_array.push(users)
    end

    if day_array.length > 9
      day_array = [day_array.first, day_array.last]
    end  
    day_array = day_array.map {|x| x.strftime("%m/%d")}

    # Line Chart
    GoogleChart::LineChart.new('600x300', "#{name} Growth", false) do |lc|
      lc.data "#{name}", users_array, '0000ff'
      lc.show_legend = true
      lc.axis :y, :range => [0,num_of_users], :color => '000000', :font_size => 16, :alignment => :center
      lc.axis :x, :labels => day_array, :color => '000000', :font_size => 16, :alignment => :center
      @chart1_url = lc.to_url
    end
    GoogleChart::LineChart.new('600x300', "New #{name} Growth", false) do |lc|
      lc.data "New #{name}", new_users_array, 'ff0000'
      lc.show_legend = true
      lc.axis :y, :range => [0,max], :color => '000000', :font_size => 16, :alignment => :center
      lc.axis :x, :labels => day_array, :color => '000000', :font_size => 16, :alignment => :center
      @chart2_url = lc.to_url
    end
    return [@chart1_url, @chart2_url]
  end
  
  def make_hours_chart(array,name)
    num_of_users = array.length
    user_array = []
    current_date = Time.now - 24.hours
    current_user = 0
    while current_date <= Time.now
      while current_user < num_of_users && array[current_user].created_at <= current_date
        current_user += 1
      end
      user_array.push([current_date-1.hours,current_user])
      current_date += 1.hours
    end    

    day_array = []
    users_array = []
    new_users_array = []
    for user in user_array
      day_array.push(user[0])
      users_array.push(user[1])
      new_users_array.push(user[1])
    end

    max = 0
    for i in 0..new_users_array.length-1
      if i > 0
        new_users_array[i] -= users_array[i-1]
      else
        new_users_array[i] = 0 
      end
      if new_users_array[i] > max
        max = new_users_array[i]
      end  
#      new_users_array.push(users)
    end


    new_days = []
    day_array = day_array.map {|x| x.strftime("%I:%M%p")}
    for i in 0..new_users_array.length-1
      if i%4 == 0
        new_days.push(day_array[i])
      end
    end
    day_array = new_days

    # Line Chart
    GoogleChart::LineChart.new('600x300', "#{name} Growth", false) do |lc|
      lc.data "#{name}", users_array, '0000ff'
      lc.show_legend = true
      lc.axis :y, :range => [0,num_of_users], :color => '000000', :font_size => 16, :alignment => :center
      lc.axis :x, :labels => day_array, :color => '000000', :font_size => 16, :alignment => :center
      @chart1_url = lc.to_url
    end
    GoogleChart::LineChart.new('600x300', "New #{name} Growth", false) do |lc|
      lc.data "New #{name}", new_users_array, 'ff0000'
      lc.show_legend = true
      lc.axis :y, :range => [0,max], :color => '000000', :font_size => 16, :alignment => :center
      lc.axis :x, :labels => day_array, :color => '000000', :font_size => 16, :alignment => :center
      @chart2_url = lc.to_url
    end
    return [@chart1_url, @chart2_url]
  end
  
end
