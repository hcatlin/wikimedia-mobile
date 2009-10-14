module Merb
  module GlobalHelpers
    
    # helpers defined here available to all views.  
    # 
    def language_notice
      %|<div class="notice" id="language_notice"><h3>Language Not Fully Supported</h3>
        <p>
        The language that you are currently using is not fully supported
        with Wikipedia Mobile. We are working hard to ensure that all Wikipedia
        languages are supported on many mobile platforms. If you would like to volunteer
        to help with this language, please volunteer at <a href="http://www.translatewiki.net">TranslateWiki</a>.
        </p>
        <p>Your searches will be on <strong>#{request.language_code}.wikipedia.org</strong></p>
       </div>|
    end
    
    def go_text
      language_object["search_submit"] || "Go"
    end
    
    def button_to(text, to, id = nil)
      id ||= text.downcase
      %|<form method="get" action="#{to}"><button type="submit" id="#{id}Button">#{text}</button></form>|
    end

    def path_site
      %|http://#{request.language_code}.wikipedia.org|
    end

    def path_encoded(path)
      CGI::escape(path)
    end

    def temp_url(path)
      %|#{path_site}/w/mobileRedirect.php?to=#{path_site}/wiki/#{path_encoded(path)}|
    end

    def perm_url(path)
      %|#{temp_url(path)}&amp;expires_in_days=#{365 * 10}|
    end

    def action_url(path,action)
      %|#{path_site}/w/index.php?title=#{path_encoded(path)}&action=#{action}&useskin=chick|
    end

    def stop_redirect_notice(path)
%|<a href="#{temp_url(path)}">#{language_object["regular_wikipedia"]}</a>
  <div id="perm">
    <a href="#{perm_url(path)}">#{language_object["perm_stop_redirect"]}</a>
  </div>|
    end
    
  end
end

