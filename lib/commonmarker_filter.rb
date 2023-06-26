require 'commonmarker'

class CommonmarkerFilter < Nanoc::Filter
  identifier :commonmarker

  def run(content, params={})
    Commonmarker.to_html(content, options:)
  end

  private

  def options
    @options ||= begin
      defaults = Commonmarker::Config::OPTIONS
      defaults.merge(
        parse: defaults[:parse].merge(unsafe: true, smart: true),
        render: defaults[:render].merge(hardbreaks: false),
        extension: defaults[:extension].merge(footnotes: true),
      )
    end
  end
end
