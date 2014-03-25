description "<%= description %>"

maintainer "<%= maintainer %>"
maintainer_email "<%= maintainer_email %>"
license "Apache v2.0"

<% platforms.each do |platform| %>
supports "<%= platform %>"
<% end %>
