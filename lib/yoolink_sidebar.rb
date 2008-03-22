class YoolinkSidebar < Sidebar
  display_name "Yoolink"
  description 'Bookmarks from <a href="http://yoolink.fr">Yoolink</a>'

  setting :login, nil, :label => 'Login'
  setting :count, 10, :label => 'Items Limit'
  setting :groupdate,   false, :input_type => :checkbox, :label => 'Group links by day'
  setting :description, false, :input_type => :checkbox, :label => 'Show description'
  setting :desclink,    false, :input_type => :checkbox, :label => 'Allow links in description'

  lifetime 1.hour

  def yoolink
    require 'ruby-debug'
    #debugger
    @yoolink ||= Yoolink.new("http://yoolink.fr/people/#{login}/rss") rescue nil
  end

  def parse_request(contents, params)
    return unless yoolink

    if groupdate
      @yoolink.days = {}
      @yoolink.items.each_with_index do |d,i|
        break if i >= count.to_i
        index = d.date.strftime("%Y-%m-%d").to_sym
        (@yoolink.days[index] ||= []) << d
      end
      @yoolink.days =
        @yoolink.days.sort_by { |d| d.to_s }.reverse.collect do |d|
        {:container => d.last, :date => d.first}
      end
    else
      @yoolink.items = @yoolink.items.slice(0, count.to_i)
    end
  end
end
