# frozen_string_literal: true

# Settings are saved in two database tables: Settings and HistoryValues.
# Due to the way the controller updates the settings, we cannot safely use ActiveRecord's callbacks (eg. after_update, after_commit...)
# so this service provides a wrapper around these operations.
class SettingService
  def after_update(setting)
    # update the stylesheet
    Stylesheet.theme&.rebuild! if %w[main_color secondary_color].include? setting.name
    Stylesheet.home_page&.rebuild! if setting.name == 'home_css'

    # notify about a change in privacy policy
    NotifyPrivacyUpdateWorker.perform_async(id) if setting.name == 'privacy_body'
  end
end
