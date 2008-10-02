module ActionController
  module Macros
    module LocalAutoComplete
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def local_auto_complete_for(object, method, options = {})
          define_method("auto_complete_for_#{object}_#{method}") do
            render :json => object.to_s.camelize.constantize.find(:all).map(&method).to_json
          end
        end
      end
    end
  end
end

module ActionView
  module Helpers
    module JavaScriptMacrosHelper
      def local_auto_complete_field(field_id, options={})
        div_id = "#{field_id}_auto_complete"
        url = options.delete(:url) or raise "url required"
        options = options.merge(:tokens => ',', :frequency => 0)
        js = javascript_tag <<-end
          new Ajax.Request('#{url}', {
            method: 'get',
              onSuccess: function(transport) {
                new Autocompleter.Local('#{field_id}', '#{div_id}', eval(transport.responseText), #{options.to_json});
              }
            });
        end
        content_tag('div', '', :id => div_id, :class => 'auto_complete') + js
      end

      def text_field_with_local_auto_complete(object, method, tag_options = {}, completion_options = {})
        (completion_options[:skip_style] ? "" : auto_complete_stylesheet) +
        text_field(object, method, tag_options) +
        local_auto_complete_field("#{object}_#{method}", :url => url_for(:action => "auto_complete_for_#{object}_#{method}"))
      end

      private

      def auto_complete_stylesheet
        content_tag('style', <<-EOT, :type => Mime::CSS)
          div.auto_complete {
            width: 350px;
            background: #fff;
          }
          div.auto_complete ul {
            border:1px solid #888;
            margin:0;
            padding:0;
            width:100%;
            list-style-type:none;
          }
          div.auto_complete ul li {
            margin:0;
            padding:3px;
          }
          div.auto_complete ul li.selected {
            background-color: #ffb;
          }
          div.auto_complete ul strong.highlight {
            color: #800; 
            margin:0;
            padding:0;
          }
        EOT
      end
    end
  end
end
