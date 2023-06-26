require 'commonmarker'

class CommonmarkerFilter < Nanoc::Filter
  identifier :commonmarker

  def run(content, params={})
    Commonmarker.to_html(content, options:, plugins: {})
  end

  private

  def options
    @options ||= begin
      defaults = Commonmarker::Config::OPTIONS
      defaults.merge(
        parse: defaults[:parse].merge(unsafe: true, smart: true),
        render: defaults[:render].merge(hardbreaks: false, github_pre_lang: false),
        extension: defaults[:extension].merge(footnotes: true),
      )
    end
  end
end
