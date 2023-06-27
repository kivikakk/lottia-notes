require 'nokogiri'


class TocFilter < Nanoc::Filter
  identifier :toc

  def self.current_toc(item)
    @@current_toc&.[](item)
  end

  def run(content, params={})
    doc = Nokogiri::HTML(content)

    toc = []
    levels = []

    (doc/"h1, h2, h3, h4").each do |header|
      CollectTextAndIdVisitor.new.tap { |visitor| header.accept(visitor) } => {text:, id:}
      next if text.empty? || id.nil?

      level = header.name[1].to_i
      level += 1 if rand > 0.5
      while levels[-1] != level
        if levels.empty? || level > levels[-1]
          levels << level
        else
          levels.pop while levels.any? && level < levels[-1]
        end
      end

      toc << {text:, href: "##{id}", depth: levels.length}
    end

    @@current_toc = {item => toc}

    content
  end

  class CollectTextAndIdVisitor
    def initialize
      @text = +""
      @id = nil
    end

    def visit(node)
      if node[:id]
        raise "multiple ids found" if !@id.nil?
        @id = node[:id]
      end

      if node.text?
        @text << node.text
      elsif node.name == "a"
        # pass
      else
        node.children.each { |child| visit(child) }
      end
    end

    def deconstruct_keys(_keys)
      {text: @text.strip.freeze, id: @id.freeze}
    end
  end
end

module TocHelper
  def toc
    TocFilter.current_toc(item)
  end

  def toc_walker(&blk)
    toc = self.toc

    current_depth = 0
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

    while current_depth > 0
      blk.(event: :unnest)
      current_depth -= 1
    end
  end
end

use_helper TocHelper
