# frozen_string_literal: true

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
        parse: defaults[:parse].merge(smart: true),
        render: defaults[:render].merge(unsafe: true, hardbreaks: false, github_pre_lang: false),
        extension: defaults[:extension].merge(footnotes: true, header_ids: nil),
      )
    end
  end
end
