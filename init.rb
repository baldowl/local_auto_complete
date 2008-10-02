require 'local_auto_complete'

ActionController::Base.send(:include, ActionController::Macros::LocalAutoComplete)
ActionController::Base.helper ActionView::Helpers::JavaScriptMacrosHelper
