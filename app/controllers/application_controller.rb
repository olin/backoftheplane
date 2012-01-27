# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
    
  def bing_query(query)
    require 'net/http'
    require 'uri'
    app_id = 'B3FD07EF9E28F0F32947C1465D8F3A1227777D7A'
    res = Net::HTTP.get_response(URI.parse('http://api.bing.net/json.aspx?AppId='+app_id+'&Query='+URI.escape(query)+'&Sources=InstantAnswer'))
    return ActiveSupport::JSON.decode(res.body)
  end
end
