require 'nokogiri'


class TocFilter < Nanoc::Filter
  identifier :toc

  @@current_toc = nil

  def self.current_toc(item)
    @@current_toc&.[](item)
  end

  def run(content, params={})
    doc = Nokogiri::HTML5.fragment(content)

    if footnotes = doc.css("section.footnotes")[0]
      footnotes[:id] = "footnotes"
      h2 = footnotes.prepend_child("<h2>")[0]
      h2.inner_html = "Footnotes"
    end

    toc = []
    levels = []

    seen_ids = Set.new(["top"])
    back_to_top = item[:back_to_top] || "top"

    doc.css("h1, h2, h3, h4, h5, h6").each do |header|
      id = header.parent[:id]
      text = header.accept(CollectTextVisitor.new)
      next if id.nil? || text.empty? || seen_ids.include?(id)

      level = header.name[1].to_i
      while levels[-1] != level
        if levels.empty? || level > levels[-1]
          levels << level
        else
          levels.pop while levels.any? && level < levels[-1]
        end
      end

      toc << {text:, href: "##{id}", depth: levels.length}

      permalink = header.add_child(" <a>")[1]
      permalink[:href] = "##{id}"
      permalink[:"aria-hidden"] = true
      permalink[:title] = "Permalink to section"
      permalink[:class] = "anchor"
      permalink.inner_html = "🔗"

      if seen_ids.include?(back_to_top)
        backlink = header.add_child(" <a>")[1]
        backlink[:href] = "##{back_to_top}"
        backlink[:"aria-hidden"] = true
        backlink[:title] = "Back to #{back_to_top}"
        backlink[:class] = "anchor"
        backlink.inner_html = "↩"
      end

      seen_ids << id
    end

    if toc.any?
      @@current_toc = {item => toc}
    end

    doc.to_s
  end

  class CollectTextVisitor
    def initialize
      @text = +""
    end

    def visit(node, root: true)
      if node.text?
        @text << node.text
      elsif node.name == "a"
        # pass
      else
        node.children.each { |child| visit(child, root: false) }
      end

      @text.strip.freeze if root
    end
  end
end

module TocHelper
  def toc
    TocFilter.current_toc(item)
  end

  def toc_walker(&blk)
    toc = self.toc

    current_depth = 1
    toc.each do |entry|
      entry => depth:, text:, href:

      first = false

      while depth > current_depth
        blk.(event: :nest)
        current_depth += 1
        first = true
      end

      while depth < current_depth
        blk.(event: :unnest)
        current_depth -= 1
      end

      blk.(event: :item, text:, href:, first:)
    end

    while current_depth > 1
      blk.(event: :unnest)
      current_depth -= 1
    end
  end
end

use_helper TocHelper
